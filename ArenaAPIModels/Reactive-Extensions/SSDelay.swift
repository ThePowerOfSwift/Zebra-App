//
//  SSDelay.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ReactiveSwift

public extension SignalProtocol {
    func ss_delay(_ interval: @autoclosure @escaping () -> DispatchTimeInterval, on scheduler: @autoclosure @escaping () -> DateScheduler) -> Signal<Value, Error> {
        return self.signal.delay(interval().timeInterval, on: scheduler())
    }
}

public extension SignalProducerProtocol {
    
    func ss_delay(_ interval: @autoclosure @escaping () -> DispatchTimeInterval, on scheduler: @autoclosure @escaping () -> DateScheduler) -> SignalProducer<Value, Error> {
        return self.producer.delay(interval().timeInterval, on: scheduler())
    }
}
