//
//  CustomerConfiguration.swift
//  QulertsIosApp
//
//  Created by YILDIRIM ADIGÜZEL on 4/4/24.
//

import Foundation

@objc public class CustomerConfiguration: NSObject, Decodable {
    public let id: String
    public let active: Bool
    public let customerId: String
}
