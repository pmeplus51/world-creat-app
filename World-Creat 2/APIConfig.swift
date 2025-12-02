//
// APIConfig.swift
// World-Creat 2
//
// Created on 2025.
//
import Foundation

struct APIConfig {
    // URL du webhook NBN pour la génération de vidéos
    static let videoGenerationURL = "https://pmeplus.app.n8n.cloud/webhook/480c37f8-5924-48e4-b675-5d7378739465"

    // URL du webhook NBN pour le polling des vidéos
    static let videoPollingURL = "https://pmeplus.app.n8n.cloud/webhook/1cc942d0-aec7-47e6-b867-ac4903f6e12"

    // URL du webhook N8N pour la génération d'images
    static let imageGenerationURL = "https://pmeplus.app.n8n.cloud/webhook/f52e0289-c74c-4049-9501-0a29f0b4ffbb"
}
