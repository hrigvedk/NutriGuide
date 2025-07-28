//
//  HealthAnalysis.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/11/25.
//
import Foundation
import SwiftUI
import AppIntents

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
