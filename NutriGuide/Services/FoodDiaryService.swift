//
//  FoodDiaryService.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/14/25.
//
import Foundation
import Firebase
import FirebaseFirestore

class FoodDiaryService: ObservableObject {
    @Published var savedProducts: [SavedProduct] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let db = Firestore.firestore()
    
    func saveProduct(_ product: SavedProduct, userId: String) async throws {
        let productsRef = db.collection("users").document(userId).collection("savedProducts")
        
        let query = productsRef.whereField("barcode", isEqualTo: product.barcode)
        let snapshot = try await query.getDocuments()
        
        if !snapshot.documents.isEmpty {
            let existingDoc = snapshot.documents[0]
            try await productsRef.document(existingDoc.documentID).setData(product.dictionary, merge: true)
        } else {
            try await productsRef.document(product.id).setData(product.dictionary)
        }
        
        await fetchSavedProducts(userId: userId)
    }
    
    func removeProduct(productId: String, userId: String) async throws {
        try await db.collection("users").document(userId).collection("savedProducts").document(productId).delete()
        
        await MainActor.run {
            self.savedProducts.removeAll { $0.id == productId }
        }
    }
    
    func fetchSavedProducts(userId: String) async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let snapshot = try await db.collection("users").document(userId).collection("savedProducts")
                .order(by: "savedDate", descending: true)
                .getDocuments()
            
            let products = snapshot.documents.compactMap { SavedProduct(document: $0) }
            
            await MainActor.run {
                self.savedProducts = products
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load saved products: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func isProductSaved(barcode: String) -> Bool {
        return savedProducts.contains { $0.barcode == barcode }
    }
}
