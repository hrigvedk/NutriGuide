//
//  helperfunctions.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import Foundation
import SwiftUICore

class Helpers {
    func calculateBMI(height: Double, weight: Double) -> Double {
        let heightInMeters = height / 100
        
        let bmi = weight / (heightInMeters * heightInMeters)
        
        return round(bmi * 10) / 10
    }

    func calculateNutritionalRequirements(
        weight: Double,
        height: Double,
        age: Int,
        gender: String,
        activityLevel: String
    ) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        
        var bmr: Double
        
        if gender.lowercased() == "male" {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        
        var activityMultiplier: Double
        switch activityLevel.lowercased() {
        case "sedentary":
            activityMultiplier = 1.2
        case "lightly active":
            activityMultiplier = 1.375
        case "moderately active":
            activityMultiplier = 1.55
        case "very active":
            activityMultiplier = 1.725
        case "extra active":
            activityMultiplier = 1.9
        default:
            activityMultiplier = 1.2
        }
        
        let dailyCalories = bmr * activityMultiplier
        
        let protein = (dailyCalories * 0.3) / 4
        let carbs = (dailyCalories * 0.5) / 4
        let fat = (dailyCalories * 0.2) / 9
        
        return (
            calories: round(dailyCalories),
            protein: round(protein),
            carbs: round(carbs),
            fat: round(fat)
        )
    }
    
    func getBMIColor(_ bmi: Double) -> Color {
        if bmi < 18.5 {
            return .blue
        } else if bmi < 25.0 {
            return .green
        } else if bmi < 30.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    func calculateBMIOffset(bmi: Double, viewWidth: CGFloat) -> CGFloat {
        let minBMI: CGFloat = 15
        let normalBMIStart: CGFloat = 18.5
        let overweightBMIStart: CGFloat = 25
        let obeseBMIStart: CGFloat = 30
        let maxBMI: CGFloat = 35
        
        let segmentWidth = viewWidth / 4
        
        let clampedBMI = max(minBMI, min(CGFloat(bmi), maxBMI))
        
        if clampedBMI < normalBMIStart {
            let rangeWidth = normalBMIStart - minBMI
            let progress = (clampedBMI - minBMI) / rangeWidth
            return progress * segmentWidth - 10
        }
        else if clampedBMI < overweightBMIStart {
            let rangeWidth = overweightBMIStart - normalBMIStart
            let progress = (clampedBMI - normalBMIStart) / rangeWidth
            return segmentWidth + (progress * segmentWidth) - 10
        }
        else if clampedBMI < obeseBMIStart {
            let rangeWidth = obeseBMIStart - overweightBMIStart
            let progress = (clampedBMI - overweightBMIStart) / rangeWidth
            return (2 * segmentWidth) + (progress * segmentWidth) - 10
        }
        else {
            let rangeWidth = maxBMI - obeseBMIStart
            let progress = (clampedBMI - obeseBMIStart) / rangeWidth
            return (3 * segmentWidth) + (progress * segmentWidth) - 10
        }
    }
    
    func getBMIDescription(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "You may need to gain some weight. Consider focusing on nutrient-dense foods."
        case 18.5..<25:
            return "Your weight is in the healthy range. Maintain your current habits."
        case 25..<30:
            return "You may benefit from losing some weight through diet and exercise."
        default:
            return "Your BMI indicates obesity, which increases health risks. Consider consulting a healthcare provider."
        }
    }
    
    func getHealthConditionAdvice(_ condition: String) -> String {
        switch condition.lowercased() {
        case "diabetes":
            return "Monitor carbohydrate intake and focus on foods with a low glycemic index."
        case "hypertension":
            return "Limit sodium intake to less than 2,300mg per day and increase potassium-rich foods."
        case "heart disease":
            return "Focus on heart-healthy foods like whole grains, lean proteins, and healthy fats."
        case "kidney disease":
            return "Monitor protein, phosphorus, sodium, and potassium intake based on your stage."
        case "irritable bowel syndrome":
            return "Consider a low-FODMAP diet and identify personal trigger foods."
        case "celiac disease":
            return "Strictly avoid all foods containing gluten, including many processed foods."
        case "gerd/acid reflux":
            return "Avoid acidic foods, spicy foods, and eat smaller, more frequent meals."
        default:
            return "Follow dietary recommendations specific to your \(condition.lowercased()) condition."
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
}
