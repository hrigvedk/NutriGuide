//
//  ScanCorner.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI

struct ScanCorner: Shape {
    var index: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        switch index {
        case 0:
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 10, y: 0))
            
        case 1:
            path.move(to: CGPoint(x: width - 10, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: 10))
            
        case 2:
            path.move(to: CGPoint(x: 0, y: height - 10))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 10, y: height))
            
        case 3: 
            path.move(to: CGPoint(x: width - 10, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: height - 10))
            
        default:
            break
        }
        
        return path
    }
}
