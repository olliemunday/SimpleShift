//
//  WatchConnectivityManager.swift
//  SimpleShift
//
//  Created by Ollie on 11/06/2023.
//

import Foundation
import WatchConnectivity
import SwiftUI

final class WatchConnectivityManager: NSObject, ObservableObject, @unchecked Sendable {
    static let shared = WatchConnectivityManager()

    public var isSessionActive: Bool = false

    #if os(watchOS)
    @AppStorage("calendar_synced", store: .standard)
    public var calendarSynced: Bool = false
    #endif

    private override init() {
        super.init()
        startWCSession()
    }

    func startWCSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            isSessionActive = true
        } else {
            isSessionActive = false
        }
    }

    func transferData(_ data: [String : Any]) {
        if WCSession.default.activationState != .activated { return }
        WCSession.default.transferUserInfo(data)
    }

    func sendAllWatchData() {
            if isSessionActive == false {
                startWCSession()
            }
            if isSessionActive == true {
                let calendarManager = CalendarManager()
                let shiftManager = ShiftManager()
                let calendar = calendarManager.packageForWatch()
                let shifts = shiftManager.packageShifts()
                transferData(["calendar" : calendar as Any])
                transferData(["shifts" : shifts as Any])
            }
    }

}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    #if os(watchOS)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let first = userInfo.first {
            let data = first.value as? Data
            guard let data = data else { return }

            if first.key == "calendar" {
                let calendarManager = CalendarManager()
                calendarManager.importDateStore(data)
                calendarSynced = true
            }

            if first.key == "shifts" {
                let shiftManager = ShiftManager()
                shiftManager.importShifts(data)
            }
        }
    }
    #endif
}
