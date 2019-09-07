//
//  ChannelsUserViewModel.swift
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

public protocol ChannelsUserViewModelInputs {
    func viewWillAppear(animated: Bool)
    func tapped(_ listChannel: ChannelUser)
//    func callFromCell(_ listChannel: ChannelUser)
    func configureWith(user: ListUser)
    func viewDidLoad()
}

public protocol ChannelsUserViewModelOutputs {
    var channels: Signal<[ChannelUser], NoError> { get }
    var goToChannel: Signal<ChannelUser, NoError> { get }
}

public protocol ChannelsUserViewModelType {
    var inputs: ChannelsUserViewModelInputs { get }
    var outputs: ChannelsUserViewModelOutputs { get }
}

public final class ChannelsUserViewModel: ChannelsUserViewModelType, ChannelsUserViewModelInputs, ChannelsUserViewModelOutputs {
    
    public init() {
        
        let current = Signal.combineLatest(self.viewWillAppearedProperty.signal.ignoreValues(), self.configUserProperty.signal.skipNil()).map(second)
        
        let fetchChannels = current.signal.switchMap { user  in
            AppEnvironment.current.apiService.getUserChannels(id: String(user.id)).materialize()
        }
        
        self.channels = fetchChannels.values().map { $0.channels }
        
        self.goToChannel = self.listChannelTappedProperty.signal.skipNil()
    }
    
    fileprivate let viewWillAppearedProperty = MutableProperty(false)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearedProperty.value = animated
    }
    
    fileprivate let listChannelTappedProperty = MutableProperty<ChannelUser?>(nil)
    public func tapped(_ listChannel: ChannelUser) {
        self.listChannelTappedProperty.value = listChannel
    }
    
    fileprivate let configUserProperty = MutableProperty<ListUser?>(nil)
    public func configureWith(user: ListUser) {
        self.configUserProperty.value = user
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let channels: Signal<[ChannelUser], NoError>
    public let goToChannel: Signal<ChannelUser, NoError>
    
    public var inputs: ChannelsUserViewModelInputs { return self }
    public var outputs: ChannelsUserViewModelOutputs { return self }
}
