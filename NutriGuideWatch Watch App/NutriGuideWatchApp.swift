//
//  NutriGuideWatchApp.swift
//  NutriGuideWatch Watch App
//
//  Created by Hrigved Khatavkar on 4/6/25.
//

import SwiftUI
import UserNotifications

@main
struct NutriGuideWatchApp: App {
    // Initialize connectivity when app launches
    @StateObject private var connectivityHandler = WatchConnectivityHandler.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                EmergencyCardView()
            }
        }
        
        // Add notification handling for emergency alerts
        WKNotificationScene(controller: NotificationController.self, category: "emergencyAlert")
    }
}

// MARK: - Notification Controller

class NotificationController: WKUserNotificationHostingController<NotificationView> {
    var emergencyInfo: [String: Any] = [:]
    
    override var body: NotificationView {
        return NotificationView(info: emergencyInfo)
    }
    
    override func didReceive(_ notification: UNNotification) {
        // Cast the userInfo dictionary to [String: Any]
        let userData = notification.request.content.userInfo
        
        // Convert AnyHashable keys to String
        var stringKeyedDict: [String: Any] = [:]
        for (key, value) in userData {
            if let stringKey = key as? String {
                stringKeyedDict[stringKey] = value
            }
        }
        
        emergencyInfo = stringKeyedDict
    }
}

// MARK: - Notification View

struct NotificationView: View {
    var info: [String: Any]
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            
            Text("Health Alert")
                .font(.headline)
            
            if let name = info["name"] as? String {
                Text("For: \(name)")
                    .font(.subheadline)
            }
            
            if let conditions = info["healthConditions"] as? [String], !conditions.isEmpty {
                Text(conditions.first ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Open app for details")
                .font(.caption2)
                .padding(.top, 5)
        }
    }
}
