//
//  SettingsController.swift
//  SimpleShift
//
//  Created by Ollie on 12/04/2023.
//

import Foundation
import SwiftUI

import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

class SettingsManager: ObservableObject {

    /// Singleton variable so state is consistent throughout application.
    static var shared = SettingsManager()

    var watchConnectivity = WatchConnectivityManager.shared

    /// App Groups identifier
    private let appGroupIdentifier = "group.com.olliemunday.SwiftShift"

    var userDefaults: UserDefaults?

    /// Publisher for updates relating to calendar
    let calendarPublisher = PassthroughSubject<Void, Never>()

    @Published var weekday: Int = Calendar.current.firstWeekday
    { didSet {
        updateValue(value: weekday, key: "calendar_weekday")
        watchConnectivity.transferData(key: "calendar_weekday", data: weekday)
    } }

    @Published var greyed: Bool = true
    { didSet { updateValue(value: greyed, key: "calendar_greyed") } }

    @Published var calendarShowOff: Bool = false
    { didSet { updateValue(value: calendarShowOff, key: "calendar_showOff") } }

    @Published var todayIndicatorType: Int = 1
    { didSet { updateValue(value: todayIndicatorType, key: "calendar_todayIndicatorType") } }

    @Published var tintColor: TintColor = .blue
    { didSet { updateValue(value: tintColor.rawValue, key: "_tintColor") } }

    private func updateValue(value: Any?, key: String) {
        calendarPublisher.send()
        userDefaults?.setValue(value, forKey: key)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
        importOldDefaults()
        loadFromUserDefaults()
    }

    /// Set variables from UserDefaults store
    func loadFromUserDefaults() {
        if let unwrapped = userDefaults?.value(forKey: "calendar_weekday") as? Int {
            weekday = unwrapped
        }

        if let unwrapped = userDefaults?.value(forKey: "calendar_greyed") as? Bool {
            greyed = unwrapped
        }

        if let unwrapped = userDefaults?.value(forKey: "calendar_showOff") as? Bool {
            calendarShowOff = unwrapped
        }

        if let unwrapped = userDefaults?.value(forKey: "calendar_todayIndicatorType") as? Int {
            todayIndicatorType = unwrapped
        }

        if let unwrapped = userDefaults?.value(forKey: "_tintColor") as? Int,
            let color = TintColor(rawValue: unwrapped) {
            tintColor = color
        }
    }

    /// Import settings from standard UserDefaults to new UserDefaults
    func importOldDefaults() {
        let oldUserDefaults = UserDefaults.standard

        if let weekday = oldUserDefaults.value(forKey: "calendar_weekday") as? Int {
            userDefaults?.setValue(weekday, forKey: "calendar_weekday")
            oldUserDefaults.removeObject(forKey: "calendar_weekday")
        }
        else { return }

        if let greyed = oldUserDefaults.value(forKey: "calendar_greyed") as? Bool {
            userDefaults?.setValue(greyed, forKey: "calendar_greyed")
            oldUserDefaults.removeObject(forKey: "calendar_greyed")
        }

        if let showOff = oldUserDefaults.value(forKey: "calendar_showOff") as? Bool {
            userDefaults?.setValue(showOff, forKey: "calendar_showOff")
            oldUserDefaults.removeObject(forKey: "calendar_showOff")
        }

        if let todayIndicator = oldUserDefaults.value(forKey: "calendar_todayIndicatorType") {
            userDefaults?.setValue(todayIndicator, forKey: "calendar_todayIndicatorType")
            oldUserDefaults.removeObject(forKey: "calendar_todayIndicatorType")
        }

        if let tintColor = oldUserDefaults.value(forKey: "_tintColor") {
            print(type(of: tintColor))
            userDefaults?.setValue(tintColor, forKey: "_tintColor")
            oldUserDefaults.removeObject(forKey: "_tintColor")
        }

    }

}
