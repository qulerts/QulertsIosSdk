//
//  JsonSerializerService.swift
//  harray-ios-sdk
//
//  Created by Leo Gordon on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class JsonSerializerService {
    func serialize(value: Dictionary<String, Any>) -> String? {
        let jsonSerialized = try? JSONSerialization.data(withJSONObject: value, options: [])
        if jsonSerialized != nil {
            return String(data: jsonSerialized!, encoding: .utf8)
        }
        return nil
    }
}
