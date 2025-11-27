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
    
    private init() {}
    
    // Générer une vidéo avec Sora 2 ou Veo 3 via webhook N8N
    func generateVideo(
        prompt: String,
        format: VideoFormat,
        startingImage: PlatformImage? = nil,
        model: String = "Sora 2"
    ) async throws -> String {
        
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
        
        // Préparer la requête vers le webhook N8N
        guard let webhookURL = URL(string: APIConfig.videoGenerationURL) else {
            let errorMessage = "Configuration du serveur invalide. Veuillez contacter le support."
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Créer le body de la requête pour le webhook
        var requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "aspect_ratio": aspectRatio,
            "duration": 10
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
                // Décoder la réponse du webhook
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Le webhook N8N peut retourner différentes structures
                    // Chercher l'URL de la vidéo dans différentes clés possibles
                    if let videoURL = json["video_url"] as? String ??
                                      json["url"] as? String ??
                                      json["result"] as? String ??
                                      json["data"] as? String {
                        await MainActor.run {
                            self.generationStatus = .success(videoURL)
                            self.generatedVideoURL = videoURL
                        }
                        return videoURL
                    } else if let taskId = json["task_id"] as? String ?? json["id"] as? String {
                        // Si c'est une tâche asynchrone, faire du polling
                        return try await pollVideoStatus(taskId: taskId)
                    }
                }
                
                // Si on arrive ici, la structure de la réponse n'est pas reconnue
                let errorMessage = "Format de réponse inattendu du serveur"
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                }
                throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else {
                // Gérer les erreurs HTTP avec un message user-friendly
                let errorMessage = getErrorMessage(from: httpResponse.statusCode, responseData: data)
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                }
                throw NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
        } catch {
            let errorMessage = getErrorMessage(from: error)
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw error
        }
    }
    
    // Vérifier le statut d'une génération vidéo en cours (si asynchrone)
    private func pollVideoStatus(taskId: String) async throws -> String {
        // TODO: Implémenter le polling via webhook si nécessaire
        // Pour l'instant, on suppose que la génération est synchrone
        throw NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Génération asynchrone non encore implémentée"])
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
    }
}


