//
//  LoginView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isPresented: Bool
    var switchToSignUp: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showForgotPassword = false
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        SecureInputView("Enter your password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    loginWithEmail()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.blue.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal, 30)
                
                VStack(spacing: 16) {
                    Text("Or sign in with")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        SocialLoginButton(type: .apple) {
                            loginWithEmail()
                        }
                        
                        SocialLoginButton(type: .google) {
                            loginWithEmail()
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        switchToSignUp()
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .disabled(isLoading)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(isPresented: $showForgotPassword)
        }
    }
    
    private func loginWithEmail() {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Incorrect Email or Password. Please try again."
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.resetPassword(email: email)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

