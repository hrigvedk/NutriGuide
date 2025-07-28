//
//  InfoBox.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/24/25.
//
import SwiftUI

struct InfoBox: View {
    var title: String
    var message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
