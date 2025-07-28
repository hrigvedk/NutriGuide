//
//  NutritionAssistantModel.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/23/25.
//
import Foundation
import Combine
import Firebase
import FirebaseFirestore

class NutritionAssistantModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var userData: [String: Any]? = nil
    @Published var showNoProfileAlert = false
    
    private let apiURL = "https://9e4d9l54il.execute-api.us-east-1.amazonaws.com/getRestaurantSuggestion"
    
    init() {
        if messages.isEmpty {
            messages.append(ChatMessage(
                id: UUID().uuidString,
                text: "Hello! I'm your nutrition assistant. I can answer questions about food and nutrition based on your dietary profile. How can I help you today?",
                isFromUser: false
            ))
        }
    }
    
    func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists, let data = document.data() {
                self.userData = data
                print("User data fetched successfully")
            } else {
                print("User data not found or error: \(error?.localizedDescription ?? "Unknown error")")
                self.userData = nil
            }
        }
    }
    
    func sendMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(id: UUID().uuidString, text: text, isFromUser: true)
        messages.append(userMessage)
        
        guard let userData = userData else {
            showNoProfileAlert = true
            messages.append(ChatMessage(
                id: UUID().uuidString,
                text: "I need more information about your dietary needs to provide personalized advice. Please complete your profile first.",
                isFromUser: false
            ))
            return
        }
        
        isLoading = true
        
        let requestBody = createRequestBody(from: userData, question: text)
        
        Task {
            do {
                let response = try await sendRequest(requestBody: requestBody)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    self.messages.append(ChatMessage(
                        id: UUID().uuidString,
                        text: response,
                        isFromUser: false
                    ))
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    self.messages.append(ChatMessage(
                        id: UUID().uuidString,
                        text: "Sorry, I encountered an error while processing your question. Please try again later.",
                        isFromUser: false
                    ))
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createRequestBody(from userData: [String: Any], question: String) -> [String: Any] {
        var requestBody: [String: Any] = [
            "question": question
        ]
        
        if let allergens = userData["allergens"] as? [String] {
            requestBody["allergens"] = allergens
        } else {
            requestBody["allergens"] = []
        }
        
        if let otherAllergens = userData["otherAllergens"] as? String {
            requestBody["otherAllergens"] = otherAllergens
        } else {
            requestBody["otherAllergens"] = ""
        }
        
        if let foodIntolerances = userData["foodIntolerances"] as? [String] {
            requestBody["foodIntolerances"] = foodIntolerances
        } else {
            requestBody["foodIntolerances"] = []
        }
        
        if let healthConditions = userData["healthConditions"] as? [String] {
            requestBody["healthConditions"] = healthConditions
        } else {
            requestBody["healthConditions"] = []
        }
        
        if let dietaryPreferences = userData["dietaryPreferences"] as? [String] {
            requestBody["dietaryPreferences"] = dietaryPreferences
        } else {
            requestBody["dietaryPreferences"] = []
        }
        
        if let otherDietaryPreferences = userData["otherDietaryPreferences"] as? String {
            requestBody["otherDietaryPreferences"] = otherDietaryPreferences
        } else {
            requestBody["otherDietaryPreferences"] = ""
        }
        
        var medicationInfo: [String: String] = [
            "name": "",
            "dosage": "",
            "frequency": ""
        ]
        
        if let medications = userData["medications"] as? [[String: Any]], let firstMed = medications.first {
            medicationInfo = [
                "name": firstMed["name"] as? String ?? "",
                "dosage": firstMed["dosage"] as? String ?? "",
                "frequency": firstMed["frequency"] as? String ?? ""
            ]
        }
        
        requestBody["medications"] = medicationInfo
        
        print("Request body: \(requestBody)")
        return requestBody
    }
    
    private func sendRequest(requestBody: [String: Any]) async throws -> String {
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        if let requestString = String(data: jsonData, encoding: .utf8) {
            print("Request JSON: \(requestString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response string: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("Error response: \(responseString)")
            }
            throw NSError(domain: "NutritionAssistantAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server error: \((response as? HTTPURLResponse)?.statusCode ?? -1)"])
        }
        
        if let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let responseText = responseDict["response"] as? String {
                return responseText
            }
            else if let replyText = responseDict["reply"] as? String {
                return replyText
            }
            else {
                let prettyData = try? JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted)
                if let prettyString = prettyData.flatMap({ String(data: $0, encoding: .utf8) }) {
                    print("Unknown response format: \(prettyString)")
                }
                
                throw NSError(domain: "NutritionAssistantAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }
        } else {
            throw NSError(domain: "NutritionAssistantAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
    }
    
    func addHelpMessage() {
        let helpMessage = ChatMessage(
            id: UUID().uuidString,
            text: "You can ask me questions about specific foods, restaurants, recipes, or general nutrition advice based on your dietary profile. For example:\n\n• Can I eat a Spicy Chicken Sandwich from Chick-fil-A?\n• Is Greek yogurt suitable for someone with lactose intolerance?\n• What should I avoid with hypertension?\n• Recommend me a breakfast option",
            isFromUser: false
        )
        messages.append(helpMessage)
    }
}
