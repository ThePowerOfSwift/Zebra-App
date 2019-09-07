
//
//  SuiteFullscreenNavigationTransition.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 12/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

class SuiteFullscreenNavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    @objc let operation: UINavigationController.Operation
    
    @objc var pushing: Bool {
        return operation == .push
    }
    
    @objc init(operation: UINavigationController.Operation) {
        self.operation = operation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    
}
