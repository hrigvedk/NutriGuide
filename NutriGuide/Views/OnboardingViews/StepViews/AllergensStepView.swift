//
//  AllergensStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//

import SwiftUICore
import Foundation
import SwiftUI


struct AllergensStepView: View {
    @Binding var userData: UserProfileData
    @State private var showOtherAllergensField = false
    
    private let commonAllergens = [
        "Peanuts", "Tree Nuts", "Milk", "Eggs", "Wheat", "Soy",
        "Fish", "Shellfish", "Sesame"
    ]
    
    private let commonIntolerances = [
        "Lactose", "Gluten", "FODMAPs", "Histamine", "Caffeine",
        "Salicylates", "MSG", "Sulfites", "Fructose"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Allergens & Sensitivities")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Select any food allergies or intolerances you have. This helps us identify foods you should avoid.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Common Food Allergies")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(commonAllergens, id: \.self) { allergen in
                        SelectableTag(
                            title: allergen,
                            isSelected: userData.allergens.contains(allergen),
                            action: {
                                toggleSelection(allergen, in: $userData.allergens)
                            }
                        )
                    }
                    
                    SelectableTag(
                        title: "Other",
                        isSelected: showOtherAllergensField,
                        action: {
                            showOtherAllergensField.toggle()
                        }
                    )
                }
                
                if showOtherAllergensField {
                    TextField("Enter other allergies (comma separated)", text: $userData.otherAllergens)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Food Intolerances")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(commonIntolerances, id: \.self) { intolerance in
                        SelectableTag(
                            title: intolerance,
                            isSelected: userData.foodIntolerances.contains(intolerance),
                            action: {
                                toggleSelection(intolerance, in: $userData.foodIntolerances)
                            }
                        )
                    }
                }
            }
            
            InfoBox(
                title: "What's the difference?",
                message: "Food allergies can trigger immune system reactions that can be severe or life-threatening. Food intolerances typically cause digestive issues and are generally less serious."
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
