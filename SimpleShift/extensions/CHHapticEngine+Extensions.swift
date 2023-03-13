//
//  CHHapticEngine+Extensions.swift
//  SwiftShift
//
//  Created by Ollie on 22/09/2022.
//

import Foundation
import CoreHaptics

extension CHHapticEngine {
    
    /// Returns a running `CHHapticEngine?`
    static func prepareEngine() -> CHHapticEngine? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        
        do {
            let hapticEngine = try CHHapticEngine()
            try hapticEngine.start()
            return hapticEngine
        } catch {
            print("Error creating haptic engine. \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Basic haptic event to be set by `intensity`, `sharpness`, `duration` and `relativeTime`
    func playHaptic(intensity: Float, sharpness: Float, duration: Double, relativeTime: Double = 0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticIntensity, hapticSharpness], relativeTime: relativeTime, duration: duration)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try self.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed \(error.localizedDescription)")
        }
    }
    
}
