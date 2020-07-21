//
//  PropertyWrappers.swift
//  LanguagePlayer
//
//  Created by Maxim Troshin on 22.07.2020.
//  Copyright © 2020 Maxim Troshin. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T> where T: Codable {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            if let data = UserDefaults.standard.object(forKey: key) as? Data {
                if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                    return decoded
                }
                fatalError("Was not decoded \(data)")
            }
            return defaultValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key)
            } else {
                fatalError("Was not encoded \(newValue)")
            }
        }
    }
}
