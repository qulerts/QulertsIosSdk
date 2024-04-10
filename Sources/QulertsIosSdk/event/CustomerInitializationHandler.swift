//
//  CustomerInitializationHandler.swift
//  QulertsIosApp
//
//  Created by Leo Gordon on 4/4/24.
//

import Foundation


@objc public class CustomerInitializationHandler: NSObject {
    
    private let applicationContextHolder: ApplicationContextHolder
    private let sessionContextHolder: SessionContextHolder
    private let httpService: HttpService
    private let sdkKey: String
    private let jsonDeserializerService: JsonDeserializerService
    
    init(applicationContextHolder: ApplicationContextHolder,
         sessionContextHolder: SessionContextHolder,
         httpService: HttpService,
         sdkKey: String,
         jsonDeserializerService: JsonDeserializerService
    ) {
        self.applicationContextHolder = applicationContextHolder
        self.sessionContextHolder = sessionContextHolder
        self.httpService = httpService
        self.sdkKey = sdkKey
        self.jsonDeserializerService = jsonDeserializerService
    }
    
    public func initialize(completionHandler: @escaping () -> Void) -> Void {
        
        var params = Dictionary<String, String>()
        params["sdkKey"] = sdkKey
        
        let responseHandler: (HttpResult) -> CustomerConfiguration? = { hr in
            if let body = hr.getBody() {
                return self.jsonDeserializerService.deserialize(jsonString: body)
            } else {
                return nil
            }
        }
        let callback: (CustomerConfiguration?) -> Void = {data in
            if let config = data {
                self.applicationContextHolder.setActive(active: config.active)
                self.applicationContextHolder.setCustomerId(customerId: config.customerId)
                self.applicationContextHolder.setApplicationId(applicationId: config.id)
                completionHandler()
            }
        }
        httpService.getApiRequest(path: "/configuration", params: params, responseHandler: responseHandler, completionHandler: callback)
    }
    
    public func getDetails(summaryConfigId: String,
                           callback: @escaping (MemberSummary?) -> Void) -> Void {
        var params = Dictionary<String, String>()
        params["sdkKey"] = sdkKey
        params["pid"] = applicationContextHolder.getPersistentId()
        params["boxId"] = summaryConfigId
        if sessionContextHolder.getMemberId() != nil {
            params["memberId"] = sessionContextHolder.getMemberId()
        }
        params["size"] = "1"
        let responseHandler: (HttpResult) -> MemberSummary? = { hr in
            if let body = hr.getBody() {
                return self.jsonDeserializerService.deserialize(jsonString: body)
            } else {
                return nil
            }
        }
        httpService.getApiRequest(
            path: "/recommendation",
            params: params,
            responseHandler: responseHandler,
            completionHandler: callback)
    }
}


