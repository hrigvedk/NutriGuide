//
//  FoodDiaryView.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/5/25.
//
//
import SwiftUI
import Firebase

struct FoodDiaryView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var foodDiaryService = FoodDiaryService()
    @State private var showDeleteConfirmation = false
    @State private var productToDelete: SavedProduct? = nil
    @State private var searchText = ""
    @State private var selectedFilter = FilterOption.all
    @State private var showingFilterOptions = false
    @FocusState private var isTextFieldFocused: Bool
    
    enum FilterOption: String, CaseIterable {
        case all = "All Products"
        case suitable = "Suitable"
        case likelySuitable = "Likely Suitable"
        case notSuitable = "Not Suitable"
        case recent = "Recently Added"
    }
    
    var filteredProducts: [SavedProduct] {
        let products = foodDiaryService.savedProducts
        
        let searchFiltered = searchText.isEmpty ? products : products.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.brand.lowercased().contains(searchText.lowercased())
        }
        
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .suitable:
            return searchFiltered.filter { $0.suitabilityStatus == "Suitable" }
        case .likelySuitable:
            return searchFiltered.filter {$0.suitabilityStatus.contains("Likely")}
        case .notSuitable:
            return searchFiltered.filter { $0.suitabilityStatus.contains("Not") }
        case .recent:
            return searchFiltered
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search saved products", text: $searchText)
                    .disableAutocorrection(true)
                    .focused($isTextFieldFocused)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Menu {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Button(action: {
                            selectedFilter = option
                        }) {
                            HStack {
                                Text(option.rawValue)
                                if selectedFilter == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            if selectedFilter != .all || !searchText.isEmpty {
                HStack {
                    if selectedFilter != .all {
                        filterPill(text: selectedFilter.rawValue)
                    }
                    
                    if !searchText.isEmpty {
                        filterPill(text: "Search: \(searchText)")
                    }
                    
                    Spacer()
                    
                    Button("Clear All") {
                        searchText = ""
                        selectedFilter = .all
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 5)
            }
            
            if foodDiaryService.isLoading {
                loadingView
            } else if let error = foodDiaryService.error {
                errorView(error: error)
            } else if filteredProducts.isEmpty {
                emptyStateView
            } else {
                productListView
            }
        }
        .navigationTitle("Food Diary")
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            if let userId = authService.user?.uid {
                Task {
                    await foodDiaryService.fetchSavedProducts(userId: userId)
                }
            }
        }
        .alert("Delete Product", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteProduct()
            }
        } message: {
            Text("Are you sure you want to remove this product from your food diary?")
        }
        .refreshable {
            if let userId = authService.user?.uid {
                await foodDiaryService.fetchSavedProducts(userId: userId)
            }
        }
    }
    
    private func filterPill(text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(15)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading your saved products...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Couldn't Load Products")
                .font(.headline)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if let userId = authService.user?.uid {
                    Task {
                        await foodDiaryService.fetchSavedProducts(userId: userId)
                    }
                }
            }) {
                Text("Try Again")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.7))
                .padding()
            
            Text("No Products Saved Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            if searchText.isEmpty && selectedFilter == .all {
                Text("Products you analyze and save will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                NavigationLink(destination: BarcodeScannerView(selectedTab: .constant(1))) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan a Product")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top)
            } else {
                Text("No products match your current filters")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var productListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredProducts) { product in
                    ProductCard(product: product, onDelete: {
                        productToDelete = product
                        showDeleteConfirmation = true
                    })
                }
            }
            .padding()
        }
    }
    
    private func deleteProduct() {
        guard let product = productToDelete, let userId = authService.user?.uid else { return }
        
        Task {
            do {
                try await foodDiaryService.removeProduct(productId: product.id, userId: userId)
            } catch {
                print("Error deleting product: \(error.localizedDescription)")
            }
        }
    }
}

struct ProductCard: View {
    let product: SavedProduct
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(product.brand)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            
            Text(product.name)
                .font(.subheadline)
                .lineLimit(2)
            
            Divider()
            
            HStack(spacing: 20) {
                nutritionItem(value: "\(Int(product.calories))", label: "Calories")
                nutritionItem(value: "\(Int(product.protein))g", label: "Protein")
                nutritionItem(value: "\(Int(product.carbs))g", label: "Carbs")
                nutritionItem(value: "\(Int(product.fat))g", label: "Fat")
            }
            
            HStack {
                Text(product.suitabilityStatus)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(suitabilityColor(status: product.suitabilityStatus).opacity(0.1))
                    .foregroundColor(suitabilityColor(status: product.suitabilityStatus))
                    .cornerRadius(5)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("NOVA")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(product.novaGroup)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(novaGroupColor(product.novaGroup))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Text("Saved on \(formattedDate(product.savedDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Barcode: \(product.barcode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func nutritionItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func suitabilityColor(status: String) -> Color {
        if status.contains("Not Suitable") {
            return .red
        } else if status.contains("Caution") {
            return .orange
        } else if status.contains("Suitable") {
            return .green
        } else {
            return .gray
        }
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
