//
//  UserProfileData.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import Foundation

struct UserProfileData {
    var height: Double = 0
    var weight: Double = 0
    var age: Int = 0
    var gender: String = ""
    var activityLevel: String = ""
    var allergens: [String] = []
    var otherAllergens: String = ""
    var foodIntolerances: [String] = []
    var healthConditions: [String] = []
    var otherHealthConditions: String = ""
    var dietaryPreferences: [String] = []
    var otherDietaryPreferences: String = ""
    var medications: [Medication] = []
    var emergencyContact: EmergencyContact = EmergencyContact()

}
