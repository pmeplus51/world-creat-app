//
//  World_Creat_2App.swift
//  World-Creat 2
//
//  Created on 2025.
//

import SwiftUI
import UserNotifications

@main
struct World_Creat_2App: App {
    @StateObject private var notificationService = NotificationService.shared
    
    init() {
        // Configurer les notifications au démarrage
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Planifier les notifications quand l'app apparaît
                    Task { @MainActor in
                        // Attendre un peu pour que tout soit initialisé
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 seconde
                        notificationService.scheduleNotifications()
                    }
                }
        }
    }
    
    private func setupNotifications() {
        // Configurer le delegate pour gérer les notifications
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Demander la permission si pas encore demandée
        Task { @MainActor in
            await notificationService.requestPermission()
        }
    }
}

// Delegate pour gérer les notifications
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // Quand l'utilisateur reçoit une notification alors que l'app est au premier plan
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Afficher la notification même si l'app est au premier plan
        completionHandler([.banner, .sound, .badge])
    }
    
    // Quand l'utilisateur tape sur une notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Traiter la notification selon son type
        if let notificationType = userInfo["notificationType"] as? String {
            if notificationType == "purchase" {
                // Ouvrir la vue d'abonnement
                NotificationCenter.default.post(name: NSNotification.Name("OpenSubscriptionView"), object: nil)
            } else if notificationType == "retention" {
                // Ouvrir l'app normalement (déjà ouvert)
                print("📱 Notification de fidélisation reçue")
            }
        }
        
        completionHandler()
    }
}

