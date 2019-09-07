//
//  PaddedSwitch.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

class PaddedSwitch: UIView {
    private static let Padding: CGFloat = 8
    
    convenience init(switchView: UISwitch) {
        self.init(frame: .zero)
        
        addSubview(switchView)
        
        frame.size = CGSize(width: switchView.frame.width + PaddedSwitch.Padding, height: switchView.frame.height)
        switchView.frame.origin = CGPoint(x: PaddedSwitch.Padding, y: 0)
    }
}
