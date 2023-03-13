//
//  String+Extensions.swift
//  SwiftShift
//
//  Created by Ollie on 09/04/2022.
//

import Foundation

extension String {
    func stringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        guard let converted = dateFormatter.date(from: self) else {
            return Date.now
        }
        return converted
    }
}
