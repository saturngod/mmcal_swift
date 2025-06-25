//
//  MMCalendarApp.swift
//  MMCalendar
//
//  Created by Bonjoy on 6/18/25.
//

import SwiftUI

@main
struct MMCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MacContentView()
            #else
            ContentView()
            #endif
        }
    }
}
