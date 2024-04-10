//
//  XennEvent.swift
//  harray-ios-sdk
//
//  Created by Leo Gordon on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class QulertsEvent{
    
    private var h : Dictionary<String, Any> = Dictionary<String, Any>()
    private var b : Dictionary<String, Any> = Dictionary<String, Any>()
    
    class func create(name:String, persistentId: String, sessionId: String) -> QulertsEvent {
        let xennEvent = QulertsEvent()
        xennEvent.h["n"] = name
        xennEvent.h["p"] = persistentId
        xennEvent.h["s"] = sessionId
        return xennEvent
    }

    func addHeader(key:String, value: Any) -> QulertsEvent {
        h[key] = value
        return self
    }
    
    func addBody(key:String, value: Any) -> QulertsEvent {
        b[key] = value
        return self
    }
    
    func memberId(memberId: String?) -> QulertsEvent {
        if memberId != nil{
            if memberId != "" {
                return addBody(key: "memberId", value: memberId!)
            }
        }
        return self
    }
    
    func appendExtra(params: Dictionary<String, Any>) -> QulertsEvent {
        for eachParam in params {
            b[eachParam.key] = eachParam.value
        }
        return self
    }
    
    func toMap() -> Dictionary<String, Any> {
        var map = Dictionary<String,Any>()
        map["h"] = h
        map["b"] = b
        return map
    }
    
}
