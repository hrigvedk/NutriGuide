//
//  NutritionScoreInfoView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct NutritionScoreInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Nutritional Quality Score")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("The Nutritional Quality Score is a measure from 0-100 that evaluates the overall nutritional quality of a food product based on several factors:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        scoreFactorRow(
                            title: "Nutrient Balance",
                            description: "How well the food provides a balanced mix of macro and micronutrients",
                            impact: "30%"
                        )
                        
                        scoreFactorRow(
                            title: "Nutrient Density",
                            description: "Amount of beneficial nutrients relative to calories",
                            impact: "25%"
                        )
                        
                        scoreFactorRow(
                            title: "Ingredient Quality",
                            description: "Use of whole, natural ingredients vs. refined or artificial ingredients",
                            impact: "20%"
                        )
                        
                        scoreFactorRow(
                            title: "Processing Level",
                            description: "Degree of industrial processing and refinement",
                            impact: "15%"
                        )
                        
                        scoreFactorRow(
                            title: "Harmful Components",
                            description: "Presence of potentially harmful ingredients like trans fats, excess sodium, or added sugars",
                            impact: "10%"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Text("Score Ranges:")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        scoreRangeRow(range: "80-100", description: "Excellent nutritional quality", color: .green)
                        scoreRangeRow(range: "60-79", description: "Good nutritional quality", color: .blue)
                        scoreRangeRow(range: "40-59", description: "Average nutritional quality", color: .yellow)
                        scoreRangeRow(range: "20-39", description: "Poor nutritional quality", color: .orange)
                        scoreRangeRow(range: "0-19", description: "Very poor nutritional quality", color: .red)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Text("This score is designed to help you make informed food choices and should be considered alongside other factors like personal dietary needs and preferences.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationBarTitle("Nutrition Score", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    private func scoreFactorRow(title: String, description: String, impact: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(impact)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 50)
        }
    }
    
    private func scoreRangeRow(range: String, description: String, color: Color) -> some View {
        HStack {
            Text(range)
                .font(.headline)
                .frame(width: 80)
            
            Rectangle()
                .fill(color)
                .frame(width: 24, height: 24)
                .cornerRadius(4)
            
            Text(description)
                .font(.subheadline)
        }
    }
}
