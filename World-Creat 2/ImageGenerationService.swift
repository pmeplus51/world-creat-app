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
    private let generationManager = GenerationManager.shared
    private let defaults = UserDefaults.standard
    private let isGeneratingKey = "imageGenerationInProgress"
    private let generatedImageURLKey = "lastGeneratedImageURL"
    
    private init() {
        // Restaurer l'état au démarrage
        restoreState()
    }
    
    private func restoreState() {
        // Si une génération était en cours, on la marque comme interrompue
        if defaults.bool(forKey: isGeneratingKey) {
            defaults.set(false, forKey: isGeneratingKey)
            // Ne pas restaurer l'état "en cours" car la requête a été interrompue
            // L'utilisateur devra relancer la génération
        }
        
        // Restaurer la dernière image générée si elle existe
        if let url = defaults.string(forKey: generatedImageURLKey) {
            generatedImageURL = url
        }
    }
    
    private func saveState() {
        defaults.set(generationStatus == .generating, forKey: isGeneratingKey)
        if let url = generatedImageURL {
            defaults.set(url, forKey: generatedImageURLKey)
        } else {
            defaults.removeObject(forKey: generatedImageURLKey)
        }
        defaults.synchronize()
    }
    
    // Générer une image avec Nano Banana via webhook N8N
    func generateImage(
        prompt: String,
        model: String = "Nano Banana",
        format: String = "1:1",
        referenceImages: [PlatformImage] = []
    ) async throws -> String {
        
        // Vérifier qu'aucune génération n'est en cours
        guard await generationManager.startGeneration(type: .image) else {
            let errorMessage = "Une génération est déjà en cours. Veuillez patienter."
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
            }
            throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        await MainActor.run {
            self.generationStatus = .generating
            self.saveState()
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
        
        // Déterminer le timeout : 90 secondes si une ou plusieurs images sont envoyées, sinon 30 secondes
        let hasImages = !referenceImages.isEmpty
        let timeoutInterval: TimeInterval = hasImages ? 90.0 : 30.0
        request.timeoutInterval = timeoutInterval
        
        // Générer un identifiant unique pour la tâche
        let taskId = "task_\(UUID().uuidString)"
        
        // Créer le body de la requête
        var requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "format": format,
            "taskId": taskId
        ]
        
        // Si des images de référence sont fournies, les convertir en base64 et les ajouter individuellement
        if !referenceImages.isEmpty {
            for (index, image) in referenceImages.enumerated() {
                if let base64 = imageToBase64(image) {
                    let imageKey = "Image\(index + 1)" // Image1, Image2, etc.
                    requestBody[imageKey] = base64
                }
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
        
        // Effectuer la requête avec timeout adaptatif
        do {
            // Créer une configuration de session avec timeout adaptatif
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = timeoutInterval
            config.timeoutIntervalForResource = timeoutInterval
            let sessionWithTimeout = URLSession(configuration: config)
            
            let (data, response) = try await sessionWithTimeout.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Réponse invalide du serveur"])
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Parser la réponse selon le format du webhook N8N
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let errorMessage = "Format de réponse invalide du serveur"
                    await MainActor.run {
                        self.generationStatus = .error(errorMessage)
                    }
                    throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                
                // Vérifier s'il y a un message d'erreur (failMsg peut être "null" comme string)
                if let failMsg = json["failMsg"] as? String,
                   failMsg.lowercased() != "null",
                   !failMsg.isEmpty {
                    let userFriendlyMessage = formatErrorMessage(failMsg)
                    await MainActor.run {
                        self.generationStatus = .error(userFriendlyMessage)
                        self.generationManager.stopGeneration()
                        self.saveState()
                    }
                    throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: userFriendlyMessage])
                }
                
                // Extraire l'URL de l'image depuis resultJson
                if let resultJsonString = json["resultJson"] as? String,
                   let resultJsonData = resultJsonString.data(using: .utf8),
                   let resultJson = try? JSONSerialization.jsonObject(with: resultJsonData) as? [String: Any],
                   let resultUrls = resultJson["resultUrls"] as? [String],
                   let imageURL = resultUrls.first {
                    await MainActor.run {
                        self.generationStatus = .success(imageURL)
                        self.generatedImageURL = imageURL
                        self.generationManager.stopGeneration()
                        self.saveState()
                    }
                    return imageURL
                } else {
                    // Si pas d'URL trouvée
                    let errorMessage = "Aucune URL d'image trouvée dans la réponse"
                    await MainActor.run {
                        self.generationStatus = .error(errorMessage)
                        self.generationManager.stopGeneration()
                        self.saveState()
                    }
                    throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
            } else {
                // Gérer les erreurs HTTP avec un message user-friendly
                let errorMessage = getErrorMessage(from: httpResponse.statusCode, responseData: data)
                await MainActor.run {
                    self.generationStatus = .error(errorMessage)
                    self.generationManager.stopGeneration()
                    self.saveState()
                }
                throw NSError(domain: "ImageGenerationService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
        } catch let error as URLError where error.code == .timedOut {
            // Timeout après 30 secondes
            let errorMessage = "Génération impossible ! Adaptez votre prompt et réessayez plus tard"
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
                self.generationManager.stopGeneration()
                self.saveState()
            }
            throw NSError(domain: "ImageGenerationService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        } catch {
            let errorMessage = getErrorMessage(from: error)
            await MainActor.run {
                self.generationStatus = .error(errorMessage)
                self.generationManager.stopGeneration()
                self.saveState()
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
        saveState()
    }
    
    // Formater les messages d'erreur pour qu'ils soient plus explicites
    private func formatErrorMessage(_ error: String) -> String {
        let lowercased = error.lowercased()
        
        if lowercased.contains("nsfw") {
            return "Contenu inapproprié détecté. Votre prompt contient du contenu non autorisé. Veuillez modifier votre prompt et réessayer."
        } else if lowercased.contains("violence") || lowercased.contains("violent") {
            return "Contenu violent détecté. Veuillez modifier votre prompt pour exclure toute référence à la violence."
        } else if lowercased.contains("hate") || lowercased.contains("discrimination") {
            return "Contenu discriminatoire détecté. Veuillez modifier votre prompt pour exclure tout contenu haineux ou discriminatoire."
        } else if lowercased.contains("illegal") || lowercased.contains("illégal") {
            return "Contenu illégal détecté. Veuillez modifier votre prompt pour exclure toute référence à des activités illégales."
        } else if lowercased.contains("policy") || lowercased.contains("politique") {
            return "Votre prompt viole nos politiques d'utilisation. Veuillez le modifier et réessayer."
        } else if lowercased.contains("invalid") || lowercased.contains("invalide") {
            return "Prompt invalide. Veuillez vérifier votre prompt et réessayer."
        } else if lowercased.contains("timeout") || lowercased.contains("expiré") {
            return "La génération a pris trop de temps. Veuillez réessayer."
        } else if lowercased.contains("quota") || lowercased.contains("limite") {
            return "Limite de génération atteinte. Veuillez réessayer plus tard."
        }
        
        // Si aucun pattern connu, retourner le message original avec une explication
        return "Erreur lors de la génération : \(error). Veuillez modifier votre prompt et réessayer."
    }
}


