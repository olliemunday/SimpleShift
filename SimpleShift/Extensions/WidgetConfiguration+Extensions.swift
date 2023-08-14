//
//  WidgetConfiguration+Extensions.swift
//  SimpleShiftWidgetExtension
//
//  Created by Ollie on 04/07/2023.
//

import Foundation
import SwiftUI
import WidgetKit

extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        if #available(watchOSApplicationExtension 9.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}
