//
//  LoginView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authService = AppleAuthService.shared
    @StateObject private var appState = AppState.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Bouton de fermeture en haut à droite
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
            }
            
            Spacer()
            
            // Logo et titre
            VStack(spacing: 24) {
                // Logo
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .purple.opacity(0.5), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 8) {
                    Text("World-Creat")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Générez avec l'IA")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Bouton Sign in with Apple
            VStack(spacing: 20) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // S'assurer que le callback est exécuté sur le thread principal
                    DispatchQueue.main.async {
                        handleSignInResult(result)
                    }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 56)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("En vous connectant, vous acceptez nos conditions d'utilisation")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Erreur de connexion", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authService.isAuthenticated) { oldValue, newValue in
            // Fermer automatiquement si l'utilisateur se connecte
            if newValue && !oldValue {
                dismiss()
            }
        }
    }
    
    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                
                // Lors de la première connexion, email et fullName sont disponibles
                // Lors des connexions suivantes, ils sont nil, il faut récupérer depuis UserDefaults
                var email = appleIDCredential.email
                var fullName = appleIDCredential.fullName
                
                // Si l'email n'est pas disponible (connexion suivante), récupérer depuis UserDefaults
                if email == nil {
                    email = UserDefaults.standard.string(forKey: "apple_user_email")
                }
                
                // Si le nom n'est pas disponible, récupérer depuis UserDefaults
                var name: String? = nil
                if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                    name = "\(givenName) \(familyName)"
                } else if let givenName = fullName?.givenName {
                    name = givenName
                } else if let familyName = fullName?.familyName {
                    name = familyName
                } else {
                    // Récupérer depuis UserDefaults si disponible
                    name = UserDefaults.standard.string(forKey: "apple_user_name")
                }
                
                print("✅ Connexion Apple réussie - ID: \(userIdentifier)")
                print("📧 Email: \(email ?? "non disponible")")
                print("👤 Nom: \(name ?? "non disponible")")
                
                // Sauvegarder via le service sur le thread principal
                Task { @MainActor in
                    authService.saveUser(identifier: userIdentifier, email: email, name: name)
                    
                    // Vérifier que l'état est bien mis à jour
                    print("🔍 État d'authentification après sauvegarde: \(authService.isAuthenticated)")
                    
                    // Attendre un peu pour s'assurer que l'état est propagé
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
                    
                    // Fermer automatiquement la vue de connexion après succès
                    dismiss()
                }
            } else {
                print("❌ Le credential n'est pas un ASAuthorizationAppleIDCredential")
                errorMessage = "Type de credential non supporté"
                showError = true
            }
        case .failure(let error):
            let errorDescription = error.localizedDescription
            errorMessage = errorDescription
            showError = true
            print("❌ Erreur de connexion: \(errorDescription)")
            
            // Afficher plus de détails sur l'erreur
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
                    print("⚠️ Erreur inconnue (code: \(authError.code.rawValue))")
                }
            }
        }
    }
}


#Preview {
    LoginView()
}

