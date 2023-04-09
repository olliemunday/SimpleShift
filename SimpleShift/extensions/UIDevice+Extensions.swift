//
//  UIDevice+Extensions.swift
//  SimpleShift
//
//  Created by Ollie on 14/03/2023.
//

import Foundation
import UIKit

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = Mirror(reflecting: systemInfo.machine).children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return machine
    }
}
