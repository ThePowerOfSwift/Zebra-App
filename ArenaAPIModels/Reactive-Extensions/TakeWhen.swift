//
//  TakeWhen.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ReactiveSwift
import Result

public extension SignalProtocol {
    
    func takeWhen <U> (_ other: Signal<U, Error>) -> Signal<Value, Error> {
        return other.withLatest(from: self.signal as! Signal<Value, NoError>).map { tuple in tuple.1 }
    }
    
    func takePairWhen <U> (_ other: Signal<U, Error>) -> Signal<(Value, U), Error> {
        return other.withLatest(from: self.signal as! Signal<Value, NoError>).map { ($0.1, $0.0) }
    }
}
