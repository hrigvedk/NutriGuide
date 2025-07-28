//
//  BMIScaleView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct BMIScaleView: View {
    let bmi: Double
    @State private var animatedBMIOffset: CGFloat = 0
    @State private var helper = Helpers()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 6) {
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(height: 16)
                            .foregroundColor(.blue.opacity(0.6))
                        Rectangle()
                            .frame(height: 16)
                            .foregroundColor(.green.opacity(0.6))
                        Rectangle()
                            .frame(height: 16)
                            .foregroundColor(.orange.opacity(0.6))
                        Rectangle()
                            .frame(height: 16)
                            .foregroundColor(.red.opacity(0.6))
                    }
                    .cornerRadius(8)
                    
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(helper.getBMIColor(bmi))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 2)
                        .offset(x: animatedBMIOffset)
                }
                .frame(height: 16)
                
                HStack {
                    Text("Underweight")
                        .font(.system(size: 8))
                    
                    Spacer()
                    
                    Text("Normal")
                        .font(.system(size: 8))
                    
                    Spacer()
                    
                    Text("Overweight")
                        .font(.system(size: 8))
                    
                    Spacer()
                    
                    Text("Obese")
                        .font(.system(size: 8))
                }
                .foregroundColor(.secondary)
            }
            .onAppear {
                animatedBMIOffset = 0
                
                withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                    animatedBMIOffset = helper.calculateBMIOffset(bmi: bmi, viewWidth: geometry.size.width)
                }
            }
            .onChange(of: geometry.size) { newSize in
                animatedBMIOffset = helper.calculateBMIOffset(bmi: bmi, viewWidth: newSize.width)
            }
        }
    }
}
