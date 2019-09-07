//
//  SearchUserCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SearchUserCellViewModelInputs {
    func configure(user: ListUser)
}

public protocol SearchUserCellViewModelOutputs {
    var userNameText: Signal<String, NoError> { get }
    var userChannelText: Signal<String, NoError> { get }
}

public protocol SearchUserCellViewModelType {
    var inputs: SearchUserCellViewModelInputs { get }
    var outputs: SearchUserCellViewModelOutputs { get }
}

public final class SearchUserCellViewModel: SearchUserCellViewModelType, SearchUserCellViewModelInputs, SearchUserCellViewModelOutputs {
    
    public init() {
        let user = self.configListUserProperty.signal.skipNil()
        
        self.userNameText = user.signal.map { $0.username }
        
        self.userChannelText = user.signal.map { "\($0.userStatus.channelCount) Channels" }
    }
    
    fileprivate let configListUserProperty = MutableProperty<ListUser?>(nil)
    public func configure(user: ListUser) {
        self.configListUserProperty.value = user
    }
    
    public let userNameText: Signal<String, NoError>
    public let userChannelText: Signal<String, NoError>
    
    public var inputs: SearchUserCellViewModelInputs { return self }
    public var outputs: SearchUserCellViewModelOutputs { return self }
}
