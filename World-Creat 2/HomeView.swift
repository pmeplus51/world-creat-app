//
//  HomeView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
import AVKit
import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct HomeView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedModelIndex: Int = 0
    @State private var showCreateImage = false
    @State private var showCreateVideo = false
    @State private var selectedVideoModel: VideoModel = .sora2
    @State private var viewId = UUID()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header amélioré
                HeaderView(credits: appState.userCredits, appState: appState)
                    .padding(.top, 8)
                
                // Titre accrocheur
                VStack(alignment: .leading, spacing: 8) {
                    Text("Les Trends IA Virales")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Faciles et Rapides")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Créez des vidéos virales en 2 minutes depuis votre téléphone")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Section "Pourquoi World-Creat est Indispensable"
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pourquoi World-Creat est Indispensable")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    // Grille de cartes d'avantages
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        FeatureCard(
                            icon: "bolt.fill",
                            iconColor: .purple,
                            title: "Modèles IA de Pointe",
                            description: "Accès aux meilleurs modèles IA du marché pour une qualité professionnelle"
                        )
                        
                        FeatureCard(
                            icon: "video.fill",
                            iconColor: .blue,
                            title: "Génération Texte en Vidéo",
                            description: "Créez des vidéos professionnelles à partir de simples descriptions textuelles"
                        )
                        
                        FeatureCard(
                            icon: "photo.on.rectangle.angled",
                            iconColor: .green,
                            title: "Transformation Image en Vidéo",
                            description: "Animez vos images de produits pour créer des vidéos captivantes"
                        )
                        
                        FeatureCard(
                            icon: "sparkles",
                            iconColor: .orange,
                    title: "Retouche Photo IA",
                    description: "Avec Nano Banana, retouchez photos et screenshots avec un simple prompt"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
                
                // Section modèles AI avec navigation
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Modèles IA")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60, height: 3)
                                .cornerRadius(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Carte Sora 2
                            ModelCard(
                                model: .video(.sora2),
                                isSelected: selectedModelIndex == 0,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedModelIndex = 0
                                        appState.selectedVideoModel = .sora2
                                        selectedVideoModel = .sora2
                                        showCreateVideo = true
                                    }
                                }
                            )
                            .id("sora2-\(viewId)")
                            
                            // Carte Nano Banana
                            ModelCard(
                                model: .image(.nanoBanana),
                                isSelected: selectedModelIndex == 1,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedModelIndex = 1
                                        appState.selectedAIModel = .nanoBanana
                                        showCreateImage = true
                                    }
                                }
                            )
                            .id("nanobanana-\(viewId)")
                            
                            // Carte Veo 3
                            ModelCard(
                                model: .video(.veo3),
                                isSelected: selectedModelIndex == 2,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedModelIndex = 2
                                        appState.selectedVideoModel = .veo3
                                        selectedVideoModel = .veo3
                                        showCreateVideo = true
                                    }
                                }
                            )
                            .id("veo3-\(viewId)")
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Section "Créations récentes"
                if !appState.generationHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Créations récentes")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Button("Voir tout") {
                                // Navigation vers historique
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(appState.generationHistory.prefix(5)) { item in
                                    HistoryCard(item: item)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                // Section "Texte en Vidéo"
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Texte en Vidéo")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60, height: 3)
                                .cornerRadius(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        alignment: .center,
                        spacing: 16
                    ) {
                        TextToVideoCard()
                        ImageToVideoCard()
                    }
                    .padding(.horizontal, 20)
                }
                
                // Section "Image en Vidéo"
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Image en Vidéo")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60, height: 3)
                                .cornerRadius(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        alignment: .center,
                        spacing: 16
                    ) {
                        ImageToVideoImageCard()
                        ImageToVideoVideoCard()
                    }
                    .padding(.horizontal, 20)
                }
                
                // Section "Modification d'image"
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Modification d'image")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60, height: 3)
                                .cornerRadius(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        alignment: .center,
                        spacing: 16
                    ) {
                        ModificationBeforeCard()
                        ModificationAfterCard()
                    }
                    .padding(.horizontal, 20)
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
        .fullScreenCover(isPresented: $showCreateImage) {
            CreateImageView()
        }
        .fullScreenCover(isPresented: $showCreateVideo) {
            AIVideoView()
        }
    }
}

