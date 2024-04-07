//
// Created by YILDIRIM ADIGÜZEL on 27.04.2020.
// Copyright (c) 2020 qulerts. All rights reserved.
//

import Foundation

public protocol HttpTask {
    func getUrlRequest() -> URLRequest
}

protocol HttpSession {
    func doRequest(from urlRequest: URLRequest,
                   completionHandler: @escaping (HttpResult) -> Void)
}

class HttpDownloadableResult {
    private let path: URL

    init(path: URL) {
        self.path = path
    }

    func getPath() -> URL {
        return path
    }

}

class HttpResult {
    
    private let statusCode: Int
    private let hasError: Bool
    private let body: String?
    
    init(statusCode: Int, hasError: Bool, body: String?) {
        self.statusCode = statusCode
        self.hasError = hasError
        self.body = body
    }

    func isSuccess() -> Bool {
        return !hasError
    }
    
    func isValidStatus() -> Bool {
        return self.statusCode >= 200 && self.statusCode <= 299
    }

    func getStatusCode() -> Int {
        return statusCode
    }
    
    func getBody() -> String? {
        return body
    }
    
    func toString() -> String {
        return "statusCode:\(statusCode);body:\(body ?? "<empty>")"
    }
    
    class func clientError() -> HttpResult {
        return HttpResult(statusCode: 0, hasError: true, body: nil)
    }
}

extension URLSession: HttpSession {

    func doRequest(from urlRequest: URLRequest,
                   completionHandler: @escaping (HttpResult) -> Void) {
        let task = dataTask(with: urlRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if let body = data {
                    completionHandler(HttpResult(statusCode: httpResponse.statusCode, hasError: false, body: String(data: body, encoding: .utf8)))
                } else {
                    completionHandler(HttpResult(statusCode: httpResponse.statusCode, hasError: false, body: nil))
                }
            } else {
                completionHandler(HttpResult(statusCode: 0, hasError: true, body: nil))
            }
        }
        task.resume()
    }
}
