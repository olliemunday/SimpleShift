//
//  TintColors.swift
//  SimpleShift
//
//  Created by Ollie on 15/04/2023.
//

import Foundation
import SwiftUI

// Custom Colors
let custom_darkOrange = Color(#colorLiteral(red: 0.9000439048, green: 0.4860342741, blue: 0, alpha: 1))
let custom_darkGreen = Color(#colorLiteral(red: 0, green: 0.374923408, blue: 0, alpha: 1))
let custom_lime = Color(#colorLiteral(red: 0.5097305179, green: 0.8830023408, blue: 0.02152137645, alpha: 1))


enum TintColor: Int, Codable, CaseIterable {
    case blackwhite,
         blue, mint, teal,
         purple, pink, indigo,
         red, yellow, orange,
         darkOrange, maroon,
         green, lime, darkGreen


    var color: Color {
        switch self {
        case .blue: return Color.blue
        case .red: return Color.red
        case .green: return Color.green
        case .orange: return Color.orange
        case .purple: return Color.purple
        case .mint: return Color.mint
        case .pink: return Color.pink
        case .indigo: return Color.indigo
        case .yellow: return Color.yellow
        case .teal: return Color.teal
        case .maroon: return Color.hex("800000")
        case .darkGreen: return custom_darkGreen
        case .darkOrange: return custom_darkOrange
        case .lime: return custom_lime
        case .blackwhite:  return .black
        }
    }

    var name: String {
        switch self {
        case .blue: return String(localized: "blue")
        case .red: return String(localized: "red")
        case .green: return String(localized: "green")
        case .orange: return String(localized: "orange")
        case .purple: return String(localized: "purple")
        case .mint: return String(localized: "mint")
        case .pink: return String(localized: "pink")
        case .indigo: return String(localized: "indigo")
        case .yellow: return String(localized: "yellow")
        case .teal: return String(localized: "teal")
        case .maroon: return String(localized: "maroon")
        case .darkGreen: return String(localized: "darkgreen")
        case .darkOrange: return String(localized: "darkorange")
        case .lime: return String(localized: "lime")
        case .blackwhite:  return String(localized: "blackwhite")
        }
    }

    // If in dark mode and set to black and white will need to use white.
    public func colorAdjusted(_ colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark && self == .blackwhite {
            return .white
        }
        return self.color
    }

    public func textColor(_ colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark && self == .blackwhite {
            return .black
        }
        return .white
    }



}
