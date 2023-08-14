//
//  SimpleShiftWidgetBundle.swift
//  SimpleShiftWidget
//
//  Created by Ollie on 04/07/2023.
//

import WidgetKit
import SwiftUI

@main
struct SimpleShiftWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThisWeekWidget()
        UpcomingWidget()
    }
}
