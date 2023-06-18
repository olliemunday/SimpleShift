import Foundation
import SwiftUI

/// https://stackoverflow.com/questions/59133826/swiftui-stop-an-animation-that-repeats-forever
extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self.speed(5.0)
        }
    }
}
