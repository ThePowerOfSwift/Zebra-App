//
//  UserViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol UserViewModelInputs {
    func configureWith(_ user: ListUser)
    func viewDidLoad()
}

public protocol UserViewModelOutputs {
    var subInitUser: Signal<ListUser, NoError> { get }
}


public protocol UserViewModelType {
    var inputs: UserViewModelInputs { get }
    var outputs: UserViewModelOutputs { get }
}

public final class UserViewModel: UserViewModelType, UserViewModelInputs, UserViewModelOutputs {
    
    public init() {
        
        let current = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configUserProperty.signal.skipNil()).map(second)
        
        self.subInitUser = current.signal
    }
    
    fileprivate let configUserProperty = MutableProperty<ListUser?>(nil)
    public func configureWith(_ user: ListUser) {
        self.configUserProperty.value = user
    }
    
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let subInitUser: Signal<ListUser, NoError>
    
    public var inputs: UserViewModelInputs { return self }
    public var outputs: UserViewModelOutputs { return self }
}
