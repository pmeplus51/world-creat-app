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
    /// Ferme le clavier quand on tape en dehors des champs de texte ou quand on swipe vers le bas
    func dismissKeyboardOnTap() -> some View {
        #if canImport(UIKit)
        return self
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        // Si le swipe est vers le bas, fermer le clavier
                        if value.translation.height > 30 && abs(value.translation.width) < abs(value.translation.height) {
                            hideKeyboard()
                        }
                    }
            )
        #else
        return self
        #endif
    }
}

#if canImport(UIKit)
func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}
#endif

// Vue wrapper pour fermer le clavier
#if canImport(UIKit)
struct KeyboardDismissView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = KeyboardDismissContainerView()
        view.backgroundColor = .clear
        
        // Tap gesture pour fermer le clavier
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        // Important : ne pas annuler les touches dans la vue pour permettre les interactions normales
        tapGesture.cancelsTouchesInView = false
        // Permettre aux autres gestes de fonctionner
        tapGesture.delegate = context.coordinator
        view.addGestureRecognizer(tapGesture)
        
        // Swipe down gesture pour fermer le clavier
        let swipeDownGesture = UISwipeGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        swipeDownGesture.direction = .down
        swipeDownGesture.delegate = context.coordinator
        view.addGestureRecognizer(swipeDownGesture)
        
        // Pan gesture pour détecter les swipes vers le bas
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // Vue container personnalisée qui ne bloque pas les interactions
    class KeyboardDismissContainerView: UIView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            // Ne pas intercepter les touches, laisser passer aux vues en dessous
            let hitView = super.hitTest(point, with: event)
            // Si c'est cette vue elle-même, retourner nil pour laisser passer
            if hitView == self {
                return nil
            }
            return hitView
        }
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private var panStartLocation: CGPoint = .zero
        
        @objc func dismissKeyboard() {
            // Fermer le clavier
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                panStartLocation = gesture.location(in: gesture.view)
            case .ended:
                let translation = gesture.translation(in: gesture.view)
                // Si le swipe est vers le bas (plus de 30 points), fermer le clavier
                if translation.y > 30 && abs(translation.x) < abs(translation.y) {
                    dismissKeyboard()
                }
            default:
                break
            }
        }
        
        // Permettre au gesture de fonctionner en même temps que d'autres gestures
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        // Ne pas intercepter les taps sur les champs de texte
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // Pour les swipe/pan gestures, toujours permettre
            if gestureRecognizer is UISwipeGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer {
                return true
            }
            
            // Pour les tap gestures, vérifier si c'est sur un champ de texte
            if let view = touch.view {
                // Vérifier si c'est un champ de texte ou un contrôle d'entrée
                if view is UITextField || view is UITextView {
                    return false
                }
                // Vérifier les superviews aussi
                var currentView: UIView? = view.superview
                while currentView != nil {
                    if currentView is UITextField || currentView is UITextView {
                        return false
                    }
                    currentView = currentView?.superview
                }
            }
            return true
        }
    }
}
#endif

