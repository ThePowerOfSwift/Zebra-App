//
//  UserChannelCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol UserChannelCellViewModelInputs {
    func channelTitleButtonTapped()
    func configureWith(channel: ChannelUser)
}

public protocol UserChannelCellViewModelOutputs {
    var channelTitleText: Signal<String, NoError> { get }
    var firstBlocks: Signal<[Block], NoError> { get }
    var callSelectedChannel: Signal<ChannelUser, NoError> { get }
}


public protocol UserChannelCellViewModelType {
    var inputs: UserChannelCellViewModelInputs { get }
    var outputs: UserChannelCellViewModelOutputs { get }
}

public final class UserChannelCellViewModel: UserChannelCellViewModelType, UserChannelCellViewModelInputs, UserChannelCellViewModelOutputs {
    
    public init() {
        self.channelTitleText = self.configChannelProperty.signal.skipNil().map { $0.title }
        
        let fetchChannel = self.configChannelProperty.signal.skipNil().switchMap { userChannel in
            AppEnvironment.current.apiService.getContentsChannel(slug: userChannel.channelStatus.slug, page: 1).materialize()
        }
        
        self.firstBlocks = fetchChannel.values().map { $0.contents }
        
        self.callSelectedChannel = Signal.combineLatest(self.configChannelProperty.signal.skipNil(), self.channelTitleTappedProperty.signal).map(first)
    }
    
    fileprivate let configChannelProperty = MutableProperty<ChannelUser?>(nil)
    public func configureWith(channel: ChannelUser) {
        self.configChannelProperty.value = channel
    }
    
    fileprivate let channelTitleTappedProperty = MutableProperty(())
    public func channelTitleButtonTapped() {
        self.channelTitleTappedProperty.value = ()
    }
    
    public let channelTitleText: Signal<String, NoError>
    public let firstBlocks: Signal<[Block], NoError>
    public let callSelectedChannel: Signal<ChannelUser, NoError>
    
    public var inputs: UserChannelCellViewModelInputs { return self }
    public var outputs: UserChannelCellViewModelOutputs { return self }
}
