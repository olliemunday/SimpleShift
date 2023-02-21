//
//  Date+Extensions.swift
//  SwiftShift
//
//  Created by Ollie on 09/04/2022.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }

    func dateToTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")

        return dateFormatter.string(from: self)
    }

    init(time: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")

        self = dateFormatter.date(from: time) ?? Date()
    }
}
