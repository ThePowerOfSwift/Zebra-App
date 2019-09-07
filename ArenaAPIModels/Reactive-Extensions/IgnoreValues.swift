//
//  IgnoreValues.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ReactiveSwift

public extension SignalProtocol {
    
    func ignoreValues() -> Signal<Void, Error> {
        return signal.map { _ in () }
    }
}

