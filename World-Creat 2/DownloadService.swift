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
            throw DownloadError.invalidURL
        }
        
        #if canImport(UIKit)
        // Télécharger la vidéo
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Créer un fichier temporaire
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        try data.write(to: tempURL)
        
        // Sauvegarder dans la galerie photo
        try await saveVideoToPhotoLibrary(url: tempURL)
        
        // Nettoyer le fichier temporaire
        try? FileManager.default.removeItem(at: tempURL)
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
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw DownloadError.permissionDenied
        }
        
        // Utiliser une continuation pour éviter le freeze
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
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


