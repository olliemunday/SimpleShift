//
//  Pattern.swift
//  SwiftShift
//
//  Created by Ollie on 10/09/2022.
//

import Foundation
import SwiftUI

struct Pattern: Identifiable, Equatable, Codable, Hashable {
    
    let id: UUID
    var name: String = ""
    var weekArray: [PatternWeek] = [PatternWeek(id: UUID())]
    
    func getWeekIndexId(weekId: UUID) -> Int {
        guard let index = self.weekArray.firstIndex(where: {$0.id == weekId}) else {
            return 0
        }
        return index
    }
    
}

extension Pattern {
    public func encode() -> String? {
        do {
            let data = try PropertyListEncoder().encode(self)
            return data.base64EncodedString()
        } catch {
            print("Error \(error)")
        }
        return nil
    }
    
    public static func decode(pattern: String) -> Pattern? {
        guard let data = Data(base64Encoded: pattern) else { return nil }
        do {
            let decoded = try PropertyListDecoder().decode(Pattern.self, from: data)
            return decoded
        } catch {
            print("Error \(error)")
        }
        return nil
    }
}

struct PatternWeek: Identifiable, Equatable, Codable, Hashable {  
    let id: UUID
    var shiftArray: [PatternShift]
    
    init(id: UUID) {
        self.id = id
        self.shiftArray = []
        
        for id in 0...6 {
            shiftArray.append(PatternShift(id: id))
        }
    }
}

struct PatternShift: Identifiable, Equatable, Codable, Hashable {
    let id: Int
    var shift: UUID?
    var selected: Bool = false
}

