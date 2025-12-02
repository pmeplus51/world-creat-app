//
//  DownloadService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
import Photos
#endif

class DownloadService {
    static let shared = DownloadService()
    
    private init() {}
    
    // Télécharger et sauvegarder une image depuis une URL
    func downloadAndSaveImage(from urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw DownloadError.invalidURL
        }
        
        #if canImport(UIKit)
        // Télécharger l'image
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw DownloadError.saveFailed
        }
        
        // Sauvegarder dans la galerie photo
        try await saveImageToPhotoLibrary(image: image)
        #else
        // Pour macOS, sauvegarder dans le dossier Téléchargements
        let (data, _) = try await URLSession.shared.data(from: url)
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileName = "World-Creat-\(UUID().uuidString).jpg"
        let fileURL = downloadsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        #endif
    }
    
    // Télécharger et sauvegarder une vidéo depuis une URL
    func downloadAndSaveVideo(from urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            print("❌ [DownloadService] URL invalide: \(urlString)")
            throw DownloadError.invalidURL
        }
        
        print("📥 [DownloadService] Début du téléchargement vidéo depuis: \(urlString)")
        
        #if canImport(UIKit)
        // Télécharger la vidéo avec une session configurée
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300.0 // 5 minutes pour les grandes vidéos
        config.timeoutIntervalForResource = 600.0 // 10 minutes au total
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("❌ [DownloadService] Erreur HTTP lors du téléchargement")
            throw DownloadError.saveFailed
        }
        
        print("✅ [DownloadService] Vidéo téléchargée - Taille: \(data.count) bytes")
        
        // Créer un fichier temporaire
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        
        do {
            try data.write(to: tempURL)
            print("✅ [DownloadService] Fichier temporaire créé: \(tempURL.path)")
        } catch {
            print("❌ [DownloadService] Erreur lors de l'écriture du fichier temporaire: \(error.localizedDescription)")
            throw DownloadError.saveFailed
        }
        
        // Sauvegarder dans la galerie photo
        do {
            try await saveVideoToPhotoLibrary(url: tempURL)
        } catch {
            // Nettoyer le fichier temporaire même en cas d'erreur
            try? FileManager.default.removeItem(at: tempURL)
            throw error
        }
        
        // Nettoyer le fichier temporaire après succès
        try? FileManager.default.removeItem(at: tempURL)
        print("🧹 [DownloadService] Fichier temporaire supprimé")
        #else
        // Pour macOS, sauvegarder dans le dossier Téléchargements
        let (data, _) = try await URLSession.shared.data(from: url)
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileName = "World-Creat-\(UUID().uuidString).mp4"
        let fileURL = downloadsURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        #endif
    }
    
    #if canImport(UIKit)
    // Sauvegarder l'image dans la galerie photo (iOS)
    private func saveImageToPhotoLibrary(image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw DownloadError.permissionDenied
        }
        
        // Utiliser une continuation pour éviter le freeze
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: DownloadError.saveFailed)
                }
            })
        }
    }
    
    // Sauvegarder la vidéo dans la galerie photo (iOS)
    private func saveVideoToPhotoLibrary(url: URL) async throws {
        // Vérifier que le fichier existe avant de tenter la sauvegarde
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ [DownloadService] Fichier vidéo introuvable: \(url.path)")
            throw DownloadError.saveFailed
        }
        
        // Vérifier que le fichier n'est pas vide
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int64,
              fileSize > 0 else {
            print("❌ [DownloadService] Fichier vidéo vide ou invalide")
            throw DownloadError.saveFailed
        }
        
        print("📥 [DownloadService] Tentative de sauvegarde vidéo - Taille: \(fileSize) bytes")
        
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            print("❌ [DownloadService] Permission refusée pour la galerie photo")
            throw DownloadError.permissionDenied
        }
        
        // Utiliser une continuation pour éviter le freeze
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                // Vérifier que la requête n'est pas nil
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                if request == nil {
                    // Si la requête est nil, on le signalera dans le completionHandler
                    print("⚠️ [DownloadService] Requête de sauvegarde nil - le fichier pourrait être invalide")
                } else {
                    print("✅ [DownloadService] Requête de sauvegarde créée")
                }
            }, completionHandler: { success, error in
                if let error = error {
                    print("❌ [DownloadService] Erreur lors de la sauvegarde: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else if success {
                    print("✅ [DownloadService] Vidéo sauvegardée avec succès")
                    continuation.resume()
                } else {
                    print("❌ [DownloadService] Échec de la sauvegarde (success = false)")
                    continuation.resume(throwing: DownloadError.saveFailed)
                }
            })
        }
    }
    #endif
    
    enum DownloadError: LocalizedError {
        case invalidURL
        case permissionDenied
        case saveFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "URL invalide"
            case .permissionDenied:
                return "Permission d'accès à la galerie photo refusée"
            case .saveFailed:
                return "Échec de la sauvegarde"
            }
        }
    }
}


