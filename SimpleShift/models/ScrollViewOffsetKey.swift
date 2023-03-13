//
//  ScrollViewOffsetKey.swift
//  SwiftShift
//
//  Created by Ollie on 22/09/2022.
//

import Foundation
import SwiftUI

struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ScrollViewHeightData: Equatable {
    let frame: CGFloat
    let scroll: CGFloat
    
    static var start: ScrollViewHeightData { get {
            self.init(frame: 0.0, scroll: 0.0)
        }
    }
}

struct ScrollViewHeightKey: PreferenceKey {
    static var defaultValue: [ScrollViewHeightData] = []
    
    static func reduce(value: inout [ScrollViewHeightData], nextValue: () -> [ScrollViewHeightData]) {
        value = nextValue()
    }
    
}
