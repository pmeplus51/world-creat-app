//
//  ImageGenerationService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import SwiftUI

class ImageGenerationService: ObservableObject {
    static let shared = ImageGenerationService()
    
    @Published var generationStatus: GenerationStatus = .idle
    @Published var generatedImageURL: String?
    
    private let session = URLSession.shared
    
    private init() {}
    
    // Générer une image avec Nano Banana via webhook N8N
    func generateImage(
        prompt: String,
        model: String = "Nano Banana",
        referenceImages: [PlatformImage] = []
    ) async throws -> String {
        
        await MainActor.run {
            self.generationStatus = .generating
        }
        
        // Préparer la requête vers le webhook N8N
        guard let webhookURL = URL(string: APIConfig.imageGenerationURL) else {
            let errorMessage = "URL du webhook invalide"
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Créer le body de la requête
        var requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt
        ]
        
        // Si des images de référence sont fournies, les convertir en base64
        if !referenceImages.isEmpty {
            var base64Images: [String] = []
            for image in referenceImages {
                if let base64 = imageToBase64(image) {
                    base64Images.append(base64)
                }
            }
            if !base64Images.isEmpty {
                requestBody["reference_images"] = base64Images
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
        
        // Effectuer la requête
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Réponse invalide du serveur"])
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Décoder la réponse
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Le webhook N8N peut retourner différentes structures
                    // Chercher l'URL de l'image dans différentes clés possibles
                    if let imageURL = json["image_url"] as? String ??
                                      json["url"] as? String ??
                                      json["result"] as? String ??
                                      json["data"] as? String {
                        await MainActor.run {
                            self.generationStatus = .success(imageURL)
                            self.generatedImageURL = imageURL
                        }
                        return imageURL
                    } else if let taskId = json["task_id"] as? String ?? json["id"] as? String {
                        // Si c'est une tâche asynchrone, faire du polling
                        return try await pollImageStatus(taskId: taskId)
                    }
                }
                
                // Si on arrive ici, la structure de la réponse n'est pas reconnue
                let errorMessage = "Format de réponse inattendu du serveur"
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                }
                throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            } else {
                // Gérer les erreurs HTTP avec un message user-friendly
                let errorMessage = getErrorMessage(from: httpResponse.statusCode, responseData: data)
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                }
                throw NSError(domain: "ImageGenerationService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
        } catch {
            let errorMessage = getErrorMessage(from: error)
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw error
        }
    }
    
    // Vérifier le statut d'une génération d'image en cours (si asynchrone)
    private func pollImageStatus(taskId: String) async throws -> String {
        // TODO: Implémenter le polling si nécessaire
        // Pour l'instant, on suppose que la génération est synchrone
        throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Génération asynchrone non encore implémentée"])
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
        generatedImageURL = nil
    }
}


