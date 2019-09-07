//
//  UIAlertController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 08/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import class UIKit.UIAlertController
import class UIKit.UIAlertAction

public extension UIAlertController {
    
    static func alert(_ title: String? = nil, message: String? = nil, confirm: ((UIAlertAction) -> Void)? = nil, cancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: confirm))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: cancel))
        
        return alertController
    }
    
    static func genericError(_ title: String? = nil, message: String? = nil, cancel: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: cancel))
        
        return alertController
    }
    
}
