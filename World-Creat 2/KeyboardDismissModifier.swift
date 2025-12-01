//
//  KeyboardDismissModifier.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// Extension pour faciliter l'utilisation
extension View {
    /// Ferme le clavier quand on tape en dehors des champs de texte
    func dismissKeyboardOnTap() -> some View {
        #if canImport(UIKit)
        return self.background(
            KeyboardDismissView()
        )
        #else
        return self
        #endif
    }
}

// Vue wrapper pour fermer le clavier
#if canImport(UIKit)
struct KeyboardDismissView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        // Important : ne pas annuler les touches dans la vue pour permettre les interactions normales
        tapGesture.cancelsTouchesInView = false
        // Permettre aux autres gestes de fonctionner
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc func dismissKeyboard() {
            // Fermer le clavier
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
        
        // Permettre au gesture de fonctionner en même temps que d'autres gestures
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        // Ne pas intercepter les taps sur les champs de texte
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // Si le touch est sur un TextField, TextEditor ou autre contrôle d'entrée, ne pas fermer le clavier
            if let view = touch.view {
                // Vérifier si c'est un champ de texte ou un contrôle d'entrée
                if view is UITextField || view is UITextView || view.superview is UITextField || view.superview is UITextView {
                    return false
                }
            }
            return true
        }
    }
}
#endif

