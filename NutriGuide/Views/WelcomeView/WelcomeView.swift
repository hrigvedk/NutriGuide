//
//  WelcomeView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isShowingLogin: Bool
    @Binding var isShowingSignUp: Bool
    
    var body: some View {
        ZStack {
            Image("food-background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
                .overlay(
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                )
            
            VStack(spacing: 30) {
                Spacer()
                
                Image("welcome-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150)
                
                Text("NutriGuide")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Personalized nutrition & allergen management")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        isShowingSignUp = true
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        isShowingLogin = true
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        continueAsGuest()
                    }) {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 60)
            }
        }
    }
    private func continueAsGuest() {
            Task {
                do {
                    try await authService.signInAnonymously()
                } catch {
                    print("Error signing in anonymously: \(error.localizedDescription)")
                }
            }
        }
}
