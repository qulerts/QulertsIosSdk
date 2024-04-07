//
//  Qulerts.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation
import UIKit

@objc public final class Qulerts: NSObject {

    static var instance: Qulerts?

    let sessionContextHolder: SessionContextHolder
    private let qulertsConfig: QulertsConfig
    private var pushNotificationToken: String = ""
    private let applicationContextHolder: ApplicationContextHolder
    private let eventProcessorHandler: EventProcessorHandler
    private let sdkEventProcessorHandler: SDKEventProcessorHandler
    private let notificationProcessorHandler: NotificationProcessorHandler
    private let ecommerceEventProcessorHandler: EcommerceEventProcessorHandler
    private let pushMessagesHistoryProcessorHandler: PushMessagesHistoryProcessorHandler
    private let memberSummaryProcessorHandler: MemberSummaryProcessorHandler

    private init(qulertsConfig: QulertsConfig,
                 sessionContextHolder: SessionContextHolder,
                 applicationContextHolder: ApplicationContextHolder,
                 eventProcessorHandler: EventProcessorHandler,
                 sdkEventProcessorHandler: SDKEventProcessorHandler,
                 notificationProcessorHandler: NotificationProcessorHandler,
                 ecommerceEventProcessorHandler: EcommerceEventProcessorHandler,
                 pushMessagesHistoryProcessorHandler: PushMessagesHistoryProcessorHandler,
                 memberSummaryProcessorHandler: MemberSummaryProcessorHandler
                 ) {
        self.sessionContextHolder = sessionContextHolder
        self.applicationContextHolder = applicationContextHolder
        self.eventProcessorHandler = eventProcessorHandler
        self.sdkEventProcessorHandler = sdkEventProcessorHandler
        self.notificationProcessorHandler = notificationProcessorHandler
        self.ecommerceEventProcessorHandler = ecommerceEventProcessorHandler
        self.qulertsConfig = qulertsConfig
        self.pushMessagesHistoryProcessorHandler = pushMessagesHistoryProcessorHandler
        self.memberSummaryProcessorHandler = memberSummaryProcessorHandler
    }
    
    @available(iOSApplicationExtension,unavailable)
    @objc public class func configure(sdkKey: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        configure(qulertsConfig: QulertsConfig.create(sdkKey: sdkKey), launchOptions: launchOptions)
    }
    
    @available(iOSApplicationExtension,unavailable)
    @objc public class func configure(qulertsConfig: QulertsConfig, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let sessionContextHolder = SessionContextHolder()
        let applicationContextHolder = ApplicationContextHolder(userDefaults: UserDefaults.standard)
        let httpService = HttpService(sdkKey: qulertsConfig.getSdkKey(), session: URLSession.shared, collectorUrl: qulertsConfig.getCollectorUrl(), apiUrl: qulertsConfig.getApiUrl())
        let entitySerializerService = EntitySerializerService(encodingService: EncodingService(), jsonSerializerService: JsonSerializerService())
        let deviceService = DeviceService(bundle: Bundle.main, uiDevice: UIDevice.current, uiScreen: UIScreen.main, locale: Locale.current)
        let chainProcessorHandler = ChainProcessorHandler()
        
        let eventProcessorHandler = EventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, entitySerializerService: entitySerializerService, chainProcessorHandler: chainProcessorHandler)
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, entitySerializerService: entitySerializerService, deviceService: deviceService)
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        let ecommerceEventProcessorHandler = EcommerceEventProcessorHandler(eventProcessorHandler: eventProcessorHandler)
        let jsonDeserializerService = JsonDeserializerService()
        
        let memberSummaryProcessorHandler = MemberSummaryProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: qulertsConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        
        let pushMessagesHistoryProcessorHandler = PushMessagesHistoryProcessorHandler(sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: qulertsConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        

        instance = Qulerts(qulertsConfig: qulertsConfig,
                          sessionContextHolder: sessionContextHolder,
                          applicationContextHolder: applicationContextHolder,
                          eventProcessorHandler: eventProcessorHandler,
                          sdkEventProcessorHandler: sdkEventProcessorHandler,
                          notificationProcessorHandler: notificationProcessorHandler,
                          ecommerceEventProcessorHandler: ecommerceEventProcessorHandler,
                          pushMessagesHistoryProcessorHandler: pushMessagesHistoryProcessorHandler,
                          memberSummaryProcessorHandler: memberSummaryProcessorHandler
        )
        
        let customerInitializationHandler = CustomerInitializationHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: qulertsConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            if let pushSource = notification[Constants.PUSH_PAYLOAD_SOURCE.rawValue] as? String {
                if Constants.PUSH_CHANNEL_ID.rawValue == pushSource {
                    notificationProcessorHandler.pushMessageOpened(pushContent: notification)
                }
            }
        }
 
        let callback: () -> Void = {
            sdkEventProcessorHandler.sessionStart()
            if (applicationContextHolder.isNewInstallation()){
                sdkEventProcessorHandler.newInstallation()
                applicationContextHolder.setInstallationCompleted()
            }
             notificationProcessorHandler.register(userNotificationCenter: UNUserNotificationCenter.current(), uiApplication: UIApplication.shared)
        }
        
        customerInitializationHandler.initialize(completionHandler: callback)
    }

    class func getInstance() -> Qulerts {
        return instance!
    }

    @objc public class func eventing() -> EventProcessorHandler {
        return getInstance().eventProcessorHandler
    }

    @objc public class func login(memberId: String) {
        let xennInstance = getInstance()
        let sessionContextHolder = xennInstance.sessionContextHolder
        sessionContextHolder.login(memberId: memberId)
        xennInstance.sdkEventProcessorHandler.login(memberId: memberId)
    }
    
    @objc public class func didReceiveNotification(userInfo: [AnyHashable: Any],
                                                   completionHandler: @escaping (_ launchUrl: String?) -> Void) {
        if let pushSource = userInfo[Constants.PUSH_PAYLOAD_SOURCE.rawValue] as? String {
            if Constants.PUSH_CHANNEL_ID.rawValue == pushSource {
                 if let launch_url = userInfo["launch_url"] as? String {
                     completionHandler(launch_url)
                 }else{
                     completionHandler(nil)
                 }
             }
        }
    }

    @objc public class func savePushToken(deviceToken: Data) {
        let xennInstance = getInstance()
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        xennInstance.pushNotificationToken = token
        xennInstance.eventProcessorHandler.savePushToken(deviceToken: token)
    }
    
    @objc public class func logout() {
        let xennInstance = getInstance()
        if let memberId = xennInstance.sessionContextHolder.getMemberId() {
            xennInstance.sessionContextHolder.logout()
            xennInstance.sdkEventProcessorHandler.logout(memberId: memberId)
        }
    }

    @objc public class func ecommerce() -> EcommerceEventProcessorHandler {
        return getInstance().ecommerceEventProcessorHandler
    }
    
    @objc public class func memberSummary() -> MemberSummaryProcessorHandler {
        return getInstance().memberSummaryProcessorHandler
    }
    
    @objc public class func pushMessagesHistory() -> PushMessagesHistoryProcessorHandler {
        return getInstance().pushMessagesHistoryProcessorHandler
    }
}
