//
//  ScaleInOut-AnyTransition.swift
//  SwiftShift
//
//  Created by Ollie on 14/09/2022.
//

import Foundation
import SwiftUI


struct ScaleInOut: ViewModifier {
    
    let active: Bool
    let anchor: UnitPoint
    let voffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.8 : 1.0, anchor: anchor)
            .opacity(active ? 0 : 1.0)
            .offset(y: active ? voffset : 0.0)
    }
}



extension AnyTransition {
    
    static func scaleInOut(anchor: UnitPoint, voffset: CGFloat = -20) -> AnyTransition {
        modifier(active: ScaleInOut(active: true, anchor: anchor, voffset: voffset), identity: ScaleInOut(active: false, anchor: anchor, voffset: voffset))
    }
    
}
