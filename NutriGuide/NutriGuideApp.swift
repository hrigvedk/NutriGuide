//
//  NutriGuideApp.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/1/25.
//

import SwiftUI
import Firebase

@main
struct NutriGuideApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthenticationService.shared)
        }
    }
}


