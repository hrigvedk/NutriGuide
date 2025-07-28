//
//  ScannerOverlayView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//

import SwiftUICore
import Swift

struct ScannerOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            let boxWidth = min(geometry.size.width * 0.8, 300)
            let boxHeight = boxWidth * 0.6
            
            ZStack {
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                Rectangle()
                                    .frame(width: boxWidth, height: boxHeight)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.5)
                                    .blendMode(.destinationOut)
                            )
                    )
                
                Rectangle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: boxWidth, height: boxHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.5)
                
                ForEach(0..<4) { index in
                    ScanCorner(index: index)
                        .stroke(Color.blue, lineWidth: 5)
                        .frame(width: 30, height: 30)
                        .position(
                            x: index % 2 == 0
                                ? geometry.size.width / 2 - boxWidth / 2 + 15
                                : geometry.size.width / 2 + boxWidth / 2 - 15,
                            y: index < 2
                                ? geometry.size.height / 2.5 - boxHeight / 2 + 15
                                : geometry.size.height / 2.5 + boxHeight / 2 - 15
                        )
                }
                
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: boxWidth - 10, height: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.5)
                    .modifier(ScanningAnimation(boxHeight: boxHeight))
            }
        }
    }
}
