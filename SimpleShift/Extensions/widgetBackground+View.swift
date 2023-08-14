//
//  widgetBackground+View.swift
//  SimpleShiftWidgetExtension
//
//  Created by Ollie on 04/07/2023.
//

import Foundation
import SwiftUI
import WidgetKit

extension View {
    func widgetBackground(color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.containerBackground(color, for: .widget)
        } else {
            return self.background(color)
        }
    }
}
