//
//  WhereImApp.swift
//  WhereIm
//
//  Created by Андрей on 25.07.2024.
//

import SwiftUI

@main
struct WhereImApp: App {
    
    @AppStorage("AppState") var appState: AppState = .intro
    
    init() {
        // Start value for appState
        if appState != .intro {
            appState = .intro
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
