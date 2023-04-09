//
//  StrictConcurrencyWorkaroundView+PreviewProvider.swift
//  SimpleShift
//
//  Created by Ollie on 09/04/2023.
//

import Foundation
import SwiftUI

struct StrictConcurrencyWorkaroundView_Previews: PreviewProvider {
  nonisolated static var _previews: Any { previews }
  nonisolated static var previews: some View {
    Text("Hello World!")
  }
}

#if DEBUG
extension PreviewProvider {
  nonisolated static var _platform: PreviewPlatform? { nil }
}
#endif
