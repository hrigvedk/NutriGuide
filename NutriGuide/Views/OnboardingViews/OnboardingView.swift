//
//  OnboardingView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/4/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct OnboardingView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var currentStep = 0
    @State private var userData = UserProfileData()
    @State private var isCompleted = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var helper = Helpers()
    
    private let totalSteps = 7
    
    var body: some View {
        VStack {
            HStack {
                ProgressBar(value: Double(currentStep) / Double(totalSteps - 1))
                    .frame(height: 8)
                
                Text("\(currentStep + 1)/\(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(spacing: 20) {
                    switch currentStep {
                    case 0:
                        WelcomeStepView()
                    case 1:
                        PersonalMetricsView(userData: $userData)
                    case 2:
                        AllergensStepView(userData: $userData)
                    case 3:
                        HealthConditionsStepView(userData: $userData)
                    case 4:
                        DietaryPreferencesStepView(userData: $userData)
                    case 5:
                        MedicationsStepView(userData: $userData)
                    case 6:
                        EmergencyContactStepView(userData: $userData)
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .animation(.default, value: currentStep)
            }
            
            HStack {
                if currentStep > 0 {
                    Button(action: {
                        if currentStep > 0 {
                            currentStep -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if currentStep < totalSteps - 1 {
                        currentStep += 1
                    } else {
                        saveUserData()
                    }
                }) {
                    Text(currentStep < totalSteps - 1 ? "Next" : "Finish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $isCompleted) {
            MainContentView()
        }
    }
    
    private func saveUserData() {
        guard let userId = authService.user?.uid else {
            errorMessage = "User not found. Please try again."
            showError = true
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let medicationsData = self.userData.medications.map { medication in
            return [
                "id": medication.id.uuidString,
                "name": medication.name,
                "dosage": medication.dosage,
                "frequency": medication.frequency,
                "notes": medication.notes
            ]
        }
        
        let emergencyContactData: [String: Any] = [
            "name": self.userData.emergencyContact.name,
            "relationship": self.userData.emergencyContact.relationship,
            "phone": self.userData.emergencyContact.phone,
            "isAuthorized": self.userData.emergencyContact.isAuthorized
        ]
        
        let bmi = helper.calculateBMI(height: self.userData.height, weight: self.userData.weight)
        let (calories, protein, carbs, fat) = helper.calculateNutritionalRequirements(
            weight: self.userData.weight,
            height: self.userData.height,
            age: self.userData.age,
            gender: self.userData.gender,
            activityLevel: self.userData.activityLevel
        )
        
        let userData: [String: Any] = [
            "height": self.userData.height,
            "weight": self.userData.weight,
            "age": self.userData.age,
            "gender": self.userData.gender,
            "activityLevel": self.userData.activityLevel,
            
            "bmi": bmi,
            "dailyCalories": calories,
            "dailyProtein": protein,
            "dailyCarbs": carbs,
            "dailyFat": fat,
            
            "allergens": self.userData.allergens,
            "otherAllergens": self.userData.otherAllergens,
            "foodIntolerances": self.userData.foodIntolerances,
            "healthConditions": self.userData.healthConditions,
            "otherHealthConditions": self.userData.otherHealthConditions,
            "dietaryPreferences": self.userData.dietaryPreferences,
            "otherDietaryPreferences": self.userData.otherDietaryPreferences,
            
            "medications": medicationsData,
            "emergencyContact": emergencyContactData,
            
            "onboardingCompleted": true,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        userRef.setData(userData, merge: true) { error in
            if let error = error {
                print("Firebase error: \(error.localizedDescription)")
                self.errorMessage = "Failed to save profile: \(error.localizedDescription)"
                self.showError = true
            } else {
                print("Successfully saved user data to Firestore")
                self.isCompleted = true
            }
        }
    }
}
