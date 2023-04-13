//
//  HapticManager.swift
//  SimpleShift
//
//  Created by Ollie on 16/03/2023.
//

import Foundation
import CoreHaptics

class HapticManager: ObservableObject {
    private var engine: CHHapticEngine?

    /// Returns a running `CHHapticEngine?`
    private func prepareEngine() -> CHHapticEngine? {
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

    public func prepareEngine() {
        self.engine = prepareEngine()
    }

    init() {
        self.engine = self.prepareEngine()
    }

    /// Basic haptic event to be set by `intensity`, `sharpness`, `duration` and `relativeTime`
    private func playHaptic(intensity: Float, sharpness: Float, duration: Double, relativeTime: Double = 0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = self.engine
        else { return }

        var events = [CHHapticEvent]()
        let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticIntensity, hapticSharpness], relativeTime: relativeTime, duration: duration)
        events.append(event)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed \(error.localizedDescription)")
        }
    }

    func extraLight() { playHaptic(intensity: 0.5, sharpness: 0.5, duration: 0.5) }
    func light() { playHaptic(intensity: 0.5, sharpness: 8, duration: 0.5) }

    func mediumLight() { playHaptic(intensity: 1, sharpness: 1, duration: 0.8) }
    func medium() { playHaptic(intensity: 1, sharpness: 8, duration: 0.5) }
}
