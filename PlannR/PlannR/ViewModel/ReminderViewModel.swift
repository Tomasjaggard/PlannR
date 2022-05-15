//
//  ReminderViewModel.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 13/05/2022.
//

import SwiftUI
import CoreData
import UserNotifications

class ReminderViewModel: ObservableObject {
    // MARK: New Reminder Properties
    @Published var addNewReminder: Bool = false
    
    @Published var title: String = ""
    @Published var reminderColor: String = "Color-1"
    @Published var weekDays: [String] = []
    @Published var isReminderOn: Bool = false
    @Published var reminderText: String = ""
    @Published var reminderDate: Date = Date()
    
    // MARK: Reminder Time Picker
    @Published var showTimePicker: Bool = false
    
    // MARK: Editing Reminder
    @Published var editReminder: Reminder?
    
    // Mark: Notification Access Status
    @Published var notificationAccess: Bool = false
    
    init(){
        requestNotificationAccess()
    }
    
    func requestNotificationAccess(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert]) {status, _ in DispatchQueue.main.async{
            self.notificationAccess = status
            }
        }
    }
        
    // MARK: Adding Reminder to Database
    func addReminder(context: NSManagedObjectContext)async->Bool{
        
        // MARK: Editing Data
        var reminder: Reminder!
        if let editReminder = editReminder {
            reminder = editReminder
            //removing all pending notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editReminder.notificationIDs ?? [])
        }else{
            reminder = Reminder(context: context)
        }
        reminder.title = title
        reminder.color = reminderColor
        reminder.weekDays = weekDays
        reminder.isReminderOn = isReminderOn
        reminder.reminderText = reminderText
        reminder.notificationDate = reminderDate
        reminder.notificationIDs = []
        
        if isReminderOn{
            // MARK: Scheduling Notifications
            if let ids = try? await scheduleNotification(){
                reminder.notificationIDs = ids
                if let _ = try? context.save(){
                    return true
                }
            }
        }else{
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    // MARK: Adding Notifications
    func scheduleNotification()async throws->[String]{
        let content = UNMutableNotificationContent()
        content.title = "Reminder Notif"
        content.subtitle = reminderText
        content.sound = UNNotificationSound.default
        
        // Scheduled IDs
        var notificationIDs: [String] = []
        let calendar = Calendar.current
        let weekdaySymbols: [String] = calendar.weekdaySymbols
        
        // MARK: Scheduling Notification
        for weekDay in weekDays{
            // UNIQUE ID FOR EACH NOTIFICATION
            let id =  UUID().uuidString
            let hour = calendar.component(.hour, from: reminderDate)
            let min = calendar.component(.minute, from: reminderDate)
            let day = weekdaySymbols.firstIndex { currentDay in
                return currentDay == weekDay
            } ?? -1
            
            // MARK: Since Week Day Starts from 1-7
            // Thus Adding +1 to Index
            if day != -1{
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                // MARK: Thus this will Trigger Notification on Each Selected Day
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // MARK: Notification Request
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                
                //ADDING ID
                notificationIDs.append(id)
            }
        }
        
        return notificationIDs
    }
    
    // MARK: Erasing Content
    func resetData(){
        title = ""
        reminderColor = "Color-1"
        weekDays = []
        isReminderOn = false
        reminderDate = Date()
        reminderText = ""
        editReminder = nil
    }
    
    // MARK: Deleting Reminder From Database
    func deleteReminder(context: NSManagedObjectContext)->Bool{
        if let editReminder = editReminder {
            if editReminder.isReminderOn{
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: editReminder.notificationIDs ?? [])
            }
            context.delete(editReminder)
            if let _ = try? context.save(){
                return true
            }
        }
        return false
    }
    
    // MARK: Restoring Edit Data
    func restoreEditData(){
        if let editReminder = editReminder {
            title = editReminder.title ?? ""
            reminderColor = editReminder.color ?? "Color-1"
            weekDays = editReminder.weekDays ?? []
            isReminderOn = editReminder.isReminderOn
            reminderDate = editReminder.notificationDate ?? Date()
            reminderText = editReminder.reminderText ?? ""
        }
    }
    // MARK: Done Button Status
    func doneStatus()->Bool{
        let reminderStatus = isReminderOn ? reminderText == "" : false
        
        if title == "" || weekDays.isEmpty || reminderStatus{
            return false
        }
        return true
    }
}
