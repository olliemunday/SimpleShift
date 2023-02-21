//
//  GradientTypes.swift
//  SwiftShift
//
//  Created by Ollie on 16/09/2022.
//

import Foundation
import SwiftUI

enum GradientTypes: Int {
    case vertical
    case horizontal
    
    var gradients: [UnitPoint] {
        switch self {
        case .vertical:
            return [UnitPoint.top, UnitPoint.bottom]
        case .horizontal:
            return [UnitPoint.leading, UnitPoint.trailing]
        }
        
    }
    
}
