//
//  ProfileView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
import AVKit

struct ProfileView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedContentType: ContentType = .image
    @State private var showLoginView = false
    @State private var showSubscriptionView = false
    
    enum ContentType {
        case image
        case video
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 12) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text("World-Creat")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Carte utilisateur
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Text(appState.userInitials)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if appState.isAuthenticated {
                                Text("Connecté en tant que")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(appState.userEmail?.isEmpty == false ? appState.userEmail! : (appState.userName?.isEmpty == false ? appState.userName! : "Utilisateur"))
                                    .textSelection(.enabled)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            } else {
                                Text("Non connecté")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("Connectez-vous pour sauvegarder vos créations")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        // Bouton crédits
                        Button(action: {
                            showSubscriptionView = true
                        }) {
                            Text("\(appState.userCredits) crédits")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // Boutons actions
                    if appState.isAuthenticated {
                        HStack(spacing: 12) {
                            Button(action: {
                                appState.signOut()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16))
                                    Text("Se déconnecter")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                appState.deleteAccount()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                    Text("Supprimer mon compte")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }
                    } else {
                        Button(action: {
                            showLoginView = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 16))
                                Text("Se connecter avec Apple")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Tabs Image/Video
                HStack(spacing: 0) {
                    Button(action: {
                        selectedContentType = .image
                    }) {
                        Text("Image")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedContentType == .image ?
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Button(action: {
                        selectedContentType = .video
                    }) {
                        Text("Video")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedContentType == .video ?
                                LinearGradient(
                                    colors: [Color.pink, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear, Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Section Historique améliorée (uniquement si connecté)
                if appState.isAuthenticated {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Historique")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            if !appState.generationHistory.isEmpty {
                                Text("\(appState.generationHistory.count) créations")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if appState.generationHistory.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("Aucune création pour le moment")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            let filteredHistory = appState.generationHistory.filter { item in
                                switch selectedContentType {
                                case .image: return item.type == .image
                                case .video: return item.type == .video
                                }
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredHistory) { item in
                                    ProfileHistoryGridCard(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } else {
                    // Message si non connecté
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Historique")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.3))
                            Text("Connectez-vous pour voir votre historique")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.top, 8)
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showLoginView) {
            LoginView()
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
    }
}

// Carte compacte pour la grille
struct ProfileHistoryGridCard: View {
    let item: GenerationItem
    @State private var showFullScreen = false
    @State private var isDownloading = false
    @State private var showDownloadSuccess = false
    
    var body: some View {
        Button(action: {
            showFullScreen = true
        }) {
            ZStack(alignment: .bottomTrailing) {
                // Aperçu de la création
                Group {
                    if let urlString = item.resultURL, let url = URL(string: urlString) {
                        if item.type == .image {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    placeholderView
                                @unknown default:
                                    placeholderView
                                }
                            }
                        } else {
                            // Pour les vidéos, on affiche un thumbnail avec icône play
                            ZStack {
                                // Fond avec gradient pour les vidéos
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Icône play centrée
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    } else {
                        placeholderView
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .clipped()
                
                // Overlay avec bouton télécharger
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                await downloadItem()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 36, height: 36)
                                if isDownloading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(isDownloading || item.resultURL == nil)
                    }
                    .padding(8)
                }
            }
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showFullScreen) {
            HistoryItemDetailView(item: item)
        }
        .alert("Téléchargement réussi !", isPresented: $showDownloadSuccess) {
            Button("OK") { }
        } message: {
            Text("Votre création a été sauvegardée dans votre galerie photo.")
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: item.type == .video ?
                            [Color.purple.opacity(0.3), Color.pink.opacity(0.2)] :
                            [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: item.type == .video ? "play.circle.fill" : "photo.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var videoPlaceholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func downloadItem() async {
        guard let urlString = item.resultURL else { return }
        
        isDownloading = true
        
        do {
            if item.type == .image {
                try await DownloadService.shared.downloadAndSaveImage(from: urlString)
            } else {
                try await DownloadService.shared.downloadAndSaveVideo(from: urlString)
            }
            showDownloadSuccess = true
        } catch {
            print("Erreur lors du téléchargement: \(error.localizedDescription)")
        }
        
        isDownloading = false
    }
}

// Vue détaillée en plein écran
struct HistoryItemDetailView: View {
    let item: GenerationItem
    @Environment(\.dismiss) private var dismiss
    @State private var isDownloading = false
    @State private var showDownloadSuccess = false
    @State private var videoPlayer: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header avec bouton fermer
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Bouton télécharger
                    Button(action: {
                        Task {
                            await downloadItem()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isDownloading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(isDownloading ? "Téléchargement..." : "Télécharger")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isDownloading || item.resultURL == nil)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Contenu
                ScrollView {
                    VStack(spacing: 24) {
                        // Aperçu de la création
                        if let urlString = item.resultURL, let url = URL(string: urlString) {
                            if item.type == .image {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(16)
                                    case .failure, .empty:
                                        placeholderView
                                    @unknown default:
                                        placeholderView
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            } else {
                                // Lecteur vidéo pour les vidéos
                                Group {
                                    if let player = videoPlayer {
                                        VideoPlayer(player: player)
                                            .frame(height: 400)
                                            .cornerRadius(16)
                                    } else {
                                        ProgressView()
                                            .frame(height: 400)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .onAppear {
                                    if videoPlayer == nil {
                                        videoPlayer = AVPlayer(url: url)
                                    }
                                }
                                .onDisappear {
                                    videoPlayer?.pause()
                                }
                            }
                        } else {
                            placeholderView
                                .padding(.horizontal, 20)
                        }
                        
                        // Informations
                        VStack(alignment: .leading, spacing: 16) {
                            // Modèle
                            HStack {
                                Text("Modèle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text(item.model)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.purple)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Prompt
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prompt")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(item.prompt)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Date
                            HStack {
                                Text("Créé le")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                                Text(item.createdAt, style: .date)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(20)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .alert("Téléchargement réussi !", isPresented: $showDownloadSuccess) {
            Button("OK") { }
        } message: {
            Text("Votre création a été sauvegardée dans votre galerie photo.")
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: item.type == .video ? "play.circle.fill" : "photo.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.5))
            Text("Aperçu non disponible")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(16)
    }
    
    private func downloadItem() async {
        guard let urlString = item.resultURL else { return }
        
        isDownloading = true
        
        do {
            if item.type == .image {
                try await DownloadService.shared.downloadAndSaveImage(from: urlString)
            } else {
                try await DownloadService.shared.downloadAndSaveVideo(from: urlString)
            }
            showDownloadSuccess = true
        } catch {
            print("Erreur lors du téléchargement: \(error.localizedDescription)")
        }
        
        isDownloading = false
    }
}

#Preview {
    ProfileView()
}

