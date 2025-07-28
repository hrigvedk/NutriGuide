//
//  ProgressBar.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//

import SwiftUICore

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.blue)
                    .animation(.linear, value: value)
            }
            .cornerRadius(45)
        }
    }
}
