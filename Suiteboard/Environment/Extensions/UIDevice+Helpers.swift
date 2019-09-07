//
//  UIDevice+Helpers.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 18/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    @objc public class func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @objc public class func isLandscapePad() -> Bool {
        
        
        return UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape == true && UIScreen.main.bounds.size.height > CGFloat(768.0)
    }
    
    @objc public class func isLandscapePadMini() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape == true && UIScreen.main.bounds.size.height == CGFloat(768.0)
    }
    
    @objc public class func isUnzoomediPhonePlus() -> Bool {
        let bounds = UIScreen.main.fixedCoordinateSpace.bounds
        let unzoomediPhonePlusHeight = CGFloat(736.0)
        
        return UIScreen.main.scale == 3.0 && bounds.size.height == unzoomediPhonePlusHeight
    }
    
    @objc public var systemMajorVersion: Int {
        let versionString = UIDevice.current.systemVersion as NSString
        return versionString.integerValue
    }
    
    @objc public func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
