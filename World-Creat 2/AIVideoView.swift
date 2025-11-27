//
//  AIVideoView.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import PhotosUI

struct AIVideoView: View {
    @Environment(\.dismiss) private var dismiss
    var selectedTab: Binding<AppTab>?
    @StateObject private var openAIService = OpenAIService.shared
    @StateObject private var appState = AppState.shared
    @State private var selectedFormat: VideoFormat = .landscape
    @State private var promptText = ""
    @State private var startingImage: PlatformImage?
    @State private var showImagePicker = false
    @State private var showVideoResult = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var generatedVideoURL: String?
    @State private var isDownloading = false
    @State private var showDownloadSuccess = false
    
    init(selectedTab: Binding<AppTab>? = nil) {
        self.selectedTab = selectedTab
    }
    
    private var buttonBackgroundColor: Color {
        startingImage != nil ? Color.green.opacity(0.3) : Color(red: 0.15, green: 0.15, blue: 0.15)
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
                            Text("AI Model")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    
                        Menu {
                            ForEach(VideoModel.allCases, id: \.self) { model in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        appState.selectedVideoModel = model
                                    }
                                }) {
                                    HStack {
                                        Text(model.rawValue)
                                        if appState.selectedVideoModel == model {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.purple)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(appState.selectedVideoModel.rawValue)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Section Format vidéo compacte
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Text("Format vidéo")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            FormatRadioButton(
                                format: .landscape,
                                label: "Format paysage",
                                selectedFormat: $selectedFormat
                            )
                            
                            FormatRadioButton(
                                format: .portrait,
                                label: "Format portrait",
                                selectedFormat: $selectedFormat
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Section Prompt compacte
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "video.fill")
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                promptText.isEmpty ? Color.white.opacity(0.1) : Color.purple.opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                                
                                if promptText.isEmpty {
                                    Text("Décrivez votre vidéo...")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 22)
                                        .allowsHitTesting(false)
                                }
                            }
                            
                            Button(action: {
                                showImagePicker = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 12))
                                    Text("Image départ")
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
                        
