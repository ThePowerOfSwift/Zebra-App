//
//  Globals.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit


var Globals = GlobalFactory()

class GlobalFactory {
    lazy var isIphoneX: Bool = _isIphoneX()
    var windowSize: CGSize = .zero
    
    
}

private func _isRunningOnSimulator() -> Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
}

private func _isTesting() -> Bool {
    return NSClassFromString("XCTest") != nil
}

private func _isIphoneX() -> Bool {
    return UIScreen.main.bounds.size.height == 812
}

private func _statusBarHeight() -> CGFloat {
    if Globals.isIphoneX {
        return 44
    }
    return 20
}

private func _bestBottomMargin() -> CGFloat {
    if Globals.isIphoneX {
        return 23
    }
    return 10
}

private func _isIpad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
