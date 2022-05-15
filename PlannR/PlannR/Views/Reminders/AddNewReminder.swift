//
//  AddNewReminder.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 13/05/2022.
//

import SwiftUI

struct AddNewReminder: View {
    @EnvironmentObject var reminderModel: ReminderViewModel
    @AppStorage("isDarkMode") var isDark1 = StorageSettings.isDark
    // MARK: Environment Values
    @Environment(\.self) var env
    var body: some View {
        NavigationView{
            VStack(spacing: 15){
                TextField("Title", text: $reminderModel.title)
                    .padding(.horizontal)
                    .padding(.vertical,10)
                    .background{ isDark1 ?  RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(.gray).opacity(0.5)) :
                         RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(.lightGray).opacity(0.5))
                    }
                
                // MARK: Reminder Color Selector
                HStack(spacing: 0){
                    ForEach(1...7, id: \.self){index in
                        let color = "Color-\(index)"
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .overlay(content: {
                                if color == reminderModel.reminderColor{
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                }
                            })
                            .onTapGesture {
                                withAnimation{
                                    reminderModel.reminderColor = color
                                }
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                // MARK: Frequency Selection
                VStack(alignment: .leading, spacing: 6){
                    Text("Frequency")
                        .font(.callout.bold())
                    let weekDays = Calendar.current.weekdaySymbols
                    HStack(spacing: 10){
                        ForEach(weekDays, id: \.self){day in
                            let index = reminderModel.weekDays.firstIndex { value in
                                return value == day
                            } ?? -1
                            // MARK: Limits to First 2 Letters
                            Text(day.prefix(2))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical,12)
                                .background{isDark1 ? RoundedRectangle(cornerRadius: 6, style: .continuous).fill(index != -1 ? Color(reminderModel.reminderColor):Color("BG").opacity(0.4)) :
                                    RoundedRectangle(cornerRadius: 6, style: .continuous).fill(index != -1 ? Color(reminderModel.reminderColor): Color(.white).opacity(0.4))
                                }
                                .onTapGesture {
                                    withAnimation{
                                        if index != -1{
                                            reminderModel.weekDays.remove(at: index)
                                        }
                                        else{
                                            reminderModel.weekDays.append(day)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top,15)
                }
                
                Divider()
                    .padding(.vertical,10)
                
                // Hiding If Notification Access is Rejected
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text("Reminder")
                            .foregroundColor(isDark1 ? .black : .white)
                            .fontWeight(.semibold)
                        
                        Text("Set notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $reminderModel.isReminderOn){}
                        .labelsHidden()
                    
                }
                .opacity(reminderModel.notificationAccess ? 1 : 0)
                
                HStack(spacing: 12){
                    Label {
                        Text(reminderModel.reminderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background{ isDark1 ? RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color("BG").opacity(0.4)) : RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(.gray).opacity(0.5))
                    }
                    .onTapGesture{
                        withAnimation{
                            reminderModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("Reminder Text", text: $reminderModel.reminderText)
                        .padding(.horizontal)
                        .padding(.vertical,10)
                        .background{isDark1 ?  RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.gray).opacity(0.5)) :
                             RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(.lightGray).opacity(0.5))
                        }
                }
                .frame(height: reminderModel.isReminderOn ? nil : 0)
                .opacity(reminderModel.isReminderOn ? 1 : 0)
                .opacity(reminderModel.notificationAccess ? 1 : 0)
            }
            .animation(.easeInOut, value: reminderModel.isReminderOn)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(reminderModel.editReminder != nil ? "Edit Reminder" : "Add Reminder")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        env.dismiss()
                    } label: {isDark1 ? Image(systemName: "xmark.circle.fill").foregroundColor(.black) : Image(systemName: "xmark.circle").foregroundColor(.white)
                    }
                    .tint(.white)
                }
                
                // MARK: Delete Button
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        if reminderModel.deleteReminder(context: env.managedObjectContext){
                            env.dismiss()
                        }
                    } label: { isDark1 ? Image(systemName: "trash.fill").foregroundColor(.black) : Image(systemName: "trash").foregroundColor(.white)
                    }
                    .tint(.white)
                    .opacity(reminderModel.editReminder == nil ? 0 : 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done"){
                        Task{
                            if await reminderModel.addReminder(context: env.managedObjectContext){
                                env.dismiss()
                            }
                        }
                    }
                    .tint(.white)
                    .disabled(!reminderModel.doneStatus())
                    .opacity(reminderModel.doneStatus() ? 1 : 0.6)
                    .foregroundColor(isDark1 ? .black : .white)
                }
            }
        }
        .overlay{
            if reminderModel.showTimePicker{
                ZStack{
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation{
                                reminderModel.showTimePicker.toggle()
                            }
                        }
                    
                    DatePicker.init("", selection: $reminderModel.reminderDate,displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("BG"))
                        }
                        .padding()
                    
                }
            }
        }
    }
}

struct AddNewReminder_Previews: PreviewProvider {
    static var previews: some View {
        AddNewReminder()
            .environmentObject(ReminderViewModel())
    }
}