struct HeaderView: View {
    let credits: Int
    @State private var showSubscriptionView = false
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                // Logo
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("World-Creat")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Générez avec l'IA")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            Button(action: {
                showSubscriptionView = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 14))
                    Text("\(credits) crédits")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
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
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
                .environmentObject(appState)
        }
    }
}

enum ModelType {
    case image(AIModel)
    case video(VideoModel)
}

struct ModelCard: View {
    let model: ModelType
    let isSelected: Bool
    let action: () -> Void
    @State private var veo3Player: AVQueuePlayer?
    @State private var veo3PlayerLooper: AVPlayerLooper?
    @State private var sora2Player: AVQueuePlayer?
    @State private var sora2PlayerLooper: AVPlayerLooper?
    
    var title: String {
        switch model {
        case .image(let aiModel): return aiModel.rawValue
        case .video(let videoModel): return videoModel.rawValue
        }
    }
    
    var icon: String {
        switch model {
        case .image(let aiModel): return aiModel.icon
        case .video(let videoModel): return videoModel.icon
        }
    }
    
    // Vérifier si c'est Sora 2
    private var isSora2: Bool {
        if case .video(let videoModel) = model {
            return videoModel == VideoModel.sora2
        }
        return false
    }
    
    // Vérifier si c'est Veo 3
    private var isVeo3: Bool {
        if case .video(let videoModel) = model {
            return videoModel == VideoModel.veo3
        }
        return false
    }
    
    // Vérifier si c'est un modèle vidéo (Sora 2 ou Veo 3) pour afficher l'image spéciale
    private var isVideoModel: Bool {
        return isSora2 || isVeo3
    }
    
    // Vérifier si c'est Nano Banana
    private var isNanoBanana: Bool {
        if case .image(let aiModel) = model {
            return aiModel == AIModel.nanoBanana
        }
        return false
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if isVideoModel {
                        ZStack {
                            if isVeo3 {
                                // Afficher la vidéo pour Veo 3
                                if let player = veo3Player {
                                    CustomVideoPlayer(player: player)
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    videoModelFallback
                                }
                            } else if isSora2 {
                                // Afficher la vidéo pour Sora 2
                                if let player = sora2Player {
                                    CustomVideoPlayer(player: player)
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    videoModelFallback
                                }
                            }
                        }
                        .frame(width: 200, height: 280)
                        .clipped()
                        .cornerRadius(16)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                        .overlay(
                            // Bouton play transparent au centre
                            ZStack {
                                // Cercle avec fond semi-transparent et bordure
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 64, height: 64)
                                
                                Circle()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                    .frame(width: 64, height: 64)
                                
                                // Icône play
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .offset(x: 3) // Légèrement décalé pour l'effet visuel
                            }
                        )
                        .onAppear {
                            // Forcer un rechargement complet à chaque fois pour s'assurer que les vidéos s'affichent
                            if isVeo3 {
                                // Nettoyer l'ancien player
                                veo3Player?.pause()
                                veo3Player = nil
                                veo3PlayerLooper = nil
                                
                                // Petit délai pour s'assurer que le nettoyage est terminé
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    loadVeo3Video()
                                }
                            } else if isSora2 {
                                // Nettoyer l'ancien player
                                sora2Player?.pause()
                                sora2Player = nil
                                sora2PlayerLooper = nil
                                
                                // Petit délai pour s'assurer que le nettoyage est terminé
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    loadSora2Video()
                                }
                            }
                        }
                        .onDisappear {
                            if isVeo3 {
                                veo3Player?.pause()
                                veo3Player?.seek(to: .zero)
                                // Ne pas détruire le player, juste le mettre en pause
                            } else if isSora2 {
                                sora2Player?.pause()
                                sora2Player?.seek(to: .zero)
                                // Ne pas détruire le player, juste le mettre en pause
                            }
                        }
                    } else if isNanoBanana {
                        // Afficher l'image banana pour Nano Banana
                        ZStack {
                            if let bananaImage = loadBananaImage() {
                                bananaImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: isSelected ? 
                                                [Color.purple.opacity(0.4), Color.pink.opacity(0.2)] :
                                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .frame(width: 200, height: 280)
                        .clipped()
                        .cornerRadius(16)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: isSelected ? 
                                        [Color.purple.opacity(0.4), Color.pink.opacity(0.2)] :
                                        [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 280)
                            .scaleEffect(isSelected ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    }
                    
                    // Overlay pour la bordure sélectionnée
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
                        .frame(width: 200, height: 280)
                    
                    // Icône en bas à gauche (seulement si ce n'est pas Veo 3)
                    if !isVeo3 {
                        if icon == "🍌" {
                            Text(icon)
                                .font(.system(size: 32))
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .blur(radius: 10)
                                )
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                                .padding(12)
                        }
                    }
                    
                    // Badge sélectionné
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.purple)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(12)
                    }
                }
                .frame(width: 200, height: 280)
                .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(modelTypeDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 12)
                .frame(width: 200, alignment: .leading)
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var modelTypeDescription: String {
        switch model {
        case .image(let aiModel): return aiModel.description
        case .video(let videoModel): return videoModel.description
        }
    }
}

