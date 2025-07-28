//
//  Medication.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/7/25.
//
import Foundation

struct Medication: Identifiable {
    var id = UUID()
    var name: String = ""
    var dosage: String = ""
    var frequency: String = ""
    var notes: String = ""
}
