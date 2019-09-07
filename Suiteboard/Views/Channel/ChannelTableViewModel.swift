//
//  ChannelTableViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 08/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//
import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol ChannelTableCellViewModelInputs {
    func configure(connection: ListChannel)
}

public protocol ChannelTableCellViewModelOutputs {
    var titleText: Signal<String, NoError> { get }
    var userChannelText: Signal<String, NoError> { get }
}

public protocol ChannelTableCellViewModelType {
    var inputs: ChannelTableCellViewModelInputs { get }
    var outputs: ChannelTableCellViewModelOutputs { get }
}

public final class ChannelTableCellViewModel: ChannelTableCellViewModelType, ChannelTableCellViewModelInputs, ChannelTableCellViewModelOutputs {
    
    public init() {
        let connection = self.configConnectionProperty.signal.skipNil()
        
        self.titleText = connection.signal.map { $0.title }
        
        self.userChannelText = connection.signal.map { $0.user }.map { $0.username }
    }
    
    fileprivate let configConnectionProperty = MutableProperty<ListChannel?>(nil)
    public func configure(connection: ListChannel) {
        self.configConnectionProperty.value = connection
    }
    
    public let titleText: Signal<String, NoError>
    public let userChannelText: Signal<String, NoError>
    
    public var inputs: ChannelTableCellViewModelInputs { return self }
    public var outputs: ChannelTableCellViewModelOutputs { return self }
}
