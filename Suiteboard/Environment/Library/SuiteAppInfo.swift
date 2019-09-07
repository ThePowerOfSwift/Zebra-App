//
//  SuiteAppInfo.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation


class SuiteAppInfo {
    
    static var sharedContainerIdentifier: String {
        return "group." + SuiteAppInfo.baseBundleIdentifier
    }
    
    static var baseBundleIdentifier: String {
        let bundle = Bundle.main
        let packageType = bundle.object(forInfoDictionaryKey: "CFBundlePackageType") as! String
        let baseBundleIdentifier = bundle.bundleIdentifier!
        
        if packageType == "XPC!" {
            let components = baseBundleIdentifier.components(separatedBy: ".")
            return components[0..<components.count-1].joined(separator: ".")
        }
        
        return baseBundleIdentifier
    }
}
