//
//  AppState.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var selectedAIModel: AIModel = .nanoBanana
    @Published var selectedVideoModel: VideoModel = .sora2
    @Published var generationHistory: [GenerationItem] = []
    
    private let creditsManager = CreditsManager.shared
    private let authService = AppleAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Propriétés d'authentification
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    var userEmail: String? {
        authService.userEmail
    }
    
    var userName: String? {
        authService.userName
    }
    
    var userInitials: String {
        if let name = authService.userName {
            let components = name.components(separatedBy: " ")
            if components.count >= 2 {
                let first = String(components[0].prefix(1))
                let second = String(components[1].prefix(1))
                return "\(first)\(second)".uppercased()
            } else if let first = components.first {
                return String(first.prefix(2)).uppercased()
            }
        } else if let email = authService.userEmail {
            return String(email.prefix(2)).uppercased()
        }
        return "NA"
    }
    
    // Propriété calculée pour synchroniser avec CreditsManager
    var userCredits: Int {
        creditsManager.credits
    }
    
    private init() {
        // Observer les changements de crédits
        creditsManager.$credits
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // Méthodes pour gérer les crédits
    func addCredits(_ amount: Int) {
        creditsManager.addCredits(amount)
    }
    
    func deductCredits(_ amount: Int) -> Bool {
        return creditsManager.deductCredits(amount)
    }
    
    func hasEnoughCredits(for cost: Int) -> Bool {
        return creditsManager.hasEnoughCredits(for: cost)
    }
    
    func getGenerationCost(for type: CreditsManager.GenerationType, model: String? = nil) -> Int {
        return creditsManager.getCost(for: type, model: model)
    }
    
    // Méthodes d'authentification
    func signOut() {
        authService.signOut()
    }
    
    func deleteAccount() {
        authService.deleteAccount()
    }
}

enum AIModel: String, CaseIterable {
    case nanoBanana = "Nano Banana 2"
    
    var icon: String {
        return "🍌"
    }
    
    var description: String {
        return "Génération & retouche photos"
    }
}

enum VideoModel: String, CaseIterable {
    case sora2 = "Sora 2"
    case veo3 = "Veo 3.1"
    
    var icon: String {
        switch self {
        case .sora2: return "video.fill"
        case .veo3: return "film.fill"
        }
    }
    
    var description: String {
        switch self {
        case .sora2: return "L'IA de toutes les vidéos virales"
        case .veo3: return "L'IA des meilleures pubs"
        }
    }
}

struct GenerationItem: Identifiable {
    let id = UUID()
    let type: GenerationType
    let prompt: String
    let resultURL: String?
    let createdAt: Date
    let model: String
    
    enum GenerationType {
        case image
        case video
    }
}