extension ModelCard {
    private func loadVeo3Video() {
        let baseNames = [
            "video-komboucha",
            "video-kombucha",
            "veo3_video",
            "veo3-video",
            "kombucha-video"
        ]
        let extensions = ["mp4", "mov", "m4v", "MP4", "MOV"]
        
        func setupPlayer(with url: URL) {
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            queuePlayer.isMuted = true
            queuePlayer.volume = 0
            
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            veo3PlayerLooper = looper
            veo3Player = queuePlayer
            queuePlayer.play()
            print("✅ Vidéo Veo 3 chargée: \(url.path)")
        }
        
        // Essayer avec fichier direct
        for baseName in baseNames {
            if let directURL = Bundle.main.url(forResource: baseName, withExtension: nil) {
                setupPlayer(with: directURL)
                return
            }
            
            // Essayer avec extensions
            for ext in extensions {
                if let videoURL = Bundle.main.url(forResource: baseName, withExtension: ext) {
                    setupPlayer(with: videoURL)
                    return
                }
            }
        }
        
        // Essayer avec NSDataAsset
        #if canImport(UIKit)
        for baseName in baseNames {
            if let dataAsset = NSDataAsset(name: baseName) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                
                do {
                    try dataAsset.data.write(to: tempURL)
                    setupPlayer(with: tempURL)
                    return
                } catch {
                    print("❌ Erreur lors de l'écriture du fichier temporaire: \(error)")
                }
            }
        }
        #endif
        
