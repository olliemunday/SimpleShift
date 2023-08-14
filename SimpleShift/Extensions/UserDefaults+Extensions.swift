//
//  UserDefaults+Extensions.swift
//  SimpleShift
//
//  Created by Ollie on 21/07/2023.
//

import Foundation

extension UserDefaults {

    /// Get data from UserDefaults Container and return as an array of a specific type.
    func getData<T: Decodable>(key: String, type: [T].Type) -> [Any]? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        do {
            let decoder = JSONDecoder()
            let store = try decoder.decode(type, from: data)
            return store
        } catch {
            fatalError()
        }
    }

}
