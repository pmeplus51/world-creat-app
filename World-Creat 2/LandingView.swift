//
//  LandingView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI

struct LandingView: View {
    @State private var showMainApp = false
    @AppStorage("hasSeenLanding") private var hasSeenLanding = false
    
    // État du chargement
    @State private var isLoading = true
    @State private var loadingProgress: CGFloat = 0
    
    // Animations
    @State private var logoScale: CGFloat = 0.8
    @State private var logoRotation: Double = 0
    @State private var logoOffset: CGFloat = 0
    @State private var pulseOpacity: Double = 0.3
    @State private var showContent = false
    
    var body: some View {
        Group {
            if showMainApp || hasSeenLanding {
                MainTabView()
            } else if isLoading {
                loadingScreen
            } else {
                landingContent
            }
        }
        .onAppear {
            // Si l'utilisateur a déjà vu la landing, aller directement à l'app
            if hasSeenLanding {
                showMainApp = true
            } else {
                // Démarrer le chargement
                startLoading()
            }
        }
    }
    
    // Écran de chargement
    private var loadingScreen: some View {
        ZStack {
            // Fond noir
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo animé pendant le chargement
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .purple.opacity(0.8), radius: 30, x: 0, y: 15)
                    .scaleEffect(logoScale)
                    .rotationEffect(.degrees(logoRotation))
                
                // Barre de progression
                VStack(spacing: 15) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Fond de la barre
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            // Barre de progression
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * loadingProgress, height: 6)
                                .animation(.linear(duration: 0.1), value: loadingProgress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 60)
                    
                    // Pourcentage
                    Text("\(Int(loadingProgress * 100))%")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
    
    private var landingContent: some View {
        ZStack {
            // Fond noir
            Color.black
                .ignoresSafeArea()
            
            // Effet de particules subtil en arrière-plan
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: CGFloat.random(in: 2...6))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }
            
            VStack(spacing: 50) {
                Spacer()
                
                // Logo avec animations
                ZStack {
                    // Effet de pulsation autour du logo
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(pulseOpacity), Color.pink.opacity(pulseOpacity)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 280, height: 280)
                        .blur(radius: 10)
                    
                    // Logo principal
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .shadow(color: .purple.opacity(0.8), radius: 30, x: 0, y: 15)
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(logoRotation))
                        .offset(y: logoOffset)
                }
                .opacity(showContent ? 1 : 0)
                
                // Contenu textuel avec animation
                VStack(spacing: 20) {
                    Text("World-Creat")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Créez des vidéos virales en 2 minutes")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("avec l'intelligence artificielle")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                
                Spacer()
                
                // Call to Action
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasSeenLanding = true
                        showMainApp = true
                    }
                }) {
                    HStack(spacing: 15) {
                        Text("Commencer")
                            .font(.system(size: 20, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .purple.opacity(0.5), radius: 25, x: 0, y: 15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
            }
        }
    }
    
    private func startLoading() {
        // Réinitialiser les valeurs
        logoScale = 0.8
        logoRotation = 0
        logoOffset = 0
        
        // Animation du logo pendant le chargement
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            logoScale = 1.1
        }
        
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            logoRotation = 360
        }
        
        // Simulation du chargement (2-3 secondes)
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if loadingProgress < 1.0 {
                loadingProgress += 0.02
            } else {
                timer.invalidate()
                // Transition vers la landing page
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                        // Réinitialiser pour les nouvelles animations
                        logoScale = 0.8
                        logoRotation = 0
                        startAnimations()
                    }
                }
            }
        }
    }
    
    private func startAnimations() {
        // Animation d'apparition du contenu
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            showContent = true
        }
        
        // Animation de scale (pulsation)
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            logoScale = 1.0
        }
        
        // Animation de rotation subtile
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            logoRotation = 360
        }
        
        // Animation de mouvement vertical (flottement)
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            logoOffset = -15
        }
        
        // Animation de pulsation de l'anneau
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseOpacity = 0.6
        }
    }
}

#Preview {
    LandingView()
}