                        if let image = startingImage {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    StartingImagePreview(
                                        image: image,
                                        onRemove: {
                                            startingImage = nil
                                        }
                                    )
                                }
                                .padding(.horizontal, 10)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Espace pour le bouton fixe
                    Spacer(minLength: 100)
                }
            }
            
            // Bouton générer fixe en bas
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                        if !promptText.isEmpty && openAIService.generationStatus != .generating {
                            generateVideo()
                        }
                    }) {
                        HStack(spacing: 10) {
                            if openAIService.generationStatus == .generating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                                Text("Génération...")
                                    .font(.system(size: 17, weight: .semibold))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Générer")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if promptText.isEmpty || openAIService.generationStatus == .generating {
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
                                    promptText.isEmpty || openAIService.generationStatus == .generating ? Color.clear : Color.purple.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: promptText.isEmpty || openAIService.generationStatus == .generating ? .clear : .purple.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(promptText.isEmpty || openAIService.generationStatus == .generating)
                    
                    Button(action: {
                        downloadVideo()
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
                                if !hasVideoToDownload || isDownloading {
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
                                    !hasVideoToDownload || isDownloading ? Color.clear : Color.purple.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: !hasVideoToDownload || isDownloading ? .clear : .purple.opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    }
                    .disabled(!hasVideoToDownload || isDownloading)
                }
                .padding(.horizontal, 20)
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
            ImagePicker(image: $startingImage)
        }
        .alert("Vidéo générée !", isPresented: $showVideoResult) {
            Button("OK") {
                showVideoResult = false
            }
        } message: {
            Text("Votre vidéo a été générée avec succès !")
        }
        .alert("Erreur", isPresented: $showError) {
            Button("OK") {
                openAIService.resetStatus()
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .alert("Téléchargement réussi !", isPresented: $showDownloadSuccess) {
            Button("OK") {
                showDownloadSuccess = false
            }
        } message: {
            #if canImport(UIKit)
            Text("La vidéo a été sauvegardée dans votre galerie photo.")
            #else
            Text("La vidéo a été sauvegardée dans votre dossier Téléchargements.")
            #endif
        }
        .onChange(of: openAIService.generationStatus) { oldValue, newValue in
            handleStatusChange(newValue)
        }
    }
    
    // Fonction pour télécharger la vidéo
    private func downloadVideo() {
        // Utiliser generatedVideoURL local ou celui du service
        let videoURL = generatedVideoURL ?? openAIService.generatedVideoURL
        
        guard let url = videoURL else {
            errorMessage = "Aucune vidéo à télécharger. Veuillez d'abord générer une vidéo."
            showError = true
            return
        }
        
        isDownloading = true
        
        Task {
            do {
                try await DownloadService.shared.downloadAndSaveVideo(from: url)
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
    
    // Propriété calculée pour vérifier si une vidéo est disponible
    private var hasVideoToDownload: Bool {
        generatedVideoURL != nil || openAIService.generatedVideoURL != nil
    }
    
    // Fonction pour gérer le changement de statut
    private func handleStatusChange(_ status: GenerationStatus) {
        if case .error(let message) = status {
            errorMessage = message
            showError = true
        }
    }
    
    // Fonction pour générer la vidéo
    private func generateVideo() {
        guard !promptText.isEmpty else {
            errorMessage = "Veuillez entrer un prompt."
            showError = true
            return
        }
        
        // Vérifier et déduire les crédits
        let cost = appState.getGenerationCost(for: .video, model: appState.selectedVideoModel.rawValue)
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
        
        Task {
            do {
                let videoURL = try await openAIService.generateVideo(
                    prompt: promptText,
                    format: selectedFormat,
                    startingImage: startingImage,
                    model: appState.selectedVideoModel.rawValue
                )
                
                await MainActor.run {
                    generatedVideoURL = videoURL
                    showVideoResult = true
                    // Ajouter à l'historique
                    appState.generationHistory.insert(
                        GenerationItem(
                            type: .video,
                            prompt: promptText,
                            resultURL: videoURL,
                            createdAt: Date(),
                            model: appState.selectedVideoModel.rawValue
                        ),
                        at: 0
                    )
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    // Rembourser les crédits en cas d'erreur
                    appState.addCredits(deductedCost)
                }
            }
        }
    }
}

struct VideoModelSelectionCard: View {
    let model: VideoModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: model.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(model.description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.purple)
                }
            }
            .padding(16)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
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

struct GenerateVideoButton: View {
    let isGenerating: Bool
    let prompt: String
    let format: VideoFormat
    let startingImage: PlatformImage?
    let onGenerate: () -> Void
    
    var body: some View {
        Button(action: {
            if !prompt.isEmpty && !isGenerating {
                onGenerate()
            }
        }) {
            HStack(spacing: 0) {
                // Partie gauche - Générer
                HStack {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Génération...")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Générer")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Group {
                        if prompt.isEmpty || isGenerating {
                            Color.gray.opacity(0.5)
                        } else {
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                
                // Partie droite - Coins
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("1310")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
        }
        .disabled(prompt.isEmpty || isGenerating)
        .cornerRadius(16)
        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

// Image Picker pour sélectionner une image de départ
#if canImport(UIKit)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: PlatformImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#endif

// Composant pour les boutons radio de format
struct FormatRadioButton: View {
    let format: VideoFormat
    let label: String?
    @Binding var selectedFormat: VideoFormat
    
    var isSelected: Bool {
        selectedFormat == format
    }
    
    var displayLabel: String {
        label ?? format.rawValue
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedFormat = format
            }
        }) {
            HStack(spacing: 12) {
                RadioButtonCircle(isSelected: isSelected, format: format)
                
                Text(displayLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isSelected {
                        Color(red: 0.2, green: 0.15, blue: 0.3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                            )
                    } else {
                        Color(red: 0.15, green: 0.15, blue: 0.15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RadioButtonCircle: View {
    let isSelected: Bool
    let format: VideoFormat
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 24, height: 24)
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
            } else {
                if format == .portrait {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .stroke(Color.purple, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

struct StartingImagePreview: View {
    let image: PlatformImage
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
    AIVideoView()
}

