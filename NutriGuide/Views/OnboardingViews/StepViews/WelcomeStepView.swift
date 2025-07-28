//
//  WelcomeStepView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import SwiftUI

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("color-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.1)))
            
            Text("Let's Personalize Your Experience")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("We'll ask you a few questions to help customize NutriGuide to your specific health needs and dietary preferences.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(icon: "health", title: "BMI and Activity Level", description: "Determine your nutritional needs")
                
                InfoRow(icon: "allergens", title: "Allergens & Sensitivities", description: "Identify foods you need to avoid")
                
                InfoRow(icon: "health", title: "Health Conditions", description: "Help us understand your dietary requirements")
                
                InfoRow(icon: "diet", title: "Dietary Preferences", description: "Tell us about your eating habits and restrictions")
                
                InfoRow(icon: "pills", title: "Medications", description: "Add details about your medications")
                
                InfoRow(icon: "emergency", title: "Emergency Contact", description: "Contact details for medical emergencies")
                
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
            
            Text("Your information is private and will only be used to personalize your experience.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
    }
}
