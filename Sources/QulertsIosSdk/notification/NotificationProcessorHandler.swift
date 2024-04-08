//
// Created by YILDIRIM ADIGÜZEL on 22.04.2020.
// Copyright (c) 2020 qulerts. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

@objc public class NotificationProcessorHandler: NSObject {

    private let httpService: HttpService
    private let entitySerializerService: EntitySerializerService

    init(httpService: HttpService, entitySerializerService: EntitySerializerService) {
        self.httpService = httpService
        self.entitySerializerService = entitySerializerService
    }

    @objc public func pushMessageOpened(pushContent: Dictionary<AnyHashable, Any>) {
        let source = pushContent[Constants.PUSH_PAYLOAD_SOURCE.rawValue]
        if let source = source {
            let pushChannelId = source as? String
            if Constants.PUSH_CHANNEL_ID.rawValue == pushChannelId! {
                let pushId = getContentItem(key: Constants.PUSH_ID_KEY.rawValue, pushContent: pushContent)
                let campaignId = getContentItem(key: Constants.CAMPAIGN_ID_KEY.rawValue, pushContent: pushContent)
                let campaignDate = getContentItem(key: Constants.CAMPAIGN_DATE_KEY.rawValue, pushContent: pushContent)
                let customerId = getContentItem(key: Constants.CUSTOMER_ID_KEY.rawValue, pushContent: pushContent)
                let pushOpenedEvent = FeedbackEvent.create(name: "o")
                        .addParameter(key: "ci", value: campaignId!)
                        .addParameter(key: "pi", value: pushId!)
                        .addParameter(key: "c", value: customerId!)
                        .addParameter(key: "cd", value: campaignDate!)
                        .toMap()
                let serializedEvent = entitySerializerService.serializeToBase64(event: pushOpenedEvent)
                httpService.sendFeedback(payload: serializedEvent)
            }
        }
    }

    private func getContentItem(key: String, pushContent: Dictionary<AnyHashable, Any>) -> String? {
        return pushContent[key] as? String
    }
}
