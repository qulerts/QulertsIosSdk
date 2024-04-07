//
//  SessionContextHolder.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2020 qulerts. All rights reserved.
//

import Foundation

class SessionContextHolder {
    private let sessionDuration: Int64 = 30 * 60 * 1000
    private var sessionId: String
    private var memberId: String?
    private var sessionStartTime: Int64
    private var lastActivityTime: Int64
    init() {
        let now = ClockUtils.getTime()
        self.sessionId = RandomValueUtils.randomUUID()
        self.sessionStartTime = now
        self.lastActivityTime = now
    }

    func getSessionIdAndExtendSession() -> String {
        let now = ClockUtils.getTime()
        if lastActivityTime + sessionDuration < now {
            restartSession()
        }
        lastActivityTime = now
        return self.sessionId
    }
    
    func restartSession() {
        let now = ClockUtils.getTime()
        self.sessionId = RandomValueUtils.randomUUID()
        self.sessionStartTime = now
    }

    func login(memberId: String) {
        self.memberId = memberId
    }

    func logout() {
        self.memberId = nil
    }

    func getSessionId() -> String {
        return self.sessionId
    }

    func getSessionStartTime() -> Int64 {
        return self.sessionStartTime
    }

    func getLastActivityTime() -> Int64 {
        return self.sessionStartTime
    }

    func getMemberId() -> String? {
        return self.memberId
    }
}
