//
//  Settings.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

struct Settings {
    fileprivate static let prefs = UserDefaults(suiteName: SuiteAppInfo.sharedContainerIdentifier)!
    
    private static func defaultForToggle() -> Bool {
        return false
    }
    
    static func getToggle() -> Bool {
        return prefs.object(forKey: "BiometricLogin") as? Bool ?? defaultForToggle()
    }
}
