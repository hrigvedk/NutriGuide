//
//  NovaGroupInfoView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct NovaGroupInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("NOVA Food Classification System")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("The NOVA system classifies foods according to the extent and purpose of food processing, rather than nutrients found in the foods. There are 4 groups:")
                        .font(.body)
                    
                    Group {
                        novaGroupInfoSection(
                            group: 1,
                            title: "Unprocessed or minimally processed foods",
                            description: "Natural foods altered by processes such as removal of inedible parts, drying, crushing, grinding, filtering, roasting, boiling, pasteurization, refrigeration, freezing, or fermentation.",
                            examples: "Fresh fruits, vegetables, grains, legumes, meat, eggs, milk"
                        )
                        
                        novaGroupInfoSection(
                            group: 2,
                            title: "Processed culinary ingredients",
                            description: "Substances derived from Group 1 foods or from nature by processes such as pressing, refining, grinding, milling.",
                            examples: "Salt, sugar, honey, vegetable oils, butter, lard"
                        )
                        
                        novaGroupInfoSection(
                            group: 3,
                            title: "Processed foods",
                            description: "Products made by adding Group 2 ingredients to Group 1 foods, using preservation methods such as canning and bottling, and non-alcoholic fermentation.",
                            examples: "Canned vegetables, fruit in syrup, salted nuts, cheese, fresh bread"
                        )
                        
                        novaGroupInfoSection(
                            group: 4,
                            title: "Ultra-processed food and drink products",
                            description: "Industrial formulations with five or more ingredients, typically including sugars, oils, fats, salt, anti-oxidants, stabilizers, and preservatives. May contain additives that imitate or enhance the sensory qualities of foods.",
                            examples: "Carbonated soft drinks, packaged snacks, confectionery, ice cream, breakfast cereals, energy bars, instant noodles"
                        )
                    }
                    
                    Text("The NOVA classification is increasingly used in dietary research and is incorporated into dietary guidelines in several countries, including Brazil and Uruguay.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationBarTitle("Processing Level", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    private func novaGroupInfoSection(group: Int, title: String, description: String, examples: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Group \(group)")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(novaGroupColor(group))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(description)
                .font(.body)
            
            Text("Examples: \(examples)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func novaGroupColor(_ group: Int) -> Color {
        switch group {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }
}
