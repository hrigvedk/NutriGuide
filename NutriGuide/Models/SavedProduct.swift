//
//  SavedProduct.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/14/25.
//
import Foundation
import FirebaseFirestore

struct SavedProduct: Identifiable, Codable {
    var id: String
    var brand: String
    var name: String
    var barcode: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var suitabilityStatus: String
    var analysis: String
    var novaGroup: Int
    var savedDate: Date
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "brand": brand,
            "name": name,
            "barcode": barcode,
            "calories": calories,
            "protein": protein,
            "carbs": carbs,
            "fat": fat,
            "suitabilityStatus": suitabilityStatus,
            "analysis": analysis,
            "novaGroup": novaGroup,
            "savedDate": Timestamp(date: savedDate)
        ]
    }
    
    init(from productDetails: ProductDetails, barcode: String) {
        self.id = UUID().uuidString
        self.brand = productDetails.brand
        self.name = productDetails.name
        self.barcode = barcode
        self.calories = productDetails.nutritionData.macronutrients.calories
        self.protein = productDetails.nutritionData.macronutrients.protein
        self.carbs = productDetails.nutritionData.macronutrients.carbohydrates
        self.fat = productDetails.nutritionData.macronutrients.fat
        self.suitabilityStatus = productDetails.suitabilityStatus.rawValue
        self.analysis = productDetails.analysis
        self.novaGroup = productDetails.nutritionData.additionalMetrics.novaGroup
        self.savedDate = Date()
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let id = data["id"] as? String,
              let brand = data["brand"] as? String,
              let name = data["name"] as? String,
              let barcode = data["barcode"] as? String,
              let calories = data["calories"] as? Double,
              let protein = data["protein"] as? Double,
              let carbs = data["carbs"] as? Double,
              let fat = data["fat"] as? Double,
              let suitabilityStatus = data["suitabilityStatus"] as? String,
              let analysis = data["analysis"] as? String,
              let novaGroup = data["novaGroup"] as? Int,
              let savedDateTimestamp = data["savedDate"] as? Timestamp else {
            return nil
        }
        
        self.id = id
        self.brand = brand
        self.name = name
        self.barcode = barcode
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.suitabilityStatus = suitabilityStatus
        self.analysis = analysis
        self.novaGroup = novaGroup
        self.savedDate = savedDateTimestamp.dateValue()
    }
}
