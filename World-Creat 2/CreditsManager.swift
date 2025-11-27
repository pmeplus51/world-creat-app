//
//  CreditsManager.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import Combine

class CreditsManager: ObservableObject {
    static let shared = CreditsManager()
    
    @Published var credits: Int = 0
    
    private let creditsKey = "userCredits"
    private let defaults = UserDefaults.standard
    
    // Clé pour vérifier si c'est un nouveau compte (pas de crédits initiaux donnés)
    private let hasInitializedKey = "creditsInitialized"
    
    // Coûts de génération
    struct GenerationCost {
        static let image = 525
        static let videoSora2 = 1310
        static let videoVeo3 = 1500
    }
    
    private init() {
        loadCredits()
    }
    
    // Charger les crédits depuis UserDefaults
    private func loadCredits() {
        // Vérifier si c'est la première initialisation
        let hasInitialized = defaults.bool(forKey: hasInitializedKey)
        
        if !hasInitialized {
            // Nouveau compte : commencer à 0 crédits
            credits = 0
            defaults.set(true, forKey: hasInitializedKey)
            saveCredits()
        } else {
            // Compte existant : charger les crédits sauvegardés
            credits = defaults.integer(forKey: creditsKey)
        }
        
        // S'assurer que les crédits ne sont jamais négatifs
        if credits < 0 {
            credits = 0
            saveCredits()
        }
    }
    
    // Sauvegarder les crédits dans UserDefaults
    private func saveCredits() {
        defaults.set(credits, forKey: creditsKey)
        defaults.synchronize()
    }
    
    // Ajouter des crédits
    func addCredits(_ amount: Int) {
        credits += amount
        saveCredits()
    }
    
    // Déduire des crédits
    func deductCredits(_ amount: Int) -> Bool {
        guard credits >= amount else {
            return false
        }
        credits -= amount
        saveCredits()
        return true
    }
    
    // Vérifier si l'utilisateur a assez de crédits
    func hasEnoughCredits(for cost: Int) -> Bool {
        return credits >= cost
    }
    
    // Obtenir le coût pour un type de génération
    func getCost(for type: GenerationType, model: String? = nil) -> Int {
        switch type {
        case .image:
            return GenerationCost.image
        case .video:
            if let model = model, model == "Veo 3" {
                return GenerationCost.videoVeo3
            }
            return GenerationCost.videoSora2
        }
    }
    
    enum GenerationType {
        case image
        case video
    }
    
    // Réinitialiser les crédits à 0 (pour tests ou réinitialisation)
    func resetCredits() {
        credits = 0
        saveCredits()
    }
    
    // Réinitialiser complètement (supprimer toutes les données de crédits)
    func resetAll() {
        credits = 0
        defaults.removeObject(forKey: creditsKey)
        defaults.removeObject(forKey: hasInitializedKey)
        defaults.synchronize()
    }
}


