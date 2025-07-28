//
//  ProductAnalysisResponse.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/24/25.
//
import Foundation

struct ProductAnalysisResponse: Codable {
    let success: Bool
    let details: ProductDetails
}
