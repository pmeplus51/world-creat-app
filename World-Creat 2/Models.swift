//
//  Models.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation

// Modèle pour la requête de création de tâche KIE API
struct KIECreateTaskRequest: Codable {
    let model: String
    let callBackUrl: String?
    let input: KIEInput
    
    enum CodingKeys: String, CodingKey {
        case model
        case callBackUrl = "callBackUrl" // Peut aussi être "callback_url" selon l'API
        case input
    }
}

// Structure pour l'input de la requête KIE
struct KIEInput: Codable {
    let prompt: String
    let duration: Int?
    let aspectRatio: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case duration
        case aspectRatio = "aspect_ratio"
        case imageUrl = "image_url"
    }
}

// Modèle pour la réponse de création de tâche KIE
struct KIECreateTaskResponse: Codable {
    let taskId: String?
    let id: String? // Alternative possible
    let status: String?
    let message: String?
    let data: TaskData?
    
    // Propriété calculée pour obtenir l'ID de la tâche
    var taskID: String {
        return taskId ?? id ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
        case status
        case message
        case data
    }
}

// Structure pour les données de la tâche
struct TaskData: Codable {
    let taskId: String?
    let id: String?
    
    var taskID: String {
        return taskId ?? id ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case id
    }
}

// Modèle pour la requête de vérification de statut KIE
struct KIEQueryTaskRequest: Codable {
    let taskId: String
}

// Modèle pour la réponse de vérification de statut KIE
struct KIEQueryTaskResponse: Codable {
    let taskId: String
    let status: String
    let videoUrl: String?
    let error: APIError?
    let progress: Int?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case videoUrl = "video_url"
        case error
        case progress
    }
}

// Modèle pour recordInfo (si utilisé)
struct KIERecordInfoResponse: Codable {
    let taskId: String
    let status: String
    let videoUrl: String?
    let metadata: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case status
        case videoUrl = "video_url"
        case metadata
    }
}

// Anciens modèles conservés pour compatibilité
struct VideoGenerationRequest: Codable {
    let model: String
    let prompt: String
    let duration: Int?
    let aspectRatio: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case duration
        case aspectRatio = "aspect_ratio"
        case imageUrl = "image_url"
    }
}

struct VideoGenerationResponse: Codable {
    let id: String
    let status: String
    let videoUrl: String?
    let error: APIError?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case videoUrl = "video_url"
        case error
    }
}

struct APIError: Codable {
    let message: String
    let type: String?
    let code: String?
}

// Modèle pour le statut de la génération
enum GenerationStatus: Equatable {
    case idle
    case generating
    case success(String) // URL de la vidéo
    case error(String) // Message d'erreur
}

// Format de vidéo
enum VideoFormat: String, CaseIterable {
    case landscape = "Format paysage"
    case portrait = "Format portrait"
    case square = "Format carré"
}

