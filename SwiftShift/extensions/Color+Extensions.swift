//
//  Color+Extensions.swift
//  SwiftShift
//
//  Created by Ollie on 04/04/2022.
//

import Foundation
import UIKit
import SwiftUI

// Extension for getting Color RGB components

extension Color {
    struct Components {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }
    var components: Components {
        typealias NativeColor = UIColor
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard NativeColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return Components(red: 0, green: 0, blue: 0, alpha: 0)
        }
        return Components(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Color {
    enum Brightness {
        case light, medium, dark, transparent

        private enum Threshold {
            static let transparent: CGFloat = 0.05
            static let light: CGFloat = 0.75
            static let dark: CGFloat = 0.35
        }

        init(brightness: CGFloat, alpha: CGFloat) {
            if alpha < Threshold.transparent {
                self = .transparent
            } else if brightness > Threshold.light {
                self = .light
            } else if brightness < Threshold.dark {
                self = .dark
            } else {
                self = .medium
            }
        }
    }

    var brightness: Brightness {
        var b: CGFloat = 0
        var a: CGFloat = 0
        let uiColor = UIColor(self)
        uiColor.getHue(nil, saturation: nil, brightness: &b, alpha: &a)
        return .init(brightness: b, alpha: a)
    }
    
    var textColor: Color {
        switch self.brightness {
        case .dark:
            return .white
        case .light:
            return .black
        case .medium:
            return .white
        case .transparent:
            return .black
        }
    }
}

// Convert Color to String for AppStorage
extension Color: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        do {
            //let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
            
        } catch {
            return ""
        }
    }
}

extension Color {
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> Color {
        guard let hex = Int(hex, radix: 16) else { return Color.clear }
        let uicolor = UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0,
                              green: ((CGFloat)((hex & 0x00FF00) >> 8)) / 255.0,
                              blue: ((CGFloat)((hex & 0x0000FF) >> 0)) / 255.0,
                              alpha: alpha)
        
        return Color(uiColor: uicolor)
    }
}
