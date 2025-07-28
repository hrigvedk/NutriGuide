//
//  ProfileView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(getUserName())
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let email = authService.user?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                VStack(spacing: 2) {
                    profileMenuButton(title: "Personal Information", icon: "person.fill") {
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    profileMenuButton(title: "Dietary Preferences", icon: "fork.knife") {
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    profileMenuButton(title: "Allergens & Sensitivities", icon: "exclamationmark.shield") {
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    profileMenuButton(title: "Health Conditions", icon: "heart.text.square") {
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                VStack(spacing: 2) {
                    profileMenuButton(title: "Notifications", icon: "bell.fill") {
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    profileMenuButton(title: "Privacy Settings", icon: "lock.fill") {
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    profileMenuButton(title: "About", icon: "info.circle") {
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Button(action: {
                    try? authService.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("Profile")
    }
    
    private func getUserName() -> String {
        if let displayName = authService.user?.displayName, !displayName.isEmpty {
            return displayName
        } else if authService.user?.isAnonymous == true {
            return "Guest User"
        } else {
            return "User"
        }
    }
    
    private func profileMenuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
