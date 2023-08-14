//
//  Array+Extensions.swift
//  SimpleShift
//
//  Created by Ollie on 29/06/2023.
//

import Foundation

extension Array {
    func element(at index: Int) -> Element? {
        guard index >= 0 && index < count else {
            return nil
        }
        return self[index]
    }

    /// Split array into subarrays of a specified size.
    func splitIntoChunks(size: Int) -> [[Element]] {
        var chunks = [[Element]]()

        for index in stride(from: 0, to: self.count, by: size) {
            let endIndex = Swift.min(index + size, self.count)
            let chunk = Array(self[index..<endIndex])
            chunks.append(chunk)
        }

        return chunks
    }
}

