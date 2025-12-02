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
    @Published var generationHistory: [GenerationItem] = [] {
        didSet {
            saveGenerationHistory()
        }
    }
    
    private let creditsManager = CreditsManager.shared
    private let authService = AppleAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let defaults = UserDefaults.standard
    private let generationHistoryKey = "generationHistory"
    
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
        // Charger l'historique sauvegardé
        loadGenerationHistory()
        
        // Observer les changements de crédits
        creditsManager.$credits
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Observer les changements d'authentification
        authService.$isAuthenticated
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                // Vérifier et donner les crédits bonus si nécessaire
                self?.checkAndGiveBonusCredits()
            }
            .store(in: &cancellables)
        
        authService.$userEmail
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                // Vérifier et donner les crédits bonus si nécessaire
                self?.checkAndGiveBonusCredits()
            }
            .store(in: &cancellables)
        
        authService.$userName
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Vérifier au démarrage si l'utilisateur est déjà connecté
        checkAndGiveBonusCredits()
    }
    
    // Vérifier et donner des crédits bonus à des utilisateurs spécifiques
    private func checkAndGiveBonusCredits() {
        guard isAuthenticated,
              let email = userEmail?.lowercased() else {
            return
        }
        
        // Clé pour vérifier si les crédits ont déjà été donnés
        let bonusCreditsKey = "bonusCredits_\(email)"
        let hasReceivedBonus = defaults.bool(forKey: bonusCreditsKey)
        
        // Donner 100 000 crédits à nath.vanparys@icloud.com (une seule fois)
        if email == "nath.vanparys@icloud.com" && !hasReceivedBonus {
            creditsManager.addCredits(100000)
            defaults.set(true, forKey: bonusCreditsKey)
            defaults.synchronize()
            print("✅ 100 000 crédits ajoutés au compte \(email)")
        }
    }
    
    // Sauvegarder l'historique dans UserDefaults
    private func saveGenerationHistory() {
        if let encoded = try? JSONEncoder().encode(generationHistory) {
            defaults.set(encoded, forKey: generationHistoryKey)
            defaults.synchronize()
        }
    }
    
    // Charger l'historique depuis UserDefaults
    private func loadGenerationHistory() {
        if let data = defaults.data(forKey: generationHistoryKey),
           let decoded = try? JSONDecoder().decode([GenerationItem].self, from: data) {
            generationHistory = decoded
        }
    }
    
    // Méthodes pour gérer les crédits
    func addCredits(_ amount: Int) {
        creditsManager.addCredits(amount)
    }
    
    // Ajouter des crédits à un compte spécifique par email (méthode admin)
    func addCreditsToAccount(email: String, amount: Int) -> Bool {
        // Vérifier que l'utilisateur est connecté avec cet email
        guard isAuthenticated,
              let currentEmail = userEmail,
              currentEmail.lowercased() == email.lowercased() else {
            print("❌ Impossible d'ajouter des crédits : l'utilisateur n'est pas connecté avec l'email \(email)")
            return false
        }
        
        print("✅ Ajout de \(amount) crédits au compte \(email)")
        creditsManager.addCredits(amount)
        return true
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

struct GenerationItem: Identifiable, Codable {
    let id: UUID
    let type: GenerationType
    let prompt: String
    let resultURL: String?
    let createdAt: Date
    let model: String
    
    init(id: UUID = UUID(), type: GenerationType, prompt: String, resultURL: String?, createdAt: Date, model: String) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.resultURL = resultURL
        self.createdAt = createdAt
        self.model = model
    }
    
    enum GenerationType: String, Codable {
        case image
        case video
    }
}

