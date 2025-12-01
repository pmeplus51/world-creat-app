//
//  NotificationService.swift
//  World-Creat 2
//
//  Created on 2025.
//

import Foundation
import UserNotifications
import StoreKit

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private let userDefaults = UserDefaults.standard
    private let hasPurchasedKey = "has_purchased_any_product"
    private let lastNotificationDateKey = "last_notification_date"
    private let notificationPermissionKey = "notification_permission_requested"
    
    private init() {
        // Vérifier les permissions au démarrage
        checkNotificationPermission()
    }
    
    // Demander la permission pour les notifications
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            if granted {
                userDefaults.set(true, forKey: notificationPermissionKey)
                print("✅ Permission de notifications accordée")
            } else {
                print("❌ Permission de notifications refusée")
            }
            
            return granted
        } catch {
            print("❌ Erreur lors de la demande de permission: \(error)")
            return false
        }
    }
    
    // Vérifier les permissions
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                // Demander la permission automatiquement
                Task { @MainActor in
                    await self.requestPermission()
                }
            }
        }
    }
    
    // Vérifier si l'utilisateur a déjà acheté quelque chose
    func hasPurchased() -> Bool {
        return userDefaults.bool(forKey: hasPurchasedKey)
    }
    
    // Marquer qu'un achat a été effectué
    func markAsPurchased() {
        userDefaults.set(true, forKey: hasPurchasedKey)
        userDefaults.synchronize()
        print("✅ Utilisateur marqué comme ayant acheté")
    }
    
    // Planifier les notifications selon le statut de l'utilisateur
    func scheduleNotifications() {
        // Annuler toutes les notifications existantes
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let hasPurchased = hasPurchased()
        
        if hasPurchased {
            // Notifications pour les utilisateurs qui ont déjà acheté (fidélisation)
            scheduleRetentionNotifications()
        } else {
            // Notifications pour encourager l'achat
            schedulePurchaseNotifications()
        }
    }
    
    // Notifications pour encourager l'achat (utilisateurs sans abonnement)
    private func schedulePurchaseNotifications() {
        let messages = [
            "🎁 Offre spéciale ! Obtenez jusqu'à 50 000 crédits pour créer vos vidéos IA",
            "⚡ Ne manquez pas nos formules Starter, Pro et Studio. Créez sans limites !",
            "✨ Débloquez votre créativité avec World-Creat. Découvrez nos offres maintenant !",
            "🚀 Créez des vidéos virales en 2 minutes. Choisissez votre formule dès maintenant !",
            "💎 Profitez de nos meilleures offres. Jusqu'à 50 000 crédits disponibles !"
        ]
        
        // Notification 1 : Dans 2 jours
        scheduleNotification(
            id: "purchase_reminder_1",
            title: "N'oubliez pas !",
            body: messages[0],
            timeInterval: 2 * 24 * 60 * 60 // 2 jours
        )
        
        // Notification 2 : Dans 5 jours
        scheduleNotification(
            id: "purchase_reminder_2",
            title: "Offre toujours disponible",
            body: messages[1],
            timeInterval: 5 * 24 * 60 * 60 // 5 jours
        )
        
        // Notification 3 : Dans 7 jours
        scheduleNotification(
            id: "purchase_reminder_3",
            title: "Dernière chance !",
            body: messages[2],
            timeInterval: 7 * 24 * 60 * 60 // 7 jours
        )
        
        // Notification 4 : Dans 10 jours
        scheduleNotification(
            id: "purchase_reminder_4",
            title: "Revenez nous voir",
            body: messages[3],
            timeInterval: 10 * 24 * 60 * 60 // 10 jours
        )
        
        // Notification 5 : Dans 14 jours
        scheduleNotification(
            id: "purchase_reminder_5",
            title: "On vous attend !",
            body: messages[4],
            timeInterval: 14 * 24 * 60 * 60 // 14 jours
        )
        
        print("📅 Notifications d'achat planifiées")
    }
    
    // Notifications pour fidéliser (utilisateurs avec abonnement)
    private func scheduleRetentionNotifications() {
        let messages = [
            "🎨 Créez de nouvelles vidéos avec vos crédits ! Explorez toutes les possibilités de l'IA",
            "💡 Astuce : Utilisez vos crédits pour tester différents styles de vidéos",
            "✨ N'oubliez pas, vous avez des crédits à utiliser. Créez quelque chose d'incroyable aujourd'hui !",
            "🚀 Continuez à créer avec World-Creat. Vos crédits vous attendent !",
            "🎁 Profitez au maximum de votre formule. Créez sans limites !"
        ]
        
        // Notification 1 : Dans 3 jours
        scheduleNotification(
            id: "retention_reminder_1",
            title: "Revenez créer !",
            body: messages[0],
            timeInterval: 3 * 24 * 60 * 60 // 3 jours
        )
        
        // Notification 2 : Dans 7 jours
        scheduleNotification(
            id: "retention_reminder_2",
            title: "Vos crédits vous attendent",
            body: messages[1],
            timeInterval: 7 * 24 * 60 * 60 // 7 jours
        )
        
        // Notification 3 : Dans 14 jours
        scheduleNotification(
            id: "retention_reminder_3",
            title: "On vous a manqué !",
            body: messages[2],
            timeInterval: 14 * 24 * 60 * 60 // 14 jours
        )
        
        // Notification 4 : Dans 21 jours
        scheduleNotification(
            id: "retention_reminder_4",
            title: "Continuez à créer",
            body: messages[3],
            timeInterval: 21 * 24 * 60 * 60 // 21 jours
        )
        
        // Notification 5 : Dans 30 jours
        scheduleNotification(
            id: "retention_reminder_5",
            title: "Profitez de votre formule",
            body: messages[4],
            timeInterval: 30 * 24 * 60 * 60 // 30 jours
        )
        
        print("📅 Notifications de fidélisation planifiées")
    }
    
    // Planifier une notification
    private func scheduleNotification(id: String, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Ajouter des données personnalisées pour ouvrir l'app
        content.userInfo = [
            "notificationType": hasPurchased() ? "retention" : "purchase",
            "notificationId": id
        ]
        
        // Créer le trigger (délai)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Créer la requête
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // Ajouter la notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur lors de la planification de la notification \(id): \(error)")
            } else {
                print("✅ Notification \(id) planifiée dans \(Int(timeInterval / 86400)) jours")
            }
        }
    }
    
    // Envoyer une notification immédiate (pour test)
    func sendTestNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur lors de l'envoi de la notification de test: \(error)")
            } else {
                print("✅ Notification de test envoyée")
            }
        }
    }
    
    // Réinitialiser les notifications (pour tests)
    func resetNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        userDefaults.removeObject(forKey: hasPurchasedKey)
        userDefaults.removeObject(forKey: lastNotificationDateKey)
        userDefaults.synchronize()
        print("🔄 Notifications réinitialisées")
    }
}


