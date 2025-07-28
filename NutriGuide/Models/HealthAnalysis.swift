//
//  HealthAnalysis.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/11/25.
//
import Foundation

struct HealthAnalysis {
    let score: Double
    let scoreDescription: String
    let scoreDetail: String
    let conditions: [HealthCondition]
    let recommendations: [NutritionRecommendation]
}
