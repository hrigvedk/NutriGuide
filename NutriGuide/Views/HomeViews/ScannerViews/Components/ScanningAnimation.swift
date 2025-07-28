//
//  ScanningAnimation.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct ScanningAnimation: ViewModifier {
    let boxHeight: CGFloat
    @State private var offsetY: CGFloat = -100
    
    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    offsetY = 100
                }
            }
    }
}
