//
//  Array+Extensions.swift
//  SwiftShift
//
//  Created by Ollie on 18/09/2022.
//

import Foundation

extension Array {
    func indexExists(index: Int) -> Bool {
        self.indices.contains(index)
    }
}
