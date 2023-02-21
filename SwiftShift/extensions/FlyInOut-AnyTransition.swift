//
//  FlyInOut.swift
//  SwiftShift
//
//  Created by Ollie on 13/09/2022.
//

import Foundation
import SwiftUI

struct FlyInViewModifier: ViewModifier {
    @Binding var forward: Bool
    let active: Bool
    let width = UIScreen.main.bounds.width*1.5
    var callback: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.4 : 1.0)
            .opacity(active ? 0 : 1.0)
            .offset(x: active ? 0 : (forward ? -width : width))
            .onAnimationCompleted(for: active ? 1 : 0, completion: callback)
    }
    
}

struct FlyOutViewModifier: ViewModifier {
    @Binding var forward: Bool
    let active: Bool
    let width = UIScreen.main.bounds.width*1.5
    var callback: () -> Void
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.4 : 1.0)
            .opacity(active ? 0 : 1.0)
            .offset(x: active ? 0 : (forward ? width : -width))
            .onAnimationCompleted(for: active ? 1 : 0, completion: callback)
    }
    
    
}


extension AnyTransition {
    static func flyIn(forward: Binding<Bool>, callback: @escaping () -> Void = {}) -> AnyTransition {
        modifier(active: FlyInViewModifier(forward: forward, active: true, callback: callback), identity: FlyInViewModifier(forward: forward, active: false, callback: callback))
    }
    
    static func flyOut(forward: Binding<Bool>, callback: @escaping () -> Void = {}) -> AnyTransition {
        modifier(active: FlyOutViewModifier(forward: forward, active: true, callback: callback), identity: FlyOutViewModifier(forward: forward, active: false, callback: callback))
    }
}
