//
//  ContentView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/1/25.
//

import SwiftUI
import Firebase

// MARK: - Main App Entry
struct NutriGuide: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false
    @State private var showOnboarding = false
    @State private var hasCompletedOnboarding = false
    
    var body: some View {
        if authService.isAuthenticated {
            if showOnboarding {
                OnboardingView()
            } else {
                MainContentView()
                    .onAppear {
                        checkOnboardingStatus()
                    }
            }
        } else {
            WelcomeView(
                isShowingLogin: $isShowingLogin,
                isShowingSignUp: $isShowingSignUp
            )
            .fullScreenCover(isPresented: $isShowingLogin) {
                LoginView(
                    isPresented: $isShowingLogin,
                    switchToSignUp: {
                        isShowingLogin = false
                        isShowingSignUp = true
                    }
                )
            }
            .fullScreenCover(isPresented: $isShowingSignUp) {
                SignUpView(
                    isPresented: $isShowingSignUp,
                    isLoggedIn: .constant(false),
                    switchToLogin: {
                        isShowingSignUp = false
                        isShowingLogin = true
                    }
                )
                .onDisappear {
                    if authService.isAuthenticated {
                        showOnboarding = true
                    }
                }
            }
        }
    }
    
    private func checkOnboardingStatus() {
        guard let userId = authService.user?.uid else {
            showOnboarding = true
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let hasCompleted = document.data()?["onboardingCompleted"] as? Bool ?? false
                if !hasCompleted {
                    showOnboarding = true
                } else {
                    hasCompletedOnboarding = true
                }
            } else {
                showOnboarding = true
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NutriGuide()
    }

}

#Preview {
    @Previewable @State var glow = false
    Button(action: {
    }) {
        HStack {
            Image(systemName: "chart.bar.doc.horizontal")
            Text("Analyze")
        }
        .padding()
        .background(Color.green.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(color: Color.green.opacity(3.0), radius: glow ? 30 : 10)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glow.toggle() }
        }
    }
}
