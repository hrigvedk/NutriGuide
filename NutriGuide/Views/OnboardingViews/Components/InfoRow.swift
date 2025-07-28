//
//  InfoRow.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import SwiftUI

struct InfoRow: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: getSystemImageName(for: icon))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func getSystemImageName(for icon: String) -> String {
        switch icon {
        case "allergens": return "exclamationmark.shield"
        case "health": return "heart.text.square"
        case "diet": return "fork.knife"
        case "pills": return "pills.fill"
        case "emergency": return "person.crop.circle.badge.exclamationmark"
        default: return "circle"
        }
    }
}
