//
//  HealthConditionsStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//

import SwiftUICore
import SwiftUI

struct HealthConditionsStepView: View {
    @Binding var userData: UserProfileData
    @State private var showOtherConditionsField = false
    
    private let commonHealthConditions = [
        "Diabetes", "Hypertension", "Heart Disease", "Kidney Disease",
        "Irritable Bowel Syndrome", "Celiac Disease", "GERD/Acid Reflux",
        "Inflammatory Bowel Disease", "Gout"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Health Conditions")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Select any health conditions that may affect your dietary needs. This helps us provide more relevant nutrition guidance.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Common Health Conditions")
                    .font(.headline)
                
                FlowLayout(spacing: 8) {
                    ForEach(commonHealthConditions, id: \.self) { condition in
                        SelectableTag(
                            title: condition,
                            isSelected: userData.healthConditions.contains(condition),
                            action: {
                                toggleSelection(condition, in: $userData.healthConditions)
                            }
                        )
                    }
                    
                    SelectableTag(
                        title: "Other",
                        isSelected: showOtherConditionsField,
                        action: {
                            showOtherConditionsField.toggle()
                        }
                    )
                }
                
                if showOtherConditionsField {
                    TextField("Enter other health conditions (comma separated)", text: $userData.otherHealthConditions)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            InfoBox(
                title: "Privacy Note",
                message: "Your health information is stored securely and only used to provide personalized nutrition guidance. You can update this information anytime in your profile settings."
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
