//
//  HttpService.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class HttpService {

    private let sdkKey: String
    private let session: HttpSession
    private let collectorUrl: String
    private let apiUrl: String
    
    init(sdkKey: String, session: HttpSession, collectorUrl: String, apiUrl: String) {
        self.session = session
        self.sdkKey = sdkKey
        self.collectorUrl = collectorUrl
        self.apiUrl = apiUrl
    }
    
    func getApiRequest<T>(path: String,
                       params: Dictionary<String, String>,
                       responseHandler: @escaping (HttpResult) -> T?,
                       completionHandler: @escaping (T?) -> Void) {
        let endpoint = getApiUrl(path: path, params: params)
        let request = ApiGetJsonRequest(endpoint: endpoint)
        session.doRequest(from: request.getUrlRequest()) { httpResult in
            if httpResult.isValidStatus() {
                completionHandler(responseHandler(httpResult))
            } else {
                QulertsLogger.log(message: "getApiRequest error. Detail: \(httpResult.toString())")
            }
        }
    }

    func postFormUrlEncoded(payload: String?) {
        if let event = payload {
            var params = Dictionary<String, String>()
            params["s"] = sdkKey
            params["e"] = event
            
            let endpoint = getCollectorUrl(path: "p.gif", params: params)
            session.doRequest(from: ApiGetJsonRequest(endpoint: endpoint).getUrlRequest()) { httpResult in
                if httpResult.isValidStatus() {
                    QulertsLogger.log(message: "Xenn collector returned \(httpResult.getStatusCode())")
                } else {
                    QulertsLogger.log(message: "Xenn collector error. Detail: \(httpResult.toString())")
                }
            }
        }
    }
    
    func sendFeedback(payload: String?) {
        if let event = payload {
            var request =  URLRequest(url: URL(string: "https://f.qulerts.com/p.gif?e=\(event)")!)
            request.httpMethod = "GET"
            
            session.doRequest(from: request) { httpResult in
                if httpResult.isValidStatus() {
                    QulertsLogger.log(message: "Qulerts collector returned \(httpResult.getStatusCode())")
                } else {
                    QulertsLogger.log(message: "Qulerts collector error. Detail: \(httpResult.toString())")
                }
            }
        }
    }

    func postJsonEncoded(payload: String?, path: String) {
        postJsonEncoded(payload: payload, path: path) { httpResult in
            if httpResult.isSuccess() {
                QulertsLogger.log(message: "Xenn path returned \(httpResult.getStatusCode())")
            } else {
                // TO-DO: Retry logic and more error handling
            }
        }
    }

    func postFormUrlEncoded(payload: String?, completionHandler: @escaping (HttpResult) -> Void) {
        if payload != nil {
            let postFromUrlEncodedRequest = PostFormUrlEncodedRequest(payload: payload!, endpoint: getCollectorUrl())
            let request = postFromUrlEncodedRequest.getUrlRequest()
            session.doRequest(from: request) { httpResult in
                completionHandler(httpResult)
            }
        } else {
            completionHandler(HttpResult.clientError())
        }

    }

    func postJsonEncoded(payload: String?, path: String, completionHandler: @escaping (HttpResult) -> Void) {
        if payload != nil {
            let postFromUrlEncodedRequest = PostJsonEncodedRequest(payload: payload!, endpoint: getCollectorUrl(path: path))
            let request = postFromUrlEncodedRequest.getUrlRequest()
            session.doRequest(from: request) { httpResult in
                completionHandler(httpResult)
            }
        } else {
            completionHandler(HttpResult.clientError())
        }

    }

    func getCollectorUrl() -> String {
        return collectorUrl + "/" + self.sdkKey
    }

    func getCollectorUrl(path: String) -> String {
        return collectorUrl + "/" + path
    }
    
    private func getCollectorUrl(path: String, params: [String: String]) -> String {
        var components = URLComponents(string: self.collectorUrl)!
        components.path = path.starts(with: "/") ? path : "/\(path)"
        let queryItems = params.map { (paramKey, paramValue) in
            URLQueryItem(name: paramKey, value: paramValue)
        }
        components.queryItems = queryItems
        return components.url!.absoluteString
    }

    private func getApiUrl(path: String, params: [String: String]) -> String {
        var components = URLComponents(string: self.apiUrl)!
        components.path = path.starts(with: "/") ? path : "/\(path)"
        let queryItems = params.map { (paramKey, paramValue) in
            URLQueryItem(name: paramKey, value: paramValue)
        }
        components.queryItems = queryItems
        return components.url!.absoluteString
    }
}
