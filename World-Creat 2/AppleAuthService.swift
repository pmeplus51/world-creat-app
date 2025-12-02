//
//  AppleAuthService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import AuthenticationServices
import SwiftUI

@MainActor
class AppleAuthService: NSObject, ObservableObject {
    static let shared = AppleAuthService()
    
    @Published var isAuthenticated = false
    @Published var userIdentifier: String?
    @Published var userEmail: String?
    @Published var userName: String?
    
    private let userDefaults = UserDefaults.standard
    private let userIdentifierKey = "apple_user_identifier"
    private let userEmailKey = "apple_user_email"
    private let userNameKey = "apple_user_name"
    
    override init() {
        super.init()
        loadSavedUser()
    }
    
    // Charger les informations utilisateur sauvegardées
    private func loadSavedUser() {
        if let identifier = userDefaults.string(forKey: userIdentifierKey) {
            userIdentifier = identifier
            userEmail = userDefaults.string(forKey: userEmailKey)
            userName = userDefaults.string(forKey: userNameKey)
            isAuthenticated = true
            
            // Forcer la publication des changements
            objectWillChange.send()
            
            print("📱 Utilisateur chargé au démarrage:")
            print("   - Email: \(userEmail ?? "nil")")
            print("   - Name: \(userName ?? "nil")")
            print("   - Identifier: \(identifier)")
            
            // Vérifier et ajouter les crédits de test si nécessaire
            addTestCreditsIfNeeded(email: userEmail)
        }
    }
    
    // Sauvegarder les informations utilisateur
    func saveUser(identifier: String, email: String?, name: String?) {
        print("💾 Sauvegarde des informations utilisateur...")
        print("   - Identifier: \(identifier)")
        print("   - Email reçu: \(email ?? "nil")")
        print("   - Name reçu: \(name ?? "nil")")
        
        // Sauvegarder l'identifier (toujours présent)
        userDefaults.set(identifier, forKey: userIdentifierKey)
        
        // Pour l'email : utiliser celui fourni, sinon garder l'existant
        let finalEmail: String?
        if let email = email, !email.isEmpty {
            userDefaults.set(email, forKey: userEmailKey)
            finalEmail = email
        } else {
            // Garder l'email existant s'il y en a un
            finalEmail = userDefaults.string(forKey: userEmailKey)
        }
        
        // Pour le nom : utiliser celui fourni, sinon garder l'existant
        let finalName: String?
        if let name = name, !name.isEmpty {
            userDefaults.set(name, forKey: userNameKey)
            finalName = name
        } else {
            // Garder le nom existant s'il y en a un
            finalName = userDefaults.string(forKey: userNameKey)
        }
        
        // Synchroniser UserDefaults
        userDefaults.synchronize()
        
        // Mettre à jour les propriétés publiées sur le thread principal
        // Cela déclenchera automatiquement les observers
        userIdentifier = identifier
        userEmail = finalEmail
        userName = finalName
        isAuthenticated = true
        
        // Forcer la publication des changements
        objectWillChange.send()
        
        print("✅ Informations sauvegardées - Authentifié: \(isAuthenticated)")
        print("   - Email final: \(userEmail ?? "nil")")
        print("   - Name final: \(userName ?? "nil")")
        print("   - Identifier final: \(userIdentifier ?? "nil")")
        
        // Ajouter des crédits gratuits uniquement pour votre compte de test
        addTestCreditsIfNeeded(email: finalEmail)
    }
    
    // Ajouter des crédits de test uniquement pour votre compte
    private func addTestCreditsIfNeeded(email: String?) {
        guard let email = email else { return }
        
        let testEmail = "theo.toulemonde@icloud.com"
        let creditsKey = "test_credits_added_\(testEmail)"
        
        // Vérifier si c'est votre email de test
        if email.lowercased() == testEmail.lowercased() {
            // Vérifier si on a déjà ajouté les crédits
            if !userDefaults.bool(forKey: creditsKey) {
                let creditsToAdd = 5000
                CreditsManager.shared.addCredits(creditsToAdd)
                userDefaults.set(true, forKey: creditsKey)
                userDefaults.synchronize()
                print("🎁 \(creditsToAdd) crédits de test ajoutés pour \(testEmail)")
            } else {
                print("ℹ️ Les crédits de test ont déjà été ajoutés pour \(testEmail)")
            }
        }
    }
    
    // Supprimer les informations utilisateur
    private func clearUser() {
        userDefaults.removeObject(forKey: userIdentifierKey)
        userDefaults.removeObject(forKey: userEmailKey)
        userDefaults.removeObject(forKey: userNameKey)
        userIdentifier = nil
        userEmail = nil
        userName = nil
        isAuthenticated = false
    }
    
    // Déconnexion
    func signOut() {
        clearUser()
    }
    
    // Supprimer le compte
    func deleteAccount() {
        clearUser()
        // Ici, tu pourrais aussi appeler une API backend pour supprimer le compte côté serveur
    }
}

// Extension pour gérer les callbacks d'authentification
extension AppleAuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            // Construire le nom complet si disponible
            var name: String? = nil
            if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                name = "\(givenName) \(familyName)"
            } else if let givenName = fullName?.givenName {
                name = givenName
            } else if let familyName = fullName?.familyName {
                name = familyName
            }
            
            // Sauvegarder les informations
            saveUser(identifier: userIdentifier, email: email, name: name)
            
            print("✅ Connexion Apple réussie - ID: \(userIdentifier)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Erreur de connexion Apple: \(error.localizedDescription)")
        
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("⚠️ L'utilisateur a annulé la connexion")
            case .failed:
                print("⚠️ La connexion a échoué")
            case .invalidResponse:
                print("⚠️ Réponse invalide")
            case .notHandled:
                print("⚠️ Erreur non gérée")
            case .unknown:
                print("⚠️ Erreur inconnue")
            @unknown default:
                print("⚠️ Erreur inconnue")
            }
        }
    }
}

// Extension pour gérer la présentation de l'authentification
extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
        #else
        return NSApplication.shared.windows.first ?? NSWindow()
        #endif
    }
}

