//
//  ProductAnalysis.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/9/25.
//
import Foundation
import UIKit

struct ProductAnalysisRequest: Codable {
    let barcode: String
    let height: Double
    let weight: Double
    let age: Int
    let bmi: Double
    let gender: String
    let activityLevel: String
    let allergens: [String]
    let otherAllergens: String
    let foodIntolerances: [String]
    let healthConditions: [String]
    let dietaryPreferences: [String]
    let otherDietaryPreferences: String
    let medications: MedicationInfo
    
    struct MedicationInfo: Codable {
        let name: String
        let dosage: String
        let frequency: String
    }
}

enum SuitabilityStatus: String {
    case suitable = "Suitable"
    case likelySuitable = "Likely Suitable"
    case caution = "Use with Caution"
    case notSuitable = "Not Suitable"
    case unknown = "Unknown Status"
    
    var color: UIColor {
        switch self {
        case .suitable:
            return .green
        case .likelySuitable:
            return .yellow
        case .caution:
            return .orange
        case .notSuitable:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    var systemImageName: String {
        switch self {
        case .suitable:
            return "checkmark.circle.fill"
        case .likelySuitable:
            return "checkmark.circle"
        case .caution:
            return "exclamationmark.triangle.fill"
        case .notSuitable:
            return "xmark.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
}
