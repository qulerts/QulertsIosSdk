//
//  XennConfig.swift
//  harray-ios-sdk
//
//  Created by Bay Batu on 20.04.2021.
//  Copyright © 2021 qulerts. All rights reserved.
//

import Foundation

@objc public class QulertsConfig: NSObject {
    
    private let sdkKey: String
    private var apiUrl: String = Constants.QULERTS_API_URL.rawValue
    private var collectorUrl: String = Constants.QULERTS_COLLECTOR_URL.rawValue
    private var inAppNotificationLinkClickHandler: ((_ deepLink: String) -> ())? = nil
    
    private init(sdkKey: String) {
        self.sdkKey = sdkKey
    }
    
    public static func create(sdkKey: String) -> QulertsConfig {
        return QulertsConfig(sdkKey: sdkKey)
    }
    
    public func collectorUrl(url: String) -> QulertsConfig {
        self.collectorUrl = QulertsConfig.getValidUrl(url: url)
        return self
    }
    
    public func inAppNotificationLinkClickHandler(_ handler: ((_ deepLink: String) -> ())? = nil) -> QulertsConfig {
        self.inAppNotificationLinkClickHandler = handler
        return self
    }

    public func apiUrl(url: String) -> QulertsConfig {
        self.apiUrl = QulertsConfig.getValidUrl(url: url)
        return self
    }

    public func getSdkKey() -> String {
        return self.sdkKey
    }

    public func getCollectorUrl() -> String {
        return self.collectorUrl
    }

    public func getApiUrl() -> String {
        return self.apiUrl
    }
    
    public func getInAppNotificationLinkClickHandler() -> ((_ deepLink: String) -> ())? {
        return self.inAppNotificationLinkClickHandler
    }
    
    private static func getValidUrl(url: String) -> String {
        return UrlUtils.removeTrailingSlash(url: url)
    }
}
