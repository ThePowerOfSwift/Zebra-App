//
//  TakeUntil.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ReactiveSwift

public extension SignalProtocol {
    
    func takeUntil(_ predicate: @escaping (Value) -> Bool) -> Signal<Value, Error> {
        return Signal.init { observer, _ in
            return self.signal.observe { event in
                if case let .value(value) = event, predicate(value) {
                    observer.send(value: value)
                    observer.sendCompleted()
                } else {
                    observer.send(event)
                }
            }
        }
    }
}

public extension SignalProducerProtocol {
    
    func takeUntil(_ predicate: @escaping (Value) -> Bool) -> SignalProducer<Value, Error> {
        return producer.lift { $0.takeUntil(predicate) }
    }
}

