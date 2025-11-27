//
//  CreateImageView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI

struct CreateImageView: View {
    @Environment(\.dismiss) private var dismiss
    var selectedTab: Binding<AppTab>?
    @StateObject private var appState = AppState.shared
    @StateObject private var imageService = ImageGenerationService.shared
    @State private var promptText = ""
    @State private var uploadedImages: [PlatformImage] = []
    @State private var showImagePicker = false
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var generatedImageURL: String?
    @State private var isDownloading = false
    @State private var showDownloadSuccess = false
    
    init(selectedTab: Binding<AppTab>? = nil) {
        self.selectedTab = selectedTab
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Bouton Retour
                    HStack {
                        Button(action: {
                            // Si on est dans la navigation principale (via footer), changer l'onglet
                            if let selectedTab = selectedTab {
                                selectedTab.wrappedValue = .home
                            } else {
                                // Sinon, fermer le modal (via vignette)
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Retour")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Header compact
                    HeaderView(credits: appState.userCredits, appState: appState)
                        .padding(.top, 4)
                    
                    // Section AI Model compacte
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundColor(.purple)
                            Text("Modèle IA")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 10) {
                            ForEach(AIModel.allCases, id: \.self) { model in
                                ModelSelectionCard(
                                    model: model,
                                    isSelected: appState.selectedAIModel == model,
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            appState.selectedAIModel = model
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Section Prompt compacte
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Text("Prompt")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        ZStack(alignment: .bottomTrailing) {
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $promptText)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 160)
                                    .padding(14)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                    .cornerRadius(14)
                                
                                if promptText.isEmpty {
                                    Text("Décrivez votre image...")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 22)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            if uploadedImages.count < 2 {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 12))
                                        Text("\(uploadedImages.count)/2")
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.7), Color.pink.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                }
                                .padding(.bottom, 10)
                                .padding(.trailing, 10)
                            }
                            
                            if !uploadedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(uploadedImages.enumerated()), id: \.offset) { index, image in
                                            UploadedImagePreview(
                                                image: image,
                                                index: index,
                                                onRemove: {
                                                    uploadedImages.remove(at: index)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .padding(.bottom, 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Section Résultat de la génération
                    if let imageURL = generatedImageURL {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                Text("Résultat")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 300)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                        .cornerRadius(16)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .frame(maxHeight: 400)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                        )
                                case .failure:
                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.system(size: 40))
                                            .foregroundColor(.orange)
                                        Text("Erreur de chargement")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                                    .cornerRadius(16)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Espace pour le bouton fixe
                    Spacer(minLength: 100)
                }
            }
            
            // Boutons générer et télécharger fixe en bas
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    GenerateImageButton(
                        isGenerating: isGenerating,
                        prompt: promptText,
                        onGenerate: {
                            generateImage()
                        }
                    )
                    
                    DownloadImageButton(
                        isDownloading: isDownloading,
                        hasImageToDownload: generatedImageURL != nil,
                        onDownload: {
                            downloadImage()
                        }
                    )
                }
                .padding(.bottom, 90)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showImagePicker) {
            #if canImport(UIKit)
            ImagePicker(image: Binding(
                get: { uploadedImages.first },
                set: { if let img = $0 { uploadedImages = [img] } }
            ))
            #endif
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .alert("Téléchargement réussi !", isPresented: $showDownloadSuccess) {
            Button("OK") {
                showDownloadSuccess = false
            }
        } message: {
            #if canImport(UIKit)
            Text("L'image a été sauvegardée dans votre galerie photo.")
            #else
            Text("L'image a été sauvegardée dans votre dossier Téléchargements.")
            #endif
        }
    }
    
    private func downloadImage() {
        guard let imageURL = generatedImageURL else {
            errorMessage = "Aucune image à télécharger. Veuillez d'abord générer une image."
            showError = true
            return
        }
        
        isDownloading = true
        
        Task {
            do {
                try await DownloadService.shared.downloadAndSaveImage(from: imageURL)
                await MainActor.run {
                    isDownloading = false
                    showDownloadSuccess = true
                }
            } catch {
                await MainActor.run {
                    isDownloading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func generateImage() {
        guard !promptText.isEmpty else {
            errorMessage = "Veuillez entrer un prompt."
            showError = true
            return
        }
        
        // Vérifier et déduire les crédits
        let cost = appState.getGenerationCost(for: .image)
        guard appState.hasEnoughCredits(for: cost) else {
            errorMessage = "Vous n'avez pas assez de crédits. Veuillez en acheter."
            showError = true
            return
        }
        
        guard appState.deductCredits(cost) else {
            errorMessage = "Erreur lors de la déduction des crédits."
            showError = true
            return
        }
        
        let deductedCost = cost // Capturer le coût pour le remboursement en cas d'erreur
        isGenerating = true
        
        Task {
            do {
                // Appel au webhook N8N pour générer l'image
                let imageURL = try await imageService.generateImage(
                    prompt: promptText,
                    model: appState.selectedAIModel.rawValue,
                    referenceImages: uploadedImages
                )
                
                await MainActor.run {
                    isGenerating = false
                    generatedImageURL = imageURL
                    // Ajouter à l'historique
                    appState.generationHistory.insert(
                        GenerationItem(
                            type: .image,
                            prompt: promptText,
                            resultURL: imageURL,
                            createdAt: Date(),
                            model: appState.selectedAIModel.rawValue
                        ),
                        at: 0
                    )
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    // Utiliser le message d'erreur du service (déjà user-friendly)
                    if case .error(let message) = imageService.generationStatus {
                        errorMessage = message
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showError = true
                    // Rembourser les crédits en cas d'erreur
                    appState.addCredits(deductedCost)
                    imageService.resetStatus()
                }
            }
        }
    }
}

struct ModelSelectionCard: View {
    let model: AIModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(model.icon)
                    .font(.system(size: 20))
                Text(model.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color(red: 0.15, green: 0.15, blue: 0.15)
                    }
                }
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GenerateImageButton: View {
    let isGenerating: Bool
    let prompt: String
    let onGenerate: () -> Void
    
    var body: some View {
        Button(action: {
            if !prompt.isEmpty && !isGenerating {
                onGenerate()
            }
        }) {
            HStack(spacing: 12) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Génération...")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Générer")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 16))
                    Text("525")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Group {
                    if prompt.isEmpty || isGenerating {
                        Color.gray.opacity(0.4)
                    } else {
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        prompt.isEmpty || isGenerating ? Color.clear : Color.purple.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: prompt.isEmpty || isGenerating ? .clear : .purple.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(prompt.isEmpty || isGenerating)
        .padding(.horizontal, 20)
    }
}

struct DownloadImageButton: View {
    let isDownloading: Bool
    let hasImageToDownload: Bool
    let onDownload: () -> Void
    
    var body: some View {
        Button(action: {
            if hasImageToDownload && !isDownloading {
                onDownload()
            }
        }) {
            HStack(spacing: 8) {
                if isDownloading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(isDownloading ? "..." : "Télécharger")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(width: 140)
            .padding(.vertical, 16)
            .background(
                Group {
                    if !hasImageToDownload || isDownloading {
                        Color.gray.opacity(0.4)
                    } else {
                        LinearGradient(
                            colors: [Color.purple, Color.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        !hasImageToDownload || isDownloading ? Color.clear : Color.purple.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: !hasImageToDownload || isDownloading ? .clear : .purple.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!hasImageToDownload || isDownloading)
    }
}

struct UploadedImagePreview: View {
    let image: PlatformImage
    let index: Int
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            #if canImport(UIKit)
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            #elseif canImport(AppKit)
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
            #endif
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .offset(x: 5, y: -5)
        }
    }
}

#Preview {
    CreateImageView()
}

