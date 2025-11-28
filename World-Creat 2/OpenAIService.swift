//
//  OpenAIService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import SwiftUI

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    @Published var generationStatus: GenerationStatus = .idle
    @Published var generatedVideoURL: String?
    
    private let session = URLSession.shared
    private let generationManager = GenerationManager.shared
    private let defaults = UserDefaults.standard
    private let isGeneratingVideoKey = "videoGenerationInProgress"
    private let currentJobIdKey = "currentVideoJobId"
    private let generatedVideoURLKey = "lastGeneratedVideoURL"
    
    private var pollingTask: Task<Void, Never>?
    
    private init() {
        // Restaurer l'état au démarrage
        restoreState()
    }
    
    private func restoreState() {
        // Si une génération était en cours, la reprendre
        if defaults.bool(forKey: isGeneratingVideoKey),
           let jobId = defaults.string(forKey: currentJobIdKey) {
            // Remettre le statut en génération
            Task { @MainActor in
                self.generationStatus = .generating
                _ = self.generationManager.startGeneration(type: .video)
            }
            
            // Reprendre le polling en arrière-plan
            pollingTask = Task.detached(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    // Reprendre le polling directement (on a déjà attendu 3 minutes avant)
                    _ = try await self.pollVideoStatus(jobId: jobId)
                } catch {
                    // L'erreur est déjà gérée dans pollVideoStatus
                }
            }
        }
        
        // Restaurer la dernière vidéo générée si elle existe
        if let url = defaults.string(forKey: generatedVideoURLKey) {
            generatedVideoURL = url
        }
    }
    
    private func saveState() {
        defaults.set(generationStatus == .generating, forKey: isGeneratingVideoKey)
        if case .generating = generationStatus {
            // Le jobId sera sauvegardé lors du démarrage du polling
        } else {
            defaults.removeObject(forKey: currentJobIdKey)
        }
        if let url = generatedVideoURL {
            defaults.set(url, forKey: generatedVideoURLKey)
        } else {
            defaults.removeObject(forKey: generatedVideoURLKey)
        }
        defaults.synchronize()
    }
    
    // Générer une vidéo avec Sora 2 ou Veo 3 via webhook N8N
    func generateVideo(
        prompt: String,
        format: VideoFormat,
        startingImage: PlatformImage? = nil,
        model: String = "Sora 2"
    ) async throws -> String {
        
        // Vérifier qu'aucune génération n'est en cours
        guard await generationManager.startGeneration(type: .video) else {
            let errorMessage = "Une génération est déjà en cours. Veuillez patienter."
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        await MainActor.run {
            self.generationStatus = .generating
        }
        
        // Déterminer l'aspect ratio selon le format
        let aspectRatio: String
        switch format {
        case .landscape:
            aspectRatio = "16:9"
        case .portrait:
            aspectRatio = "9:16"
        case .square:
            aspectRatio = "1:1"
        }
        
        // Générer un identifiant unique pour le job
        let jobId = "job_\(UUID().uuidString)"
        
        // Préparer la requête vers le webhook N8N
        guard let webhookURL = URL(string: APIConfig.videoGenerationURL) else {
            let errorMessage = "Configuration du serveur invalide. Veuillez contacter le support."
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
                self.generationManager.stopGeneration()
            }
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Créer le body de la requête pour le webhook
        var requestBody: [String: Any] = [
            "jobId": jobId,
            "prompt": prompt,
            "aspectRatio": aspectRatio,
            "model": model
        ]
        
        // Si une image de départ est fournie, la convertir en base64
        if let startingImage = startingImage {
            if let base64Image = imageToBase64(startingImage) {
                requestBody["starting_image"] = base64Image
            }
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            let errorMessage = "Erreur lors de la préparation de la requête"
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw error
        }
        
        // Effectuer la requête vers le webhook
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let errorMessage = "Réponse invalide du serveur"
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                }
                throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Sauvegarder le jobId et démarrer le polling après 3 minutes
                defaults.set(jobId, forKey: currentJobIdKey)
                defaults.set(true, forKey: isGeneratingVideoKey)
                defaults.synchronize()
                
                // Attendre 3 minutes puis commencer le polling
                try await Task.sleep(nanoseconds: 3 * 60 * 1_000_000_000) // 3 minutes
                
                // Démarrer le polling (continue en arrière-plan même si on change de page)
                return try await pollVideoStatus(jobId: jobId)
            } else {
                // Gérer les erreurs HTTP avec un message user-friendly
                let errorMessage = getErrorMessage(from: httpResponse.statusCode, responseData: data)
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                    self.generationManager.stopGeneration()
                }
                throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
        } catch {
            let errorMessage = getErrorMessage(from: error)
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
                self.generationManager.stopGeneration()
            }
            throw error
        }
    }
    
    // Vérifier le statut d'une génération vidéo en cours via polling
    private func pollVideoStatus(jobId: String) async throws -> String {
        let maxDuration: TimeInterval = 8 * 60 // 8 minutes maximum
        let pollingInterval: TimeInterval = 30 // 30 secondes entre chaque requête
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < maxDuration {
            // Vérifier si on a dépassé le temps maximum
            if Date().timeIntervalSince(startTime) >= maxDuration {
                let errorMessage = "Le temps imparti est écoulé. La génération a pris plus de 8 minutes."
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                    self.generationManager.stopGeneration()
                    self.defaults.set(false, forKey: self.isGeneratingVideoKey)
                    self.defaults.removeObject(forKey: self.currentJobIdKey)
                    self.saveState()
                }
                throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            // Faire une requête de polling
            guard let pollingURL = URL(string: APIConfig.videoPollingURL) else {
                let errorMessage = "URL du webhook de polling invalide"
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                    self.generationManager.stopGeneration()
                    self.saveState()
                }
                throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            var pollingRequest = URLRequest(url: pollingURL)
            pollingRequest.httpMethod = "POST"
            pollingRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let pollingBody: [String: Any] = ["jobId": jobId]
            pollingRequest.httpBody = try JSONSerialization.data(withJSONObject: pollingBody)
            
            do {
                let (data, response) = try await session.data(for: pollingRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    // Continuer le polling en cas d'erreur de réponse
                    try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
                    continue
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    // Parser la réponse
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Vérifier s'il y a une URL vidéo
                        if let videoURL = json["urlVideo"] as? String, !videoURL.isEmpty {
                            await MainActor.run {
                                self.generationStatus = .success(videoURL)
                                self.generatedVideoURL = videoURL
                                self.generationManager.stopGeneration()
                                self.defaults.set(false, forKey: self.isGeneratingVideoKey)
                                self.defaults.removeObject(forKey: self.currentJobIdKey)
                                self.saveState()
                            }
                            return videoURL
                        }
                        
                        // Vérifier s'il y a un message d'erreur
                        if let errorMsg = json["errorMessage"] as? String, !errorMsg.isEmpty {
                            let errorMessage = errorMsg
                            await MainActor.run {
                                self.generationStatus = .error(errorMessage)
                                self.generationManager.stopGeneration()
                                self.defaults.set(false, forKey: self.isGeneratingVideoKey)
                                self.defaults.removeObject(forKey: self.currentJobIdKey)
                                self.saveState()
                            }
                            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        }
                        
                        // Vérifier l'état
                        if let etat = json["etat"] as? String {
                            // Si l'état indique que c'est terminé mais pas de résultat, continuer à poller
                            if etat.lowercased() == "completed" || etat.lowercased() == "success" {
                                // Attendre un peu plus et réessayer
                                try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
                                continue
                            } else if etat.lowercased() == "failed" || etat.lowercased() == "error" {
                                let errorMessage = json["errorMessage"] as? String ?? "La génération a échoué"
                                await MainActor.run {
                                    self.generationStatus = .error(errorMessage)
                                    self.generationManager.stopGeneration()
                                    self.defaults.set(false, forKey: self.isGeneratingVideoKey)
                                    self.defaults.removeObject(forKey: self.currentJobIdKey)
                                    self.saveState()
                                }
                                throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            }
                        }
                    }
                }
            } catch {
                // En cas d'erreur réseau, continuer le polling
                print("Erreur lors du polling: \(error.localizedDescription)")
            }
            
            // Attendre 30 secondes avant le prochain polling
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
        }
        
        // Si on arrive ici, le temps maximum est écoulé
        let errorMessage = "Le temps imparti est écoulé. La génération a pris plus de 8 minutes."
        await MainActor.run {
            self.generationStatus = .error(errorMessage)
            self.generationManager.stopGeneration()
            self.defaults.set(false, forKey: self.isGeneratingVideoKey)
            self.defaults.removeObject(forKey: self.currentJobIdKey)
            self.saveState()
        }
        throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
    
    // Convertir une image en base64
    private func imageToBase64(_ image: PlatformImage) -> String? {
        #if canImport(UIKit)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        #elseif canImport(AppKit)
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            return nil
        }
        #endif
        return imageData.base64EncodedString()
    }
    
    // Obtenir un message d'erreur user-friendly
    private func getErrorMessage(from statusCode: Int, responseData: Data) -> String {
        // Essayer de parser le message d'erreur du serveur
        if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let message = json["message"] as? String ?? json["error"] as? String {
            return message
        }
        
        // Messages d'erreur user-friendly selon le code HTTP
        switch statusCode {
        case 400:
            return "Requête invalide. Vérifiez votre prompt et réessayez."
        case 401:
            return "Authentification échouée. Vérifiez votre configuration."
        case 403:
            return "Accès refusé. Vérifiez vos permissions."
        case 404:
            return "Service non disponible. Veuillez réessayer plus tard."
        case 429:
            return "Trop de requêtes. Veuillez patienter quelques instants."
        case 500...599:
            return "Erreur serveur. Veuillez réessayer dans quelques instants."
        default:
            return "Une erreur est survenue. Veuillez réessayer."
        }
    }
    
    // Obtenir un message d'erreur user-friendly depuis une erreur
    private func getErrorMessage(from error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "Pas de connexion internet. Vérifiez votre connexion."
            case .timedOut:
                return "La requête a pris trop de temps. Réessayez."
            case .cannotFindHost, .cannotConnectToHost:
                return "Impossible de se connecter au serveur. Vérifiez votre connexion."
            default:
                return "Erreur de connexion. Veuillez réessayer."
            }
        }
        return "Une erreur est survenue. Veuillez réessayer."
    }
    
    // Réinitialiser le statut
    func resetStatus() {
        generationStatus = .idle
        generatedVideoURL = nil
        pollingTask?.cancel()
        pollingTask = nil
        defaults.set(false, forKey: isGeneratingVideoKey)
        defaults.removeObject(forKey: currentJobIdKey)
        saveState()
    }
}


