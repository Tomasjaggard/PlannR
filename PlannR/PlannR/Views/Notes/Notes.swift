//
//  NewView.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 14/05/2022.
//

import SwiftUI
 
struct Notes: View {
 
    @AppStorage("isDarkMode") var isDark = StorageSettings.isDark
    @State var newItem: String = ""
    @State var notes: [String] = []
    @State var isAlert: Bool = false
    @State var trimmed: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack{
                
                EditButton()
                    .frame(width: 50)
                
                ZStack{
                    Text("Notes")
                        .foregroundColor(isDark ? .black : .white)
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .trailing){
                        }
                }

                        Button(action:{isDark.toggle()
                        }, label: {
                            isDark ? Label("", systemImage: "lightbulb.fill") : Label("", systemImage: "lightbulb")
                        })
            }
 
            HStack {
                TextField("Add Note", text: $newItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
 
                Button(action: {
                    trimmed = self.newItem.trimmingCharacters(in: .whitespaces)
                    if trimmed.isEmpty {
                        self.isAlert.toggle()
                    } else {
                        self.notes.append(trimmed)
                        self.newItem = ""
                        UserDefaults.standard.set(self.notes, forKey: "notes")
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 50, height: 30)
                            .foregroundColor(Color.cyan)
 
                        Text("Add")
                            .foregroundColor(.white)
                    }
                }
            }
 
            List {
                ForEach (notes, id: \.self) { item in
                    Text(item)
                        .padding()
                }.onDelete { IndexSet in
                    self.notes.remove(atOffsets: IndexSet)
                    UserDefaults.standard.set(self.notes, forKey: "notes")
                }.onMove { (IndexSet, Destination) in
                    self.notes.move(fromOffsets: IndexSet, toOffset: Destination)
                    UserDefaults.standard.set(self.notes, forKey: "notes")
                }
 
            }
 
            Spacer()
 
        }
        .alert(isPresented: self.$isAlert) {
            Alert(title: Text("This cannot be blank"), message: Text("Please enter text"), dismissButton: .default(Text("Ok")))
        }.onAppear() {
            guard let defaultItem = UserDefaults.standard.array(forKey: "notes") as? [String]
                else {return}
            self.notes = defaultItem
        }
    }
}
 
struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        Notes()
    }
}
