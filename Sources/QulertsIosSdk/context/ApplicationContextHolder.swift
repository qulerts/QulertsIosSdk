//
//  ApplicationContextHolder.swift
//  harray-ios-sdk
//
//  Created by Leo Gordon on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class ApplicationContextHolder {
    private let persistentId: String
    private let sdkVersion = "1.0.0"
    private var newInstallation = false
    private var customerId: String? = nil
    private var applicationId: String? = nil
    private var active: Bool = true

    init(userDefaults: UserDefaults) {
        var value = userDefaults.string(forKey: Constants.SDK_PERSISTENT_ID_KEY.rawValue)
        if value == nil {
            value = RandomValueUtils.randomUUID()
            userDefaults.set(value, forKey: Constants.SDK_PERSISTENT_ID_KEY.rawValue)
            newInstallation = true
        }
        self.persistentId = value!
    }

    func getPersistentId() -> String {
        return self.persistentId
    }

    func getTimezone() -> String {
        return TimeZone.current.identifier
    }
    
    func getTimezoneNumeric() -> String {
        return String(TimeZone.current.secondsFromGMT() / 3600)
    }

    func getSdkVersion() -> String {
        return self.sdkVersion
    }
    
    func isNewInstallation() -> Bool {
        return self.newInstallation
    }
    
    func setInstallationCompleted() {
        self.newInstallation = false
    }
    
    func setCustomerId(customerId: String) {
        self.customerId = customerId
    }
    
    func setApplicationId(applicationId: String) {
        self.applicationId = applicationId
    }
    
    func setActive(active: Bool) {
        self.active = active
    }
}
