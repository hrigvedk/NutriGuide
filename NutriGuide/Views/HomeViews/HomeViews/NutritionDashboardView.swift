//
//  NutritionDashboardView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
import SwiftUICore
import SwiftUI
import Firebase

struct NutritionDashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var userData: [String: Any]? = nil
    @State private var isLoading = true
    @State private var error: String? = nil
    @State private var helper = Helpers()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading your nutrition data...")
                        .padding(.top, 100)
                } else if let error = error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Error loading data")
                            .font(.headline)
                        
                        Text(error)
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
                } else if userData != nil {
                    welcomeHeader
                    
                    bmiCard
                    
                    macronutrientsCard
                    
                    calorieCard
                    
                    healthInsightsCard
                }
            }
            .padding()
        }
        .navigationTitle("Your Nutrition")
        .navigationBarItems(trailing: NavigationLink(destination: ProfileView()) {
            Label("Profile", systemImage: "person.crop.circle").labelStyle(.iconOnly)
        })
        .onAppear {
            fetchUserData()
        }
        .refreshable {
            fetchUserData()
        }
    }
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hello, \(getUserName())")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Here's your personalized nutrition overview")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    private var bmiCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "figure.stand")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text("BMI Overview")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let bmi = userData?["bmi"] as? Double {
                HStack(alignment: .top, spacing: 10) {
                    VStack {
                        Text(String(format: "%.1f", bmi))
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(helper.getBMIColor(bmi))
                        
                        Text(helper.getBMICategory(bmi))
                            .font(.subheadline)
                            .foregroundColor(helper.getBMIColor(bmi))
                    }
                    .frame(width: 120)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        BMIScaleView(bmi: bmi)
                        
                        Spacer()
                        
                        Text(helper.getBMIDescription(bmi))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(height: 70)
//                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                Text("BMI data not available")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func getUserName() -> String {
        if let displayName = authService.user?.displayName, !displayName.isEmpty {
            return displayName
        } else if authService.user?.isAnonymous == true {
            return "Guest"
        } else {
            return "there"
        }
    }
    
    private var macronutrientsCard: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                    
                    Text("Your Daily Macronutrients")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                if let protein = userData?["dailyProtein"] as? Double,
                   let carbs = userData?["dailyCarbs"] as? Double,
                   let fat = userData?["dailyFat"] as? Double {
                    
                    VStack {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                                .frame(width: 180, height: 180)
                            
                            MacronutrientPieChart(
                                protein: protein,
                                carbs: carbs,
                                fat: fat
                            )
                            .frame(width: 180, height: 180)
                            
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 120, height: 120)
                            
                            VStack(spacing: 2) {
                                Text("\(Int(protein + carbs + fat))")
                                    .font(.system(size: 28, weight: .bold))
                                
                                Text("total g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            MacronutrientLegendItem(color: .blue, name: "Protein", value: Int(protein), percentage: 30)
                            MacronutrientLegendItem(color: .orange, name: "Carbs", value: Int(carbs), percentage: 40)
                            MacronutrientLegendItem(color: .purple, name: "Fat", value: Int(fat), percentage: 30)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Macronutrient data not available")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    
    private var calorieCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text("Daily Energy Needs")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let calories = userData?["dailyCalories"] as? Double,
               let activityLevel = userData?["activityLevel"] as? String {
                
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        Text("\(Int(calories))")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("calories")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 120)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Based on your profile:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        bulletPoint(text: "Activity: \(activityLevel)")
                        
                        if let gender = userData?["gender"] as? String,
                           let age = userData?["age"] as? Int,
                           let weight = userData?["weight"] as? Double {
                            bulletPoint(text: "\(gender.capitalized), \(age) years")
                            bulletPoint(text: "\(Int(weight)) kg")
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To maintain weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(calories)) calories/day")
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("To lose weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(calories * 0.8)) calories/day")
                            .fontWeight(.medium)
                    }
                }
            } else {
                Text("Calorie data not available")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var healthInsightsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text("Health Considerations")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            if let healthConditions = userData?["healthConditions"] as? [String], !healthConditions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on your health conditions:")
                        .font(.subheadline)
                    
                    ForEach(healthConditions.prefix(3), id: \.self) { condition in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 4)
                            
                            Text(helper.getHealthConditionAdvice(condition))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else if let allergens = userData?["allergens"] as? [String], !allergens.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Food allergies to monitor:")
                        .font(.subheadline)
                    
                    ForEach(allergens.prefix(3), id: \.self) { allergen in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                                .padding(.top, 4)
                            
                            Text("Avoid foods containing \(allergen.lowercased())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("No specific health considerations found")
                    .foregroundColor(.secondary)
            }
            
            NavigationLink(destination: HealthReportView()) {
                Text("View Detailed Health Report")
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }

        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func macronutrientBar(value: Double, total: Double, name: String, color: Color, unit: String) -> some View {
        let percentage = total > 0 ? value / total : 0
        
        return VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 40, height: 150)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Rectangle()
                    .frame(width: 40, height: CGFloat(percentage) * 150)
                    .foregroundColor(color)
                    .cornerRadius(8)
            }
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("\(Int(value))\(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    struct MacronutrientPieChart: View {
        let protein: Double
        let carbs: Double
        let fat: Double
        
        @State private var proteinTrimEnd: CGFloat = 0
        @State private var carbsTrimEnd: CGFloat = 0
        @State private var fatTrimEnd: CGFloat = 0
        
        private var total: Double {
            protein + carbs + fat
        }
        
        private var proteinProportion: CGFloat {
            total > 0 ? CGFloat(protein / total) : 0
        }
        
        private var carbsProportion: CGFloat {
            total > 0 ? CGFloat(carbs / total) : 0
        }
        
        private var fatProportion: CGFloat {
            total > 0 ? CGFloat(fat / total) : 0
        }
        
        var body: some View {
            ZStack {
                Circle()
                    .trim(from: 0, to: proteinTrimEnd)
                    .stroke(Color.blue, lineWidth: 30)
                    .rotationEffect(.degrees(-90))
                

                Circle()
                    .trim(from: 0, to: carbsTrimEnd)
                    .stroke(Color.orange, lineWidth: 30)
                    .rotationEffect(.degrees(-90.0 + 360.0 * proteinProportion))
                
                Circle()
                    .trim(from: 0, to: fatTrimEnd)
                    .stroke(Color.purple, lineWidth: 30)
                    .rotationEffect(.degrees(-90 + 360.0 * (proteinProportion + carbsProportion)))
                
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    proteinTrimEnd = proteinProportion
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        carbsTrimEnd = carbsProportion
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        fatTrimEnd = fatProportion
                    }
                }
            }
        }
    }

    struct MacronutrientLegendItem: View {
        var color: Color
        var name: String
        var value: Int
        var percentage: Int
        
        var body: some View {
            VStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                HStack(spacing: 2) {
                    Text("\(value)g")
                        .font(.caption)
                    
                    Text("(\(percentage)%)")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func bulletPoint(text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.subheadline)
                .foregroundColor(.orange)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Data Fetching
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
                self.isLoading = false
                
                if let error = error {
                    self.error = "Failed to load data: \(error.localizedDescription)"
                    return
                }
                
                guard let document = document, document.exists else {
                    self.error = "Profile data not found. Please complete onboarding."
                    return
                }
                
                self.userData = document.data()
            }
        }
    }
}
