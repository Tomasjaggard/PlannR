//
//  Tracker_AppApp.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 13/05/2022.
//

import SwiftUI

@main
struct PlannR_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
