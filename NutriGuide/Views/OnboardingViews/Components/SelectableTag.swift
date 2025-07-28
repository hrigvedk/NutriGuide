//
//  SelectableTag.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//

import SwiftUICore
import SwiftUI

struct SelectableTag: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
