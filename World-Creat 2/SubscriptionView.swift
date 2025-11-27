//
//  SubscriptionView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var selectedPlan: SubscriptionPlan?
    @State private var isPurchasing = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""
    @State private var showPurchaseSuccess = false
    
    enum SubscriptionPlan: String, CaseIterable {
        case starter = "Starter"
        case pro = "Pro"
        case studio = "Studio"
        
        var coins: Int {
            switch self {
            case .starter: return 9000
            case .pro: return 24000
            case .studio: return 50000
            }
        }
        
        var productID: PurchaseService.ProductID {
            switch self {
            case .starter: return .starter
            case .pro: return .pro
            case .studio: return .studio
            }
        }
        
        var defaultPrice: String {
            // Prix par défaut (sera remplacé par le prix StoreKit si disponible)
            switch self {
            case .starter: return "6 € HT"
            case .pro: return "15 € HT"
            case .studio: return "30 € HT"
            }
        }
        
        var icon: String {
            switch self {
            case .starter: return "🪙"
            case .pro: return "⚡"
            case .studio: return "👑"
            }
        }
        
        var isPopular: Bool {
            self == .pro
        }
    }
    
    var body: some View {
        ZStack {
            // Fond avec gradient violet foncé
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header avec bouton fermer
                    HStack {
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Titre et description
                    VStack(spacing: 12) {
                        Text("Choisissez votre formule")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Sélectionnez la formule qui vous convient pour créer de superbes contenus générés par IA.")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Plans d'abonnement
                    HStack(spacing: 16) {
                        ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                            SubscriptionPlanCard(
                                plan: plan,
                                price: getPrice(for: plan),
                                isSelected: selectedPlan == plan,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedPlan = plan
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Bouton d'achat
                    if let plan = selectedPlan {
                        Button(action: {
                            Task {
                                await purchasePlan(plan)
                            }
                        }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Acheter \(plan.rawValue)")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .disabled(isPurchasing || purchaseService.isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    // Texte "sans engagement"
                    HStack(spacing: 4) {
                        Text("sans engagement - résiliables à tout moment")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        Text("🚀")
                            .font(.system(size: 14))
                    }
                    .padding(.top, 8)
                    
                    // Lien "à propos"
                    Button(action: {
                        // Ouvrir la page CGV dans Safari
                        if let url = URL(string: "https://www.world-creat.com/cgv") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("à propos")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 8)
                    
                    // Lien "Politique de confidentialité"
                    Button(action: {
                        // Ouvrir la page Politique de confidentialité dans Safari
                        if let url = URL(string: "https://www.world-creat.com/politique-confidentialite") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Politique de confidentialité")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                    
                    // Lien "CGU"
                    Button(action: {
                        // Ouvrir la page CGU dans Safari
                        if let url = URL(string: "https://www.world-creat.com/cgu") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("CGU")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .onAppear {
            Task {
                await purchaseService.loadProducts()
            }
        }
        .alert("Achat réussi !", isPresented: $showPurchaseSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Vos crédits ont été ajoutés avec succès.")
        }
        .alert("Erreur d'achat", isPresented: $showPurchaseError) {
            Button("OK") { }
        } message: {
            Text(purchaseErrorMessage)
        }
    }
    
    private func purchasePlan(_ plan: SubscriptionPlan) async {
        isPurchasing = true
        purchaseErrorMessage = ""
        
        do {
            let success = try await purchaseService.purchaseByID(plan.productID)
            
            if success {
                showPurchaseSuccess = true
            } else {
                purchaseErrorMessage = "L'achat a été annulé."
                showPurchaseError = true
            }
        } catch {
            purchaseErrorMessage = error.localizedDescription
            showPurchaseError = true
        }
        
        isPurchasing = false
    }
    
    // Fonction helper pour obtenir le prix (peut accéder à @MainActor)
    private func getPrice(for plan: SubscriptionPlan) -> String {
        // Si le produit est chargé depuis StoreKit, utiliser son prix
        if let product = purchaseService.availableProducts.first(where: { $0.id == plan.productID.rawValue }) {
            return product.displayPrice
        }
        // Sinon, prix par défaut
        return plan.defaultPrice
    }
}

struct SubscriptionPlanCard: View {
    let plan: SubscriptionView.SubscriptionPlan
    let price: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Badge "Populaire" pour Pro
                if plan.isPopular {
                    Text("Populaire")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            LinearGradient(
                                colors: [Color.pink, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .padding(.top, -8)
                } else {
                    Spacer()
                        .frame(height: 20)
                }
                
                // Icône
                Text(plan.icon)
                    .font(.system(size: 48))
                    .padding(.top, plan.isPopular ? 0 : 8)
                
                // Nom du plan
                Text(plan.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                // Nombre de coins
                Text("\(formatCoins(plan.coins)) coins")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.pink)
                
                // Fréquence
                Text("hebdomadaire")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                
                // Prix
                Text(price)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.pink : (plan.isPopular ? Color.pink.opacity(0.5) : Color.clear),
                                lineWidth: isSelected ? 2 : (plan.isPopular ? 1 : 0)
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func formatCoins(_ coins: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: coins)) ?? "\(coins)"
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(AppState.shared)
}

