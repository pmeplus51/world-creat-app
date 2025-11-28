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
                    handleSignInResult(result)
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
                
                // Sauvegarder via le service
                Task { @MainActor in
                    authService.saveUser(identifier: userIdentifier, email: email, name: name)
                    // Fermer automatiquement la vue de connexion après succès
                    dismiss()
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Erreur de connexion: \(error.localizedDescription)")
        }
    }
}


#Preview {
    LoginView()
}

