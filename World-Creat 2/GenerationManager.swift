//
//  GenerationManager.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import Combine

@MainActor
class GenerationManager: ObservableObject {
    static let shared = GenerationManager()
    
    @Published var isGenerating: Bool = false
    @Published var currentGenerationType: GenerationType? = nil
    
    enum GenerationType {
        case image
        case video
    }
    
    private init() {}
    
    func startGeneration(type: GenerationType) -> Bool {
        guard !isGenerating else {
            return false
        }
        isGenerating = true
        currentGenerationType = type
        return true
    }
    
    func stopGeneration() {
        isGenerating = false
        currentGenerationType = nil
    }
    
    var canGenerate: Bool {
        return !isGenerating
    }
}

