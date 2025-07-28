//
//  LottieLoadingView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct LottieLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.1), lineWidth: 14)
                .frame(width: 150, height: 150)
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.1)]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            VStack(spacing: 10) {
                Text("Analyzing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
    }
}
