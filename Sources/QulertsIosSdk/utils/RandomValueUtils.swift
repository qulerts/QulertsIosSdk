//
//  RandomValueUtils.swift
//  harray-ios-sdk
//
//  Created by Leo Gordon on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class RandomValueUtils {
    
    private static var isFrozen: Bool = false
    private static var randomUUIDValue: String!
    private init(){

    }

    class func randomUUID() -> String {
        if isFrozen {
            return randomUUIDValue
        }
        return UUID.init().uuidString
    }
    
    class func freeze() {
        isFrozen = true
        randomUUIDValue = UUID.init().uuidString
    }
    
    class func unFreeze() {
        isFrozen = false
        randomUUIDValue = nil
    }
    
}
