//
//  HealthReportView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/6/25.
//
import SwiftUI
import Firebase
import WatchConnectivity

struct HealthReportView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var userData: [String: Any]? = nil
    @State private var isLoading = true
    @State private var error: String? = nil
    @StateObject private var emergencyCardModel = EmergencyCardModel()
    @State private var showShareSheet = false
    @State private var showWatchAlert = false
    @State private var healthAnalysis: HealthAnalysis? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if isLoading {
                    ProgressView("Loading your health data...")
                        .padding(.top, 100)
                } else if let error = error {
                    errorView(error)
                } else if userData != nil {
                    reportHeader
                    
                    healthScoreCard
                    
                    healthConditionsCard
                    
                    recommendationsCard
                    
                    emergencyCardSection
                }
            }
            .padding()
        }
        .navigationTitle("Health Report")
        .onAppear {
            fetchUserData()
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = emergencyCardModel.cardImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Apple Watch Integration", isPresented: $showWatchAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(emergencyCardModel.syncStatus.description)
        }
    }
    
    private var reportHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            
                Text("Generated on \(formatDate(Date()))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            
            Text("This report is based on your profile data and health conditions")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    private var healthScoreCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text("Your Health Score")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 25) {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 25) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(healthAnalysis?.score ?? 75) / 100)
                                .stroke(scoreColor, lineWidth: 12)
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 0) {
                                Text("\(Int(healthAnalysis?.score ?? 75))")
                                    .font(.system(size: 32, weight: .bold))
                                
                                Text("/100")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text(healthAnalysis?.scoreDescription ?? "Your health score is good")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                            
                            Text(healthAnalysis?.scoreDetail ?? "Based on your BMI, reported health conditions, and dietary preferences.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: 280)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var healthConditionsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "stethoscope")
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                
                Text("Health Considerations")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let conditions = healthAnalysis?.conditions, !conditions.isEmpty {
                ForEach(conditions, id: \.name) { condition in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(condition.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(condition.severity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(severityColor(condition.severity))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Text(condition.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !condition.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommendations:")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                ForEach(condition.recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.green)
                                            .padding(.top, 3)
                                        
                                        Text(recommendation)
                                            .font(.caption)
                                            .foregroundColor(.primary.opacity(0.8))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.vertical, 4)
                }
            } else {
                Text("No specific health conditions noted")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                Text("Nutritional Recommendations")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let recommendations = healthAnalysis?.recommendations, !recommendations.isEmpty {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendation.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(recommendation.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if index < recommendations.count - 1 {
                        Divider()
                    }
                }
            } else {
                Text("No personalized recommendations available")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var emergencyCardSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text("Emergency Health Card")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text("Generate a digital emergency card with your essential health information that can be saved to your phone and synced with your Apple Watch.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
            
            VStack(spacing: 16) {
                Button(action: {
                    generateEmergencyCard()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text(emergencyCardModel.isGenerating ? "Generating..." : "Generate Emergency Card")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(emergencyCardModel.isGenerating)
                
                Button(action: {
                    syncWithAppleWatch()
                }) {
                    HStack {
                        Image(systemName: "applewatch")
                        Text("Sync with Apple Watch")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func errorView(_ errorMessage: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()
            
            Text("Error loading data")
                .font(.headline)
            
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Try Again") {
                fetchUserData()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.top, 50)
    }
    
    private var scoreColor: Color {
        let score = healthAnalysis?.score ?? 75
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "high": return .red
        case "moderate": return .orange
        case "low": return .green
        default: return .blue
        }
    }
    
    private func fetchUserData() {
        guard let userId = authService.user?.uid else {
            error = "User not found. Please sign in again."
            isLoading = false
            return
        }
        
        isLoading = true
        error = nil
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = "Failed to load data: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let document = document, document.exists else {
                    self.error = "Profile data not found. Please complete onboarding."
                    self.isLoading = false
                    return
                }
                
                self.userData = document.data()
                self.analyzeHealthData(userData: self.userData!)
                self.isLoading = false
            }
        }
    }
    
    private func analyzeHealthData(userData: [String: Any]) {
        let healthConditions = userData["healthConditions"] as? [String] ?? []
        let allergens = userData["allergens"] as? [String] ?? []
        let dietaryPreferences = userData["dietaryPreferences"] as? [String] ?? []
        let bmi = userData["bmi"] as? Double ?? 25.0
        

        var score = 85.0
        if !healthConditions.isEmpty {
            score -= Double(healthConditions.count * 5)
        }
        
        if bmi < 18.5 || bmi > 30 {
            score -= 10
        } else if bmi < 18.9 || bmi > 25 {
            score -= 5
        }
        
        var conditions: [HealthCondition] = []
        
        for condition in healthConditions {
            let healthCondition = createHealthConditionAnalysis(condition)
            conditions.append(healthCondition)
        }
        
        var recommendations: [NutritionRecommendation] = []
        
        recommendations.append(NutritionRecommendation(
            title: "Maintain proper hydration",
            description: "Drink at least 8 glasses of water daily to support metabolism and organ function."
        ))
        
        recommendations.append(NutritionRecommendation(
            title: "Include more whole foods",
            description: "Focus on fruits, vegetables, lean proteins, and whole grains while minimizing processed foods."
        ))
        
        if healthConditions.contains("Diabetes") {
            recommendations.append(NutritionRecommendation(
                title: "Monitor carbohydrate intake",
                description: "Keep track of carbs and focus on complex carbohydrates with low glycemic index."
            ))
        }
        
        if healthConditions.contains("Hypertension") {
            recommendations.append(NutritionRecommendation(
                title: "Reduce sodium intake",
                description: "Limit salt consumption to less than 2,300mg per day and increase potassium-rich foods."
            ))
        }
        
        let scoreDescription: String
        if score >= 80 {
            scoreDescription = "Your health score is excellent"
        } else if score >= 60 {
            scoreDescription = "Your health score is good"
        } else {
            scoreDescription = "Your health score needs attention"
        }
        
        var scoreDetailParts: [String] = []
        
        if !healthConditions.isEmpty {
            scoreDetailParts.append("your health conditions")
        }
        
        if !allergens.isEmpty {
            scoreDetailParts.append("allergies")
        }
        
        if bmi < 18.5 || bmi > 25 {
            scoreDetailParts.append("BMI")
        }
        
        let scoreDetail: String
        if scoreDetailParts.isEmpty {
            scoreDetail = "Based on your overall profile data."
        } else {
            scoreDetail = "Based on " + scoreDetailParts.joined(separator: ", ") + "."
        }
        
        self.healthAnalysis = HealthAnalysis(
            score: score,
            scoreDescription: scoreDescription,
            scoreDetail: scoreDetail,
            conditions: conditions,
            recommendations: recommendations
        )
    }
    
    private func createHealthConditionAnalysis(_ condition: String) -> HealthCondition {
        switch condition {
        case "Diabetes":
            return HealthCondition(
                name: "Type 2 Diabetes",
                severity: "Moderate",
                description: "A chronic condition affecting how your body metabolizes sugar. Regular monitoring of blood glucose levels is essential.",
                recommendations: [
                    "Monitor carbohydrate intake carefully",
                    "Eat smaller, regular meals throughout the day",
                    "Focus on foods with low glycemic index",
                    "Limit foods high in added sugars"
                ]
            )
        case "Hypertension":
            return HealthCondition(
                name: "Hypertension",
                severity: "Moderate",
                description: "High blood pressure increases risk of heart disease and stroke. Dietary and lifestyle modifications are crucial.",
                recommendations: [
                    "Reduce sodium intake to less than 2,300mg daily",
                    "Consume potassium-rich foods like bananas and spinach",
                    "Limit alcohol consumption",
                    "Incorporate the DASH diet principles"
                ]
            )
        case "Lactose Intolerance":
            return HealthCondition(
                name: "Lactose Intolerance",
                severity: "Low",
                description: "An inability to digest lactose, the sugar in dairy products, causing digestive discomfort.",
                recommendations: [
                    "Use lactose-free dairy products",
                    "Try plant-based milk alternatives",
                    "Consider lactase enzyme supplements before consuming dairy",
                    "Check food labels for hidden lactose ingredients"
                ]
            )
        case "Celiac Disease":
            return HealthCondition(
                name: "Celiac Disease",
                severity: "High",
                description: "An autoimmune disorder where ingestion of gluten leads to damage of the small intestine.",
                recommendations: [
                    "Strictly avoid all forms of gluten",
                    "Focus on naturally gluten-free foods",
                    "Be cautious of cross-contamination",
                    "Look for certified gluten-free products"
                ]
            )
        default:
            return HealthCondition(
                name: condition,
                severity: "Moderate",
                description: "This condition requires dietary and lifestyle considerations for optimal health management.",
                recommendations: [
                    "Consult with healthcare providers for specific advice",
                    "Monitor symptoms and track food intake",
                    "Stay consistent with prescribed medications"
                ]
            )
        }
    }
    
    private func generateEmergencyCard() {
        guard let userData = userData else { return }
        
        emergencyCardModel.isGenerating = true
        
        let userName = authService.user?.displayName ?? "User"
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.emergencyCardModel.generateEmergencyCard(userData: userData, userName: userName)
            
            DispatchQueue.main.async {
                self.emergencyCardModel.cardImage = image
                self.emergencyCardModel.isGenerating = false
                self.showShareSheet = true
            }
        }
    }
    
    private func syncWithAppleWatch() {
        guard let userData = userData else { return }
        
        let userName = authService.user?.displayName ?? "User"
        
        emergencyCardModel.syncWithAppleWatch(userData: userData, userName: userName)
        
        showWatchAlert = true
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
