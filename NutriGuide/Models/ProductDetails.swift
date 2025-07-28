//
//  ProductDetails.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/24/25.
//
import Foundation

struct ProductDetails: Codable {
    let brand: String
    let name: String
    let type: String
    let ingredients: String
    let nutritionData: NutritionData
    let analysis: String
    
    var suitabilityStatus: SuitabilityStatus {
        if analysis.lowercased().contains("not suitable") {
            return .notSuitable
        } else if analysis.lowercased().contains("likely suitable") {
            return .likelySuitable
        } else if analysis.lowercased().contains("suitable") {
            return .suitable
        } else if analysis.lowercased().contains("caution") {
            return .caution
        } else {
            return .unknown
        }
    }
}