        print("❌ Vidéo Veo 3 introuvable (testés: \(baseNames.joined(separator: ", ")))")
    }
    
    private func loadSora2Video() {
        let baseNames = [
            "sora2",
            "sora2_video",
            "sora2-video",
            "sora_2",
            "sora_2_video",
            "Sora2",
            "Sora 2"
        ]
        let extensions = ["mp4", "mov", "m4v", "MP4", "MOV", "M4V"]
        
        func setupPlayer(with url: URL) {
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            queuePlayer.isMuted = true
            queuePlayer.volume = 0
            
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            sora2PlayerLooper = looper
            sora2Player = queuePlayer
            queuePlayer.play()
            print("✅ Vidéo Sora 2 chargée: \(url.path)")
        }
        
        print("🔍 Recherche de la vidéo Sora 2...")
        
        // Essayer avec NSDataAsset en premier (pour les Data Assets dans Assets.xcassets)
        #if canImport(UIKit)
        for baseName in baseNames {
            if let dataAsset = NSDataAsset(name: baseName) {
                print("✅ Data Asset '\(baseName)' trouvé, taille: \(dataAsset.data.count) bytes")
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                
                do {
                    try dataAsset.data.write(to: tempURL)
                    print("✅ Fichier temporaire créé: \(tempURL.path)")
                    setupPlayer(with: tempURL)
                    return
                } catch {
                    print("❌ Erreur lors de l'écriture du fichier temporaire: \(error)")
                }
            }
        }
        #endif
        
        // Essayer avec fichier direct
        for baseName in baseNames {
            if let directURL = Bundle.main.url(forResource: baseName, withExtension: nil) {
                print("✅ Vidéo '\(baseName)' trouvée (sans extension): \(directURL.path)")
                setupPlayer(with: directURL)
                return
            }
            
            // Essayer avec extensions
            for ext in extensions {
                if let videoURL = Bundle.main.url(forResource: baseName, withExtension: ext) {
                    print("✅ Vidéo '\(baseName)' trouvée avec extension \(ext): \(videoURL.path)")
                    setupPlayer(with: videoURL)
                    return
                }
            }
        }
        
        let triedNames = baseNames.joined(separator: ", ")
        print("❌ Vidéo Sora 2 introuvable (testés: \(triedNames))")
    }
    
    private var videoModelImage: Image? {
#if canImport(UIKit)
        if isSora2 {
            if let uiImage = UIImage(named: "sora2_homme") {
                return Image(uiImage: uiImage)
            } else {
                print("⚠️ Image 'sora2_homme' introuvable dans le bundle")
            }
        } else if isVeo3 {
            if let uiImage = UIImage(named: "veo3_kombucha") {
                return Image(uiImage: uiImage)
            } else {
                print("⚠️ Image 'veo3_kombucha' introuvable dans le bundle")
            }
        }
#elseif canImport(AppKit)
        if isSora2 {
            if let nsImage = NSImage(named: "sora2_homme") {
                return Image(nsImage: nsImage)
            } else {
                print("⚠️ Image 'sora2_homme' introuvable (AppKit)")
            }
        } else if isVeo3 {
            if let nsImage = NSImage(named: "veo3_kombucha") {
                return Image(nsImage: nsImage)
            } else {
                print("⚠️ Image 'veo3_kombucha' introuvable (AppKit)")
            }
        }
#endif
        return nil
    }
    
    private var videoModelFallback: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: isSora2 ?
                        [Color.purple.opacity(0.4), Color.pink.opacity(0.2)] :
                        [Color.green.opacity(0.4), Color.green.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private func loadBananaImage() -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "banana") {
            return Image(uiImage: uiImage)
        } else {
            print("⚠️ Image 'banana' introuvable dans le bundle")
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(named: "banana") {
            return Image(nsImage: nsImage)
        } else {
            print("⚠️ Image 'banana' introuvable (AppKit)")
        }
        #endif
        return nil
    }
}

struct HistoryCard: View {
    let item: GenerationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Aperçu
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    Group {
                        if item.type == .video {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.model)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(item.prompt)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
    }
}

struct TextToVideoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Soldat en plein champ de bataille, caméra épaule immersive avec grains cinéma. Fumée, flammes, mouvement nerveux, ambiance sombre inspirée des films de guerre modernes.")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(16)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(12)
    }
}

struct ImageToVideoCard: View {
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(maxWidth: .infinity, minHeight: 200)
            
