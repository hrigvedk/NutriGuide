//
//  PersonalMetricsView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//

import SwiftUICore
import SwiftUI

struct PersonalMetricsView: View {
    @Binding var userData: UserProfileData
    
    private let activityLevels = [
        "Sedentary",
        "Lightly Active",
        "Moderately Active",
        "Very Active",
        "Extra Active"
    ]
    
    private let activityDescriptions = [
        "Sedentary": "Little or no exercise, desk job",
        "Lightly Active": "Light exercise 1-3 days/week",
        "Moderately Active": "Moderate exercise 3-5 days/week",
        "Very Active": "Hard exercise 6-7 days/week",
        "Extra Active": "Very hard exercise, physical job, or training twice a day"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We'll use this information to calculate your nutritional needs and personalize recommendations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gender")
                            .font(.headline)
                        
                        Picker("Gender", selection: $userData.gender) {
                            Text("Select Gender").tag("")
                            Text("Male").tag("male")
                            Text("Female").tag("female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.headline)
                        
                        HStack {
                            TextField("Enter your age", value: $userData.age, format: .number)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .frame(maxWidth: 150)
                            
                            Text("years")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.headline)
                        
                        HStack {
                            TextField("Enter your height", value: $userData.height, format: .number)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .frame(maxWidth: 150)
                            
                            Text("cm")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.headline)
                        
                        HStack {
                            TextField("Enter your weight", value: $userData.weight, format: .number)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .frame(maxWidth: 150)
                            
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Level")
                            .font(.headline)
                        
                        ForEach(activityLevels, id: \.self) { level in
                            Button(action: {
                                userData.activityLevel = level
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: userData.activityLevel == level ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(userData.activityLevel == level ? .blue : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(level)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        if let description = activityDescriptions[level] {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(userData.activityLevel == level ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !userData.gender.isEmpty &&
        userData.age > 0 &&
        userData.height > 100 &&
        userData.weight > 30 &&
        !userData.activityLevel.isEmpty
    }
}
