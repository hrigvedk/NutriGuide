//
//  NutritionData.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/24/25.
//
import Foundation

struct NutritionData: Codable {
    let macronutrients: Macronutrients
    let micronutrients: Micronutrients
    let additionalMetrics: AdditionalMetrics
}