            // Afficher la vidéo si disponible
            if let player = player {
                CustomVideoPlayer(player: player)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .cornerRadius(12)
                    .clipped()
                    .onAppear {
                        setupVideoLoop(player: player)
                        // Démarrer la lecture immédiatement
                        DispatchQueue.main.async {
                            player.play()
                            print("▶️ Lecture de la vidéo démarrée")
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                // Fallback : gradient si la vidéo n'est pas trouvée
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(maxWidth: .infinity, minHeight: 200)
                    
                    // Indicateur de chargement ou erreur
                    VStack(spacing: 8) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Vidéo non trouvée")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .onAppear {
            if player == nil {
                loadVideo()
            } else {
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
            player?.seek(to: .zero)
            // Nettoyer les observers
            if let currentItem = player?.currentItem {
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: currentItem
                )
            }
        }
    }
    
    private func loadVideo() {
        // Charger la vidéo depuis le bundle
        // Le fichier s'appelle "texte_en_video"
        
        print("🔍 Tentative de chargement de la vidéo 'texte_en_video'")
        
        // Méthode 1 : Essayer avec différentes extensions (sans extension d'abord)
        if let videoURL = Bundle.main.url(forResource: "texte_en_video", withExtension: nil) {
            print("✅ Vidéo trouvée dans le bundle (sans extension): \(videoURL.path)")
            let newPlayer = createMutedPlayer(with: videoURL)
            configurePlayerForLoop(player: newPlayer)
            player = newPlayer
            return
        }
        
        // Méthode 2 : Essayer avec différentes extensions
        let extensions = ["mp4", "mov", "m4v", "MOV", "MP4", "m4v"]
        for ext in extensions {
            if let videoURL = Bundle.main.url(forResource: "texte_en_video", withExtension: ext) {
                print("✅ Vidéo trouvée avec extension \(ext): \(videoURL.path)")
                let newPlayer = createMutedPlayer(with: videoURL)
                configurePlayerForLoop(player: newPlayer)
                player = newPlayer
                return
            }
        }
        
        // Méthode 3 : Essayer avec le nom avec espace (au cas où)
        if let videoURL = Bundle.main.url(forResource: "texte en video", withExtension: nil) {
            print("✅ Vidéo trouvée avec nom avec espace: \(videoURL.path)")
            let newPlayer = createMutedPlayer(with: videoURL)
            configurePlayerForLoop(player: newPlayer)
            player = newPlayer
            return
        }
        
        // Méthode 4 : Essayer avec NSDataAsset (si dans Assets.xcassets)
        #if canImport(UIKit)
        if let dataAsset = NSDataAsset(name: "texte_en_video") {
            print("✅ Data Set trouvé, taille: \(dataAsset.data.count) bytes")
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            do {
                try dataAsset.data.write(to: tempURL)
                print("✅ Fichier temporaire créé: \(tempURL.path)")
                let newPlayer = createMutedPlayer(with: tempURL)
                configurePlayerForLoop(player: newPlayer)
                player = newPlayer
                print("✅ AVPlayer créé avec succès")
                return
            } catch {
                print("❌ Erreur lors de l'écriture du fichier temporaire: \(error)")
            }
        }
        #endif
        
        // Si la vidéo n'est pas trouvée, player reste nil et le fallback s'affiche
        print("❌ Vidéo 'texte_en_video' non trouvée dans le bundle")
        print("📦 Bundle path: \(Bundle.main.bundlePath)")
    }
    
    private func createMutedPlayer(with url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        player.isMuted = true
        player.volume = 0
        return player
    }
    
    // Configurer le player pour la lecture en boucle
    private func configurePlayerForLoop(player: AVPlayer) {
        // Configurer pour la lecture en boucle
        player.actionAtItemEnd = .none
        
        // Observer la fin de la vidéo pour la relancer
        if let currentItem = player.currentItem {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
    
    // Configurer la boucle vidéo avec notification
    private func setupVideoLoop(player: AVPlayer) {
        // Configurer pour la lecture en boucle
        player.actionAtItemEnd = .none
        
        // Observer la fin de la vidéo pour la relancer
        if let currentItem = player.currentItem {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
}

// Vue personnalisée pour afficher une vidéo sans contrôles
#if canImport(UIKit)
struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        // Masquer les contrôles en désactivant les interactions
        view.isUserInteractionEnabled = false
        
        // Mettre à jour le frame quand la vue change de taille
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Mettre à jour le frame du playerLayer et le player
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
            // S'assurer que le player est toujours attaché
            if playerLayer.player != player {
                playerLayer.player = player
            }
        } else {
            // Si le layer n'existe pas, le recréer
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = uiView.bounds
            uiView.layer.addSublayer(playerLayer)
        }
    }
}
#elseif canImport(AppKit)
struct CustomVideoPlayer: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer?.addSublayer(playerLayer)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let playerLayer = nsView.layer?.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = nsView.bounds
        }
    }
}
#endif

