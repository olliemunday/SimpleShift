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

    @AppStorage("shifts_synced", store: .standard)
    public var shiftsSynced: Bool = false
    #endif

    @AppStorage("sync_uuid", store: .standard)
    public var syncId: String = UUID().uuidString

    private var userDefaults: UserDefaults?

    private override init() {
        super.init()
        let appConstants = AppConstants()
        self.userDefaults = UserDefaults.init(suiteName: appConstants.appGroupIdentifier)
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

    func transferData(key: String, data: Any) {
        if !isSessionActivated { return }
        let transfer = [key : data]
        #if targetEnvironment(simulator)
        do { try WCSession.default.updateApplicationContext(transfer) } catch { print("watch update error") }
        #else
        WCSession.default.transferUserInfo(transfer)
        #endif
    }

    func sendAllWatchData() {
            if isSessionActive == false {
                startWCSession()
            }
            if isSessionActive == true {
                let calendarManager = CalendarManager()
                let shiftManager = ShiftManager()
                let settings = SettingsManager()
                if let calendar = calendarManager.packageForWatch() {
                    transferData(key: "calendar", data: calendar)
                }
                if let shifts = shiftManager.packageShifts() {
                    transferData(key: "shifts", data: shifts)
                }

                transferData(key: "calendar_weekday", data: settings.weekday)
            }
    }

    func sendSimulatorTest() {
        if isSessionActive == false {
            startWCSession()
        }
        if isSessionActive == true {
            if WCSession.default.activationState != .activated { return }
            do {
                let calendarManager = CalendarManager()
                let shiftManager = ShiftManager()
                let calendar = calendarManager.packageForWatch()
                let shifts = shiftManager.packageShifts()
                try WCSession.default.updateApplicationContext(["calendar": calendar as Any])
                try WCSession.default.updateApplicationContext(["shifts": shifts as Any])
            } catch {
                print(error.localizedDescription)
            }

        } else {
            print("Session not active")
        }

        print(WCSession.default.activationState == .activated)
        print(WCSession.default.isReachable)
    }

    var isSessionActivated: Bool { WCSession.default.activationState == .activated }

    func sendMessage(key: String, message: Any? = nil) {
        if !isSessionActivated { return }
        let message = [key : message as Any]
        WCSession.default.sendMessage(message, replyHandler: nil)
    }

}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error { print(error.localizedDescription) }
    }

    #if os(iOS) || os(xrOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let first = message.first else { return }
        if first.key == "sync_request"  {
            if let id = first.value as? String {
                if !(syncId == id) { sendAllWatchData(); syncId = id; print("Sent initial watch data.") }
            }
        }
    }
    #endif

    #if os(watchOS)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let first = userInfo.first else { return }
        handleReceived(key: first.key, value: first.value)
    }

    func handleReceived(key: String, value: Any) {
        if let data = value as? Data {
            if key == "calendar" { importCalendar(data); return }
            if key == "shifts" { importShifts(data); return }
        }
        if let number = value as? Int {
            if key == "calendar_weekday" { updateWeekday(weekday: number); return }
        }
    }

    func importCalendar(_ data: Data) {
        let calendarManager = CalendarManager()
        calendarManager.importDateStore(data)
        DispatchQueue.main.async { self.calendarSynced = true }
    }

    func importShifts(_ data: Data) {
        let shiftManager = ShiftManager()
        shiftManager.importShifts(data)
        DispatchQueue.main.async { self.shiftsSynced = true }
    }

    func updateWeekday(weekday: Int) {
        print("Received weekday update")
        userDefaults?.setValue(weekday, forKey: "calendar_weekday")
        NotificationCenter.default.post(name: NSNotification.Name("calendar_weekdayUpdate"),
                                        object: nil)
    }

    #if targetEnvironment(simulator)
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let first = applicationContext.first else { return }
        handleReceived(key: first.key, value: first.value)
    }
    #endif
    #endif

}
