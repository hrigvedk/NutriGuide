//
//  MainContentView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import SwiftUI
import Firebase

struct MainContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                NutritionDashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                BarcodeScannerView(selectedTab: .constant(selectedTab))
            }
            .tabItem {
                Label("Scan", systemImage: "barcode.viewfinder")
            }
            .tag(1)
            
            NavigationView {
                FoodDiaryView()
            }
            .tabItem {
                Label("Food Diary", systemImage: "calendar.badge.plus")
            }
            .tag(2)
            
            NavigationView {
                NutritionAssistantView()
            }
            .tabItem {
                Label("Assistant", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(3)
        }
    }
}

