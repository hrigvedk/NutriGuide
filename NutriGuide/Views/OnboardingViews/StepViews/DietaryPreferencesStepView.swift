//
//  DietaryPreferencesStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/7/25.
//

import SwiftUICore
import SwiftUI

struct DietaryPreferencesStepView: View {
    @Binding var userData: UserProfileData
    @State private var showOtherPreferencesField = false
    
    private let dietaryPreferences = [
        "Vegetarian", "Vegan", "Pescatarian", "Paleo", "Keto",
        "Mediterranean", "Gluten-Free", "Low-FODMAP", "Kosher", "Halal",
        "Intermittent Fasting", "Whole30", "Low-Carb", "Low-Fat"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dietary Preferences")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Select any dietary preferences or restrictions you follow. This helps us recommend foods that align with your lifestyle.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Common Dietary Preferences")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(dietaryPreferences, id: \.self) { preference in
                        SelectableTag(
                            title: preference,
                            isSelected: userData.dietaryPreferences.contains(preference),
                            action: {
                                toggleSelection(preference, in: $userData.dietaryPreferences)
                            }
                        )
                    }
                    
                    SelectableTag(
                        title: "Other",
                        isSelected: showOtherPreferencesField,
                        action: {
                            showOtherPreferencesField.toggle()
                        }
                    )
                }
                
                if showOtherPreferencesField {
                    TextField("Enter other dietary preferences (comma separated)", text: $userData.otherDietaryPreferences)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            InfoBox(
                title: "Almost there!",
                message: "After this step, we'll have everything we need to personalize your NutriGuide experience."
            )
        }
    }
    
    private func toggleSelection(_ item: String, in binding: Binding<[String]>) {
        if binding.wrappedValue.contains(item) {
            binding.wrappedValue.removeAll { $0 == item }
        } else {
            binding.wrappedValue.append(item)
        }
    }
}
