//
//  ProductAnalysisView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/10/25.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct ProductAnalysisView: View {
    @EnvironmentObject var authService: AuthenticationService
    let barcode: String
    @State private var userData: [String: Any]? = nil
    @StateObject private var analysisService = ProductAnalysisService()
    @StateObject private var foodDiaryService = FoodDiaryService()
    @Environment(\.dismiss) private var dismiss
    @State private var showingNovaGroupInfo = false
    @State private var showingNutritionScoreInfo = false
    @State private var showSavingIndicator = false
    @State private var isSaved = false
    @State private var showSaveConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Product Analysis")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()
                
                Text("Barcode: \(barcode)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if analysisService.isLoading {
                    loadingView
                        .padding(.top, 100)
                } else if let error = analysisService.error {
                    errorView(message: error)
                        .padding(.top, 100)
                } else if let productDetails = analysisService.productDetails {
                    productDetailsView(productDetails)
                    
                    saveToFoodDiaryButton(productDetails: productDetails)
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .onAppear {
            fetchUserData()
            if let userId = authService.user?.uid {
                Task {
                    await foodDiaryService.fetchSavedProducts(userId: userId)
                    isSaved = foodDiaryService.isProductSaved(barcode: barcode)
                }
            }
        }
        .sheet(isPresented: $showingNovaGroupInfo) {
            NovaGroupInfoView()
        }
        .sheet(isPresented: $showingNutritionScoreInfo) {
            NutritionScoreInfoView()
        }
        .toast(isPresented: $showSaveConfirmation) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Product saved to Food Diary")
                    .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private func saveToFoodDiaryButton(productDetails: ProductDetails) -> some View {
        Button(action: {
            saveToFoodDiary(productDetails: productDetails)
        }) {
            HStack {
                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 18))
                Text(isSaved ? "Saved to Food Diary" : "Save to Food Diary")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSaved ? Color.green.opacity(0.2) : Color.blue)
            .foregroundColor(isSaved ? .green : .white)
            .cornerRadius(12)
            .overlay(
                Group {
                    if showSavingIndicator {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            )
        }
        .disabled(showSavingIndicator)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    struct ToastModifier<Presenting>: ViewModifier where Presenting: View {
        @Binding var isPresented: Bool
        let duration: TimeInterval
        let presenting: () -> Presenting
        
        func body(content: Content) -> some View {
            ZStack {
                content
                
                if isPresented {
                    VStack {
                        Spacer()
                        presenting()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                    withAnimation {
                                        self.isPresented = false
                                    }
                                }
                            }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isPresented)
                }
            }
        }
    }
    
    private func saveToFoodDiary(productDetails: ProductDetails) {
        guard let userId = authService.user?.uid else { return }
        
        showSavingIndicator = true
        
        let savedProduct = SavedProduct(from: productDetails, barcode: barcode)
        
        Task {
            do {
                try await foodDiaryService.saveProduct(savedProduct, userId: userId)
                
                await MainActor.run {
                    showSavingIndicator = false
                    isSaved = true
                    showSaveConfirmation = true
                }
            } catch {
                await MainActor.run {
                    showSavingIndicator = false
                    analysisService.error = "Failed to save product: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 30) {
            LottieLoadingView()
                .frame(width: 200, height: 200)
            
            Text("Analyzing product nutrition...")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("We're checking if this product matches your dietary needs")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 70))
                .foregroundColor(.orange)
            
            Text("Analysis Failed")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if let userData = userData {
                    Task {
                        await analysisService.fetchProductDetails(for: barcode, userData: userData)
                    }
                }
            }) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
    }
    
    private func productDetailsView(_ details: ProductDetails) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(details.brand)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(details.name)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            suitabilityView(details)
            
            analysisView(details.analysis)
            
            macronutrientsPieChartView(details.nutritionData.macronutrients)
            
            dailyValueComparisonView(details.nutritionData)
            
            processingLevelView(novaGroup: details.nutritionData.additionalMetrics.novaGroup)
            
            ingredientsView(details.ingredients)
            
            Spacer().frame(height: 30)
        }
    }
    
    private func suitabilityView(_ details: ProductDetails) -> some View {
        let status = details.suitabilityStatus
        
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: status.systemImageName)
                    .font(.system(size: 30))
                    .foregroundColor(Color(status.color))
                
                Text(status.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(status.color))
            }
            
            Text("Based on your dietary profile")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(status.color).opacity(0.1))
        .cornerRadius(16)
    }
    
    private func analysisView(_ analysis: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personalized Analysis")
                .font(.headline)
            
            Text(analysis)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func macronutrientsPieChartView(_ macros: Macronutrients) -> some View {
        let totalMacros = macros.protein + macros.carbohydrates + macros.fat
        let proteinPercentage = totalMacros > 0 ? Double(macros.protein) / Double(totalMacros) : 0
        let carbsPercentage = totalMacros > 0 ? Double(macros.carbohydrates) / Double(totalMacros) : 0
        let fatPercentage = totalMacros > 0 ? Double(macros.fat) / Double(totalMacros) : 0
        
        return VStack(spacing: 20) {
            Text("Macronutrient Distribution")
                .font(.headline)
            
            HStack(spacing: 25) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 130, height: 130)
                    
                    Circle()
                        .trim(from: 0, to: proteinPercentage)
                        .stroke(Color.blue, lineWidth: 20)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .trim(from: 0, to: carbsPercentage)
                        .stroke(Color.orange, lineWidth: 20)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90 + 360 * proteinPercentage))
                    
                    Circle()
                        .trim(from: 0, to: fatPercentage)
                        .stroke(Color.purple, lineWidth: 20)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90 + 360 * (proteinPercentage + carbsPercentage)))
                    
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(macros.calories))")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    macroLegendItem(color: .blue, name: "Protein", value: Int(macros.protein), percentage: Int(proteinPercentage * 100))
                    macroLegendItem(color: .orange, name: "Carbs", value: Int(macros.carbohydrates), percentage: Int(carbsPercentage * 100))
                    macroLegendItem(color: .purple, name: "Fat", value: Int(macros.fat), percentage: Int(fatPercentage * 100))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func macroLegendItem(color: Color, name: String, value: Int, percentage: Int) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(value)g")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private let recommendedValues = [
        "calories": 2000,
        "protein": 50,
        "carbs": 275,
        "fat": 70,
        "fiber": 25,
        "sugar": 25,
        "sodium": 2.3
    ]
    
    private func dailyValueComparisonView(_ nutritionData: NutritionData) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("% Daily Value")
                .font(.headline)
                .padding(.bottom, 5)
            
            Group {
                nutrientProgressBar(
                    name: "Calories",
                    value: Double(nutritionData.macronutrients.calories),
                    recommended: (userData?["dailyCalories"] as? Double ?? recommendedValues["calories"]) ?? 2000,
                    color: .orange
                )
                
                nutrientProgressBar(
                    name: "Protein",
                    value: Double(nutritionData.macronutrients.protein),
                    recommended: (userData?["dailyProtein"] as? Double ?? recommendedValues["protein"]) ?? 50,
                    color: .blue,
                    unit: "g"
                )
                
                nutrientProgressBar(
                    name: "Carbs",
                    value: Double(nutritionData.macronutrients.carbohydrates),
                    recommended: (userData?["dailyCarbs"] as? Double ?? recommendedValues["carbs"]) ?? 275,
                    color: .orange,
                    unit: "g"
                )
                
                nutrientProgressBar(
                    name: "Fat",
                    value: Double(nutritionData.macronutrients.fat),
                    recommended: (userData?["dailyFat"] as? Double ?? recommendedValues["protein"]) ?? 70,
                    color: .purple,
                    unit: "g"
                )
                
                nutrientProgressBar(
                    name: "Fiber",
                    value: Double(nutritionData.macronutrients.fiber),
                    recommended: Double(recommendedValues["fiber"]!),
                    color: .green,
                    unit: "g"
                )
                
                nutrientProgressBar(
                    name: "Sugar",
                    value: Double(nutritionData.macronutrients.sugar),
                    recommended: Double(recommendedValues["sugar"]!),
                    color: .red,
                    unit: "g"
                )
                
                nutrientProgressBar(
                    name: "Sodium",
                    value: nutritionData.micronutrients.sodium * 1000,
                    recommended: Double(recommendedValues["sodium"]!) * 1000,
                    color: .red,
                    unit: "mg"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func nutrientProgressBar(name: String, value: Double, recommended: Double, color: Color, unit: String = "") -> some View {
        let percentage = min(value / recommended, 1.0)
        
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(value))\(unit) of \(Int(recommended))\(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 15) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: 10)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * CGFloat(percentage), height: 10)
                            .cornerRadius(5)
                    }
                }
                .frame(height: 10)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .frame(width: 40)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func processingLevelView(novaGroup: Int) -> some View {
        VStack(spacing: 15) {
            HStack {
                Text("Processing Level (NOVA Group)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingNovaGroupInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 0) {
                ForEach(1...4, id: \.self) { group in
                    VStack(spacing: 5) {
                        ZStack {
                            Rectangle()
                                .fill(group == novaGroup ? novaGroupColor(group) : Color.gray.opacity(0.3))
                                .frame(height: 40)
                            
                            if group == novaGroup {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .opacity(0.9)
                            }
                        }
                        
                        Text("Group \(group)")
                            .font(.caption)
                            .foregroundColor(group == novaGroup ? .primary : .secondary)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(group == novaGroup ? novaGroupColor(group) : Color.clear, lineWidth: 2)
                    )
                }
            }
            .cornerRadius(8)
            
            Text(novaGroupDescription(novaGroup))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func ingredientsView(_ ingredients: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients")
                .font(.headline)
            
            Text(ingredients)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func novaGroupColor(_ group: Int) -> Color {
        switch group {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }
    
    private func novaGroupDescription(_ group: Int) -> String {
        switch group {
        case 1: return "Unprocessed or minimally processed foods"
        case 2: return "Processed culinary ingredients"
        case 3: return "Processed foods"
        case 4: return "Ultra-processed food and drink products"
        default: return "Unknown processing level"
        }
    }
    
    private func fetchUserData() {
        guard let userId = authService.user?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                self.userData = data
                
                if let userData = self.userData {
                    Task {
                        await self.analysisService.fetchProductDetails(for: self.barcode, userData: userData)
                    }
                }
            } else {
                self.analysisService.error = "Could not retrieve your profile data. Please complete your profile setup first."
            }
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, duration: TimeInterval = 2.0, content: @escaping () -> some View) -> some View {
        self.modifier(ProductAnalysisView.ToastModifier(isPresented: isPresented, duration: duration, presenting: content))
    }
}
