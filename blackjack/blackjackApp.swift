//
//  blackjackApp.swift
//  blackjack
//
//  Created by Noah Schlorf on 12/2/24.
//

import SwiftUI

@main
struct blackjackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