struct ImageToVideoImageCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let showcaseImage = loadShowcaseImage() {
                showcaseImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .overlay(Color.black.opacity(0.15))
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.4), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                Text("Image 'chaussure' introuvable")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Image → Vidéo")
                    .font(.system(size: 16, weight: .semibold))
                Text("Image de départ transformée en vidéo animée par l'IA.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.1)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
    }
}

extension ImageToVideoImageCard {
    private func loadShowcaseImage() -> Image? {
#if canImport(UIKit)
        let assetNames = ["chaussure", "chaussure_image", "Sneaker"]
        for name in assetNames {
            if let uiImage = UIImage(named: name) {
                if name != "chaussure" {
                    print("ℹ️ Image showcase chargée via asset '\(name)'")
                }
                return Image(uiImage: uiImage)
            }
        }
        let joinedNames = assetNames.joined(separator: ", ")
        print("⚠️ Aucune image de chaussure trouvée dans les assets (\(joinedNames))")
#elseif canImport(AppKit)
        let assetNamesAppKit = ["chaussure", "chaussure_image", "Sneaker"]
        for name in assetNamesAppKit {
            if let nsImage = NSImage(named: name) {
                if name != "chaussure" {
                    print("ℹ️ Image showcase chargée via asset '\(name)' (AppKit)")
                }
                return Image(nsImage: nsImage)
            }
        }
        let joinedNamesAppKit = assetNamesAppKit.joined(separator: ", ")
        print("⚠️ Aucune image de chaussure trouvée (AppKit) (\(joinedNamesAppKit))")
#endif
        return nil
    }
}

struct ImageToVideoVideoCard: View {
    @State private var player: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.75))
                .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
            
            if let player = player {
                CustomVideoPlayer(player: player)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .cornerRadius(16)
                    .clipped()
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.5), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text("Chargement de la vidéo...")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Résultat vidéo")
                    .font(.system(size: 16, weight: .semibold))
                Text("Boucle IA dragon cinématique générée depuis l'image.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.75), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
        .onAppear {
            if player == nil {
                loadVideo()
            } else {
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
            player?.seek(to: .zero)
            // Nettoyer le looper (il sera automatiquement nettoyé quand on le met à nil)
            playerLooper = nil
        }
    }
    
    private func loadVideo() {
        let baseNames = [
            "chaussure-video",
            "chaussre-video",
            "chaussure_video",
            "chaussre_video",
            "dragon_video",
            "DragonVideo"
        ]
        let extensions = ["mp4", "mov", "m4v", "MP4", "MOV"]
        
        func setupPlayer(with url: URL) {
            let item = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: item)
            queuePlayer.isMuted = true
            queuePlayer.volume = 0
            
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            playerLooper = looper
            player = queuePlayer
            queuePlayer.play()
        }
        
        for baseName in baseNames {
            if let directURL = Bundle.main.url(forResource: baseName, withExtension: nil) {
                print("✅ Vidéo '\(baseName)' trouvée (sans extension)")
                setupPlayer(with: directURL)
                return
            }
        }
        
        for baseName in baseNames {
            for ext in extensions {
                if let url = Bundle.main.url(forResource: baseName, withExtension: ext) {
                    print("✅ Vidéo '\(baseName).\(ext)' trouvée")
                    setupPlayer(with: url)
                    return
                }
            }
        }
        
        #if canImport(UIKit)
        for baseName in baseNames {
            if let dataAsset = NSDataAsset(name: baseName) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                do {
                    try dataAsset.data.write(to: tempURL)
                    print("✅ Vidéo '\(baseName)' chargée depuis les assets (NSDataAsset)")
                    setupPlayer(with: tempURL)
                    return
                } catch {
                    print("❌ Impossible d'écrire la vidéo \(baseName): \(error)")
                }
            }
        }
        #endif
        
        let triedNames = baseNames.joined(separator: ", ")
        print("❌ Vidéo chaussure introuvable (testés: \(triedNames))")
    }
}

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icône avec fond coloré
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Titre
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            // Description
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(iconColor.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: iconColor.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct ModificationBeforeCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadImage(named: "sans_tour") {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 200, maxHeight: 200)
                    .overlay(Color.black.opacity(0.15))
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(minHeight: 200, maxHeight: 200)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Avant")
                    .font(.system(size: 16, weight: .semibold))
                Text("Photo originale sans la Tour Eiffel")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.1)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
        .frame(minHeight: 200, maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
        .fixedSize(horizontal: false, vertical: false)
    }
    
    private func loadImage(named: String) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: named) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(named: named) {
            return Image(nsImage: nsImage)
        }
        #endif
        print("⚠️ Image '\(named)' introuvable dans les assets")
        return nil
    }
}

