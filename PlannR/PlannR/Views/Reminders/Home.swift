//
//  Home.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 13/05/2022.
//

import SwiftUI

struct Home: View {
    @AppStorage("isDarkMode") var isDark = StorageSettings.isDark
    @FetchRequest(entity: Reminder.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Reminder.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var reminders: FetchedResults<Reminder>
    @StateObject var reminderModel: ReminderViewModel = .init()
    
    enum StorageSettings {
        static let isDark = false
    }
    
    var body: some View {
        VStack(spacing: 0){
            Text("Reminder")
                .foregroundColor(isDark ? .black : .white)
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing){
                    Button(action:{isDark.toggle()
                    }, label: {
                        isDark ? Label("", systemImage: "lightbulb.fill") : Label("", systemImage: "lightbulb")

                    })
                }
            
            // MAKING ADD BUTTON CENTER WHEN REMINDER'S EMPTY
            ScrollView(reminders.isEmpty ? .init() : .vertical, showsIndicators: false){
                VStack(spacing: 15){
                    
                    ForEach(reminders){ reminder in
                        ReminderCardView(reminder: reminder)
                    }
                    
                    // MARK: Add Reminder Button
                    Button{
                        reminderModel.addNewReminder.toggle()
                    } label: {
                        Label{
                            Text("New Reminder")
                                .foregroundColor(isDark ? .black : .white)
                        } icon: { isDark ? Image(systemName: "plus.circle.fill").foregroundColor(.black) : Image(systemName: "plus.circle").foregroundColor(.white)
                        }
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    }
                    .padding(.top,15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .padding(.vertical)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $reminderModel.addNewReminder){
            // MARK: Delete All Existing Content
            reminderModel.resetData()
            
        } content: {
            AddNewReminder()
                .environmentObject(reminderModel)
        }
    }
    
    // MARK: Reminder Card View
    @ViewBuilder
    func ReminderCardView(reminder: Reminder)->some View{
        VStack(spacing: 6){
            HStack{
                Text(reminder.title ?? "")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Image(systemName: "bell.badge.fill")
                    .font(.callout)
                    .foregroundColor(Color(reminder.color ?? "Card-1"))
                    .scaleEffect(0.9)
                    .opacity(reminder.isReminderOn ? 1 : 0)
                
                Spacer()
                
                let count = (reminder.weekDays?.count ?? 0)
                Text(count == 7 ? "Everyday" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal,10)
            
            // MARK: Displaying Current Week and Marking Active Reminder Dates
            let calendar = Calendar.current
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            let symbols = calendar.weekdaySymbols
            let startDate = currentWeek?.start ?? Date()
            let activeWeekDays = reminder.weekDays ?? []
            let activePlot = symbols.indices.compactMap{ index -> (String,Date) in
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                return (symbols[index],currentDate!)
            }
            
            HStack(spacing: 0){
                ForEach(activePlot.indices, id: \.self){ index in
                    let item = activePlot[index]
                    
                    VStack(spacing: 6){
                        // MARK: Limits to first 3 letters
                        Text(item.0.prefix(3))
                            .font(.caption)
                            .foregroundColor(.gray)
                        let status = activeWeekDays.contains{ day in
                            return day == item.0
                        }
                        Text(getDate(date: item.1))
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(8)
                            .background{
                                Circle()
                                    .fill(Color(reminder.color ?? "Card-1"))
                                    .opacity(status ? 1 : 0)
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top,15)
        }
        .padding(.vertical)
        .padding(.horizontal,6)
        .background{ isDark ?
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.gray).opacity(0.5)) :
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.lightGray).opacity(0.5))
        }
        .onTapGesture{
            // MARK: Editing reminder
            reminderModel.editReminder = reminder
            reminderModel.restoreEditData()
            reminderModel.addNewReminder.toggle()
        }
    }
    // MARK: Formatting Date
    func getDate(date: Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        return formatter.string(from: date)
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}