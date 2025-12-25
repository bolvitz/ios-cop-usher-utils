//
//  EventMonitorApp.swift
//  EventMonitor
//
//  Created by Claude
//  iOS equivalent of android-cop-usher-utils
//

import SwiftUI
import SwiftData

@main
struct EventMonitorApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Venue.self,
                    AreaTemplate.self,
                    Event.self,
                    EventType.self,
                    AreaCount.self,
                    LostItem.self,
                    Incident.self
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VenueListScreen()
            }
            .modelContainer(modelContainer)
            .preferredColorScheme(.light) // Match Android default
        }
    }
}
