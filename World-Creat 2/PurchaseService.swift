//
//  PurchaseService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import StoreKit
import Combine

@MainActor
class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var availableProducts: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Identifiants des produits (à configurer dans App Store Connect)
    enum ProductID: String, CaseIterable {
        case starter = "com.worldcreat.starter"
        case pro = "com.worldcreat.pro"
        case studio = "com.worldcreat.studio"
        
        var coins: Int {
            switch self {
            case .starter: return 9000
            case .pro: return 24000
            case .studio: return 50000
            }
        }
    }
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Écouter les transactions
        updateListenerTask = listenForTransactions()
        
        // Charger les produits disponibles (en arrière-plan, ne bloque pas l'init)
        Task { @MainActor in
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // Charger les produits depuis l'App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let products = try await Product.products(for: productIDs)
            
            await MainActor.run {
                self.availableProducts = products
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Erreur lors du chargement des produits: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Acheter un produit
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Ajouter les crédits correspondants
            if let productID = ProductID(rawValue: product.id) {
                CreditsManager.shared.addCredits(productID.coins)
            }
            
            await transaction.finish()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // Acheter directement par ID (pour développement/test)
    func purchaseByID(_ productID: ProductID) async throws -> Bool {
        guard let product = availableProducts.first(where: { $0.id == productID.rawValue }) else {
            throw PurchaseError.productNotFound
        }
        return try await purchase(product)
    }
    
    // Écouter les transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    // Vérifier la transaction (fonction non-isolée)
                    let transaction = try Self.checkVerifiedNonIsolated(result)
                    
                    // Obtenir les coins pour ce productID
                    let coins = Self.getCoinsForProductID(transaction.productID)
                    
                    // Ajouter les crédits sur le MainActor
                    await MainActor.run {
                        CreditsManager.shared.addCredits(coins)
                    }
                    
                    await transaction.finish()
                } catch {
                    print("Erreur lors de la vérification de la transaction: \(error)")
                }
            }
        }
    }
    
    // Vérifier la transaction (version non-isolée statique pour Task.detached)
    nonisolated private static func checkVerifiedNonIsolated<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // Obtenir les coins pour un productID (version non-isolée statique)
    nonisolated private static func getCoinsForProductID(_ productID: String) -> Int {
        switch productID {
        case "com.worldcreat.starter":
            return 9000
        case "com.worldcreat.pro":
            return 24000
        case "com.worldcreat.studio":
            return 50000
        default:
            return 0
        }
    }
    
    // Vérifier la transaction (version MainActor)
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// Enum d'erreur déplacé en dehors de la classe pour être accessible depuis un contexte non-isolé
enum PurchaseError: LocalizedError {
    case productNotFound
    case failedVerification
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Produit non trouvé"
        case .failedVerification:
            return "Échec de la vérification de la transaction"
        }
    }
}

