//
//  ProductAnalysisService.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/9/25.
//
import Foundation
import Firebase
import FirebaseFirestore

class ProductAnalysisService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var productDetails: ProductDetails? = nil
    
    private let apiUrl = "https://9e4d9l54il.execute-api.us-east-1.amazonaws.com/getDetailsFromBarcode"
    
    func fetchProductDetails(for barcode: String, userData: [String: Any]) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
            self.productDetails = nil
        }
        
        do {
            let requestBody = try constructRequestBody(barcode: barcode, userData: userData)
            let requestData = try JSONEncoder().encode(requestBody)
            
            print("🔍 API Request for barcode: \(barcode)")
            
            var request = URLRequest(url: URL(string: apiUrl)!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            if let requestString = String(data: requestData, encoding: .utf8) {
                print("📤 Request payload: \(requestString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 API Response: \(responseString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    var errorMessage = "Server returned status code: \(httpResponse.statusCode)"
                    if let responseString = String(data: data, encoding: .utf8) {
                        errorMessage += " - Response: \(responseString)"
                    }
                    throw NSError(domain: "API Error", code: httpResponse.statusCode,
                                 userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ProductAnalysisResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.productDetails = decodedResponse.details
                    self.isLoading = false
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 Response that failed to decode: \(responseString)")
                }
                throw NSError(domain: "API Error", code: -1,
                             userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response: \(error.localizedDescription)"])
            }
            
        } catch {
            DispatchQueue.main.async {
                self.error = "Product not found. Please try again later."
                self.isLoading = false
            }
            print("❌ API Error: \(error.localizedDescription)")
        }
    }
    
    private func constructRequestBody(barcode: String, userData: [String: Any]) throws -> ProductAnalysisRequest {
        guard let height = userData["height"] as? Double,
              let weight = userData["weight"] as? Double,
              let age = userData["age"] as? Int,
              let bmi = userData["bmi"] as? Double,
              let gender = userData["gender"] as? String,
              let activityLevel = userData["activityLevel"] as? String else {
            throw NSError(domain: "Request Error", code: 0,
                         userInfo: [NSLocalizedDescriptionKey: "Missing required basic user data fields"])
        }
        
        let allergens = userData["allergens"] as? [String] ?? []
        let foodIntolerances = userData["foodIntolerances"] as? [String] ?? []
        let healthConditions = userData["healthConditions"] as? [String] ?? []
        let dietaryPreferences = userData["dietaryPreferences"] as? [String] ?? []
        
        let otherAllergens = userData["otherAllergens"] as? String ?? ""
        let otherDietaryPreferences = userData["otherDietaryPreferences"] as? String ?? ""
        
        var medicationInfo = ProductAnalysisRequest.MedicationInfo(name: "", dosage: "", frequency: "")
        
        if let medications = userData["medications"] as? [[String: Any]], let firstMed = medications.first {
            medicationInfo = ProductAnalysisRequest.MedicationInfo(
                name: firstMed["name"] as? String ?? "",
                dosage: firstMed["dosage"] as? String ?? "",
                frequency: firstMed["frequency"] as? String ?? ""
            )
        } else if let medications = userData["medications"] as? [String: Any] {
            medicationInfo = ProductAnalysisRequest.MedicationInfo(
                name: medications["name"] as? String ?? "",
                dosage: medications["dosage"] as? String ?? "",
                frequency: medications["frequency"] as? String ?? ""
            )
        }
        
        print("✅ Successfully constructed request body")
        
        return ProductAnalysisRequest(
            barcode: barcode,
            height: height,
            weight: weight,
            age: age,
            bmi: bmi,
            gender: gender,
            activityLevel: activityLevel,
            allergens: allergens,
            otherAllergens: otherAllergens,
            foodIntolerances: foodIntolerances,
            healthConditions: healthConditions,
            dietaryPreferences: dietaryPreferences,
            otherDietaryPreferences: otherDietaryPreferences,
            medications: medicationInfo
        )
    }
}
