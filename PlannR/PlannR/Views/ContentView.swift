//
//  ContentView.swift
//  Tracker App
//
//  Created by Tomas Jaggard on 13/05/2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") var isDark1 = StorageSettings.isDark
    var body: some View {
        TabView{
            Home()
                .tabItem{
                    Label("Alerts", systemImage: "calendar")
                }
            Notes()
                .tabItem{
                    Label("Tools", systemImage: "list.dash")
                }

        }
        .preferredColorScheme( isDark1 ? .light : .dark)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
