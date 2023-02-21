//
//  DisplayLink.swift
//  SwiftShift
//
//  Created by Ollie on 25/09/2022.
//

import Foundation
import SwiftUI

class DisplayLink: NSObject, ObservableObject {
    @Published var preferredFrameRate: CAFrameRateRange = .default
    
    static let sharedInstance: DisplayLink = DisplayLink()
    private var timer: Timer?
    
    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self, selector: #selector(frame))
        displaylink.add(to: .current, forMode: .common)
    }
    
    @objc func frame(displaylink: CADisplayLink) {
        displaylink.preferredFrameRateRange = preferredFrameRate
    }
    
}

extension DisplayLink {

    public func setFramerate(framerate: CAFrameRateRange, time: Double = 3) {
        self.preferredFrameRate = framerate

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { timer in
            self.preferredFrameRate = .default
            timer.invalidate()
        })
    }

    public func defaultFramerate(time: Double = 0) {
        self.preferredFrameRate = .default
    }

    public func highFramerate(time: Double = 3) {
        self.preferredFrameRate = CAFrameRateRange(minimum: 100, maximum: 100, preferred: 100)
    }

    public func mediumFramerate(time: Double = 3) {
        self.preferredFrameRate = CAFrameRateRange(minimum: 80, maximum: 80, preferred: 80)
    }

}
