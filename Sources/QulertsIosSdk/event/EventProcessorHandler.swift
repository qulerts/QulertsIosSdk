//
//  EventProcessorHandler.swift
//  harray-ios-sdk
//
//  Created by Leo Gordon on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

@objc public class EventProcessorHandler: NSObject {

    private let applicationContextHolder: ApplicationContextHolder
    private let sessionContextHolder: SessionContextHolder
    private let httpService: HttpService
    private let entitySerializerService: EntitySerializerService
    private let chainProcessorHandler : ChainProcessorHandler
    
    private let dateFormatter = DateFormatter()
    private let numberFormatter = NumberFormatter()
   

    init(applicationContextHolder: ApplicationContextHolder, sessionContextHolder: SessionContextHolder, httpService: HttpService, entitySerializerService: EntitySerializerService, chainProcessorHandler : ChainProcessorHandler) {
        self.applicationContextHolder = applicationContextHolder
        self.sessionContextHolder = sessionContextHolder
        self.httpService = httpService
        self.entitySerializerService = entitySerializerService
        self.chainProcessorHandler = chainProcessorHandler
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.minimumFractionDigits = 2
        self.numberFormatter.maximumFractionDigits = 2
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    @objc public func pageView(pageType: String) {
        pageView(pageType: pageType, params: Dictionary<String, Any>())
    }

    @objc public func pageView(pageType: String, params: Dictionary<String, Any>) {
        let pageViewEvent = QulertsEvent.create(name: "PV", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "pageType", value: pageType)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
        chainProcessorHandler.callAll(pageType: pageType)
    }

    @objc public func actionResult(type: String) {
        actionResult(type: type, params: Dictionary<String, Any>())
    }

    @objc public func actionResult(type: String, params: Dictionary<String, Any>) {
        let pageViewEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "type", value: type)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc public func impression(pageType: String) {
        impression(pageType: pageType, params: Dictionary<String, Any>())
    }

    @objc public func impression(pageType: String, params: Dictionary<String, Any>) {
        let pageViewEvent = QulertsEvent.create(name: "IM", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "pageType", value: pageType)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc public func custom(eventName: String, params: Dictionary<String, Any>) {
        let pageViewEvent = QulertsEvent.create(name: eventName, persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc func savePushToken(deviceToken: String) {
        let pageViewEvent = QulertsEvent.create(name: "Collection", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .addBody(key: "name", value: "pushToken")
                .addBody(key: "type", value: "iosToken")
                .addBody(key: "appType", value: "iosAppPush")
                .addBody(key: "deviceToken", value: deviceToken)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    func removeTokenAssociation(deviceToken: String) {
        let pageViewEvent = QulertsEvent.create(name: "TR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .addBody(key: "name", value: "pushToken")
                .addBody(key: "type", value: "iosToken")
                .addBody(key: "appType", value: "iosAppPush")
                .addBody(key: "deviceToken", value: deviceToken)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    
    func tagString(key:String, value:String) -> Void{
        let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "name", value: key)
                .addBody(key: "value", value: value)
                .addBody(key: "tt", value: "str")
                .addBody(key: "type", value: "tag")
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    func tagInteger(key:String, value: Int32) -> Void{
        let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "name", value: key)
                .addBody(key: "value", value: value)
                .addBody(key: "tt", value: "ln")
                .addBody(key: "type", value: "tag")
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    func tagDouble(key:String, value: Double) -> Void{
        let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "name", value: key)
                .addBody(key: "value", value: numberFormatter.string(from:  NSNumber(value: value)) ?? 0)
                .addBody(key: "tt", value: "db")
                .addBody(key: "type", value: "tag")
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
   func tagDate(key:String, value: Date) -> Void{
       let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
               .addBody(key: "name", value: key)
               .addBody(key: "value", value: dateFormatter.string(from: value))
               .addBody(key: "tt", value: "dt")
               .addBody(key: "type", value: "tag")
               .toMap()
       let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
       httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    
    func tagBoolean(key:String, value: Bool) -> Void{
        let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "name", value: key)
                .addBody(key: "value", value: value)
                .addBody(key: "tt", value: "b")
                .addBody(key: "type", value: "tag")
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    
    func tagArray(key:String, value: Array<String>) -> Void{
        let tagEvent = QulertsEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "name", value: key)
                .addBody(key: "value", value: value)
                .addBody(key: "tt", value: "ar")
                .addBody(key: "type", value: "tag")
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: tagEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
}
