//
//  UIControl.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 09/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ReactiveSwift
import Result
import UIKit

private enum Associations {
    fileprivate static var enabled = 0
    fileprivate static var selected = 1
}

public extension Rac where Object: UIControl {
    var enabled: Signal<Bool, NoError> {
        nonmutating set {
            let prop: MutableProperty<Bool> = lazyMutableProperty(object, key: &Associations.enabled,
                                                                  setter: { [weak object] in object?.isEnabled = $0 },
                                                                  getter: { [weak object] in object?.isEnabled ?? true })
            
            prop <~ newValue.observe(on: UIScheduler())
        }
        
        get {
            return .empty
        }
    }
    
    var selected: Signal<Bool, NoError> {
        nonmutating set {
            let prop: MutableProperty<Bool> = lazyMutableProperty(
                object, key: &Associations.selected,
                setter: { [weak object] in object?.isSelected = $0 },
                getter: { [weak object] in object?.isSelected ?? false })
            
            prop <~ newValue.observe(on: UIScheduler())
        }
        
        get {
            return .empty
        }
    }
}
