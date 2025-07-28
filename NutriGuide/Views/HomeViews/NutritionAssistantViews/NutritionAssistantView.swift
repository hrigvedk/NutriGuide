//
//  NutritionAssistantView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct NutritionAssistantView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var viewModel = NutritionAssistantModel()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Nutrition Assistant")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.addHelpMessage()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .bottom
            )
            
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                                .padding(.horizontal)
                                .id(message.id)
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessageId = viewModel.messages.last?.id {
                        withAnimation {
                            scrollView.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Ask about nutrition...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.leading)
                    .focused($isTextFieldFocused)
                
                Button(action: {
                    viewModel.sendMessage(text: messageText)
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                        .padding(.trailing)
                        .opacity(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading ? 0.5 : 1.0)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .top
            )
        }
        .onAppear {
            if let userId = authService.user?.uid {
                viewModel.fetchUserData(userId: userId)
            }
        }
        .alert(isPresented: $viewModel.showNoProfileAlert) {
            Alert(
                title: Text("Profile Not Complete"),
                message: Text("Please complete your profile with dietary information for personalized nutrition advice."),
                primaryButton: .default(Text("Go to Profile")) {
                },
                secondaryButton: .cancel()
            )
        }
        .navigationTitle("Nutrition Assistant")
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
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
        
        return requestBody
    }
    
    private func sendRequest(requestBody: [String: Any]) async throws -> String {
        let apiURL = URL(string: "https://9e4d9l54il.execute-api.us-east-1.amazonaws.com/getRestaurantSuggestion")!
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "NutritionAssistantAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        if let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseText = responseDict["response"] as? String {
            return responseText
        } else {
            throw NSError(domain: "NutritionAssistantAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


