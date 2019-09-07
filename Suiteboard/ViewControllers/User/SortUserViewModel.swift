//
//  SortUserViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SortUserViewModelInputs {
    func configureWith(_ user: User)
    func channelsButtonTapped()
    func followingButtonTapped()
    func followersButtonTapped()
}

public protocol SortUserViewModelOutputs {
    
}

public protocol SortUserViewModelType {
    var inputs: SortUserViewModelInputs { get }
    var outputs: SortUserViewModelOutputs { get }
}

public final class SortUserViewModel: SortUserViewModelType, SortUserViewModelInputs, SortUserViewModelOutputs {
    
    public init() {
        
    }
    
    fileprivate let channelsButtonTappedProperty = MutableProperty(())
    public func channelsButtonTapped() {
        self.channelsButtonTappedProperty.value = ()
    }
    
    fileprivate let followingButtonTappedProperty = MutableProperty(())
    public func followingButtonTapped() {
        self.followingButtonTappedProperty.value = ()
    }
    
    fileprivate let followersButtonTappedProperty = MutableProperty(())
    public func followersButtonTapped() {
        self.followersButtonTappedProperty.value = ()
    }
    
    fileprivate let configUserProperty = MutableProperty<User?>(nil)
    public func configureWith(_ user: User) {
        self.configUserProperty.value = user
    }
    
    
    public var inputs: SortUserViewModelInputs { return self }
    public var outputs: SortUserViewModelOutputs { return self }
}