struct ModificationAfterCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = loadImage(named: "avec_tour") {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 200, maxHeight: 200)
                    .overlay(Color.black.opacity(0.15))
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(minHeight: 200, maxHeight: 200)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Après")
                    .font(.system(size: 16, weight: .semibold))
                Text("Photo modifiée avec la Tour Eiffel")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.1)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .cornerRadius(16)
            )
        }
        .frame(minHeight: 200, maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
        .fixedSize(horizontal: false, vertical: false)
    }
    
    private func loadImage(named: String) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: named) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(named: named) {
            return Image(nsImage: nsImage)
        }
        #endif
        print("⚠️ Image '\(named)' introuvable dans les assets")
        return nil
    }
}

#Preview {
    HomeView()
}

// MARK: - Premium Tab Bar Component
enum AppTab: String, CaseIterable {
    case home = "Accueil"
    case createImage = "Créer Image"
    case createVideo = "Vidéo IA"
    case profile = "Profil"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .createImage: return "sparkles"
        case .createVideo: return "video.fill"
        case .profile: return "person.fill"
        }
    }
}

struct PremiumTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                    // Fermer le clavier quand on change d'onglet
                    #if canImport(UIKit)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    #endif
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24, weight: selectedTab == tab ? .semibold : .regular))
                            .symbolEffect(.bounce, value: selectedTab == tab)
                            .foregroundStyle(
                                selectedTab == tab ?
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .buttonStyle(TabButtonStyle(isSelected: selectedTab == tab))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 34)
        .background(
            // Effet glassmorphism (liquid glass)
            ZStack {
                // Fond avec blur
                RoundedRectangle(cornerRadius: 0)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                // Overlay avec gradient pour l'effet glass
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Bordure subtile en haut
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Spacer()
                }
            }
        )
        .overlay(
            // Bordure brillante subtile
            RoundedRectangle(cornerRadius: 0)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}

struct TabButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var homeViewId = UUID()
    
    var body: some View {
        ZStack {
            // Contenu principal selon l'onglet sélectionné
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Footer premium en overlay - collé en bas avec effet glassmorphism
            VStack {
                Spacer()
                PremiumTabBar(selectedTab: $selectedTab)
                    .background(
                        // Fond supplémentaire pour l'effet glass
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onChange(of: selectedTab) { oldValue, newValue in
            // Quand on revient sur l'onglet home, forcer la réinitialisation
            if newValue == .home && oldValue != .home {
                homeViewId = UUID()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .home:
            HomeView()
                .id(homeViewId)
        case .createImage:
            CreateImageView(selectedTab: $selectedTab)
        case .createVideo:
            AIVideoView(selectedTab: $selectedTab)
        case .profile:
            ProfileView()
        }
    }
}


