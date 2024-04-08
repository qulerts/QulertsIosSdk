//
//  File.swift
//  
//
//  Created by YILDIRIM ADIGÜZEL on 4/8/24.
//

import Foundation
import UserNotifications
import UIKit


class QulertsNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationProcessorHandler: NotificationProcessorHandler
    let pushNotificationOpenHandler: ((_ launchUrl: String, _ userInfo: Dictionary<AnyHashable, Any>) -> ())?
    
    init(notificationProcessorHandler: NotificationProcessorHandler, pushNotificationOpenHandler: ((_ launchUrl: String, _ userInfo: Dictionary<AnyHashable, Any>) -> ())?) {
        self.notificationProcessorHandler = notificationProcessorHandler
        self.pushNotificationOpenHandler = pushNotificationOpenHandler
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle the notification when the app is in the foreground
        let userInfo = notification.request.content.userInfo
        if let pushNotificationOpenHandler = pushNotificationOpenHandler {
            if let launchUrl = userInfo[Constants.PUSH_PAYLOAD_LAUNCH_URL.rawValue] as? String {
                pushNotificationOpenHandler(launchUrl, userInfo)
            }
        }
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let pushSource = userInfo[Constants.PUSH_PAYLOAD_SOURCE.rawValue] as? String {
            if Constants.PUSH_CHANNEL_ID.rawValue == pushSource {
                notificationProcessorHandler.pushMessageOpened(pushContent: userInfo)
            }
        }
        
        if let pushNotificationOpenHandler = pushNotificationOpenHandler {
            if let launchUrl = userInfo[Constants.PUSH_PAYLOAD_LAUNCH_URL.rawValue] as? String {
                pushNotificationOpenHandler(launchUrl, userInfo)
            }
        }
        completionHandler()
    }
    
    func register(userNotificationCenter: UNUserNotificationCenter, uiApplication: UIApplication) {
        userNotificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { granted, error in
            guard granted else { return }
            userNotificationCenter.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    uiApplication.registerForRemoteNotifications()
                }
            }
        }
        userNotificationCenter.delegate = self
        uiApplication.applicationIconBadgeNumber = 0
    }
    
}
