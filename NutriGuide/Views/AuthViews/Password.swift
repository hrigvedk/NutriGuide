//
//  Password.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter your email to receive a password reset link")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                if showSuccess {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        
                        Text("Reset link sent!")
                            .font(.headline)
                        
                        Text("Please check your email for instructions to reset your password.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
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
                    .padding(.horizontal)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                Spacer()
                
                if showSuccess {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Return to Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                } else {
                    Button(action: {
                        resetPassword()
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!email.isEmpty ? Color.blue : Color.blue.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isLoading || email.isEmpty)
                    .padding(.horizontal, 30)
                }
                
                Spacer().frame(height: 40)
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
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            showSuccess = true
        }
    }
}

// MARK: - Password Requirements View
struct PasswordRequirementsView: View {
    let password: String
    
    private var hasMinLength: Bool {
        password.count >= 8
    }
    
    private var hasUppercase: Bool {
        password.contains { $0.isUppercase }
    }
    
    private var hasNumber: Bool {
        password.contains { $0.isNumber }
    }
    
    private var hasSpecialCharacter: Bool {
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_-+=<>?")
        return password.unicodeScalars.contains { specialCharacterSet.contains($0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RequirementRow(text: "At least 8 characters", isMet: hasMinLength)
            RequirementRow(text: "At least 1 uppercase letter", isMet: hasUppercase)
            RequirementRow(text: "At least 1 number", isMet: hasNumber)
            RequirementRow(text: "At least 1 special character", isMet: hasSpecialCharacter)
        }
        .padding(.vertical, 4)
    }
}
