//
//  SignupView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Binding var isPresented: Bool
    @Binding var isLoggedIn: Bool
    var switchToLogin: () -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeToTerms = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        isValidEmail(email) &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        agreeToTerms
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get started with NutriGuide")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                                .foregroundColor(.primary.opacity(0.8))
                            
                            TextField("Enter your name", text: $name)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
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
                            
                            if !email.isEmpty && !isValidEmail(email) {
                                    Text("Please enter a valid email address")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.top, 4)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.primary.opacity(0.8))
                            
                            SecureInputView("Create a password", text: $password)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            if !password.isEmpty {
                                PasswordRequirementsView(password: password)
                            }
                        }
                
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.primary.opacity(0.8))
                            
                            SecureInputView("Confirm your password", text: $confirmPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            if !confirmPassword.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(password == confirmPassword ? .green : .red)
                                    
                                    Text("Passwords match")
                                        .font(.caption)
                                        .foregroundColor(password == confirmPassword ? .primary : .red)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $agreeToTerms) {
                            Text("I agree to the ")
                            HStack {
                                Button(action: {
                                }) {
                                    Text("Terms of Service")
                                        .underline()
                                }
                                
                                Text(" and ")
                                
                                Button(action: {
                                }) {
                                    Text("Privacy Policy")
                                        .underline()
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    Button(action: {
                        createAccount()
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
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
                        Text("Or sign up with")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            SocialLoginButton(type: .apple) {
                                createAccount()
                            }
                            
                            SocialLoginButton(type: .google) {
                                createAccount()
                            }
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            switchToLogin()
                        }) {
                            Text("Sign In")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 30)
                }
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
    
    private func createAccount() {
            guard isFormValid else {
                if password != confirmPassword {
                    errorMessage = "Passwords do not match"
                } else if !isValidEmail(email) {
                    errorMessage = "Please enter a valid email address"
                } else if !agreeToTerms {
                    errorMessage = "You must agree to the terms"
                } else {
                    errorMessage = "Please fill in all fields correctly"
                }
                return
            }
            
            isLoading = true
            errorMessage = ""
            
            Task {
                do {
                    try await authService.createAccount(email: email, password: password, name: name)
                    await MainActor.run {
                        isLoading = false
                        isPresented = false
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
