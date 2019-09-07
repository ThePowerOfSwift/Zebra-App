//
//  TableContentCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import ReactiveSwift
import Result

public protocol TableContentCellViewModelInputs {
    func configureWith(_ channel: UserChannel)
    func configureWith(_ channel: ListChannel)
}

public protocol TableContentCellViewModelOutputs {
    var channelTitleText: Signal<String, NoError> { get }
    var authorTitleText: Signal<String, NoError> { get }
    var blocksCountText: Signal<String, NoError> { get }
}

public protocol TableContentCellViewModelType {
    var inputs: TableContentCellViewModelInputs { get }
    var outputs: TableContentCellViewModelOutputs { get }
}

public final class TableContentCellViewModel: TableContentCellViewModelType, TableContentCellViewModelInputs, TableContentCellViewModelOutputs {
    
    public init() {
        let current = self.configListChannelProperty.signal.skipNil()
        let currentCustom = self.configCustomChannelProperty.signal.skipNil()
        
        self.channelTitleText = Signal.merge(current.signal.map { $0.title }, currentCustom.signal.map { $0.title })
        self.authorTitleText = Signal.merge(current.signal.map { $0.user.username }, currentCustom.signal.map { $0.user.username })
        self.blocksCountText = Signal.merge(current.signal.map { Format.stringToDate(rawDate: $0.updatedAt) }.map { Format.dateFormatterString(date: $0, template: "MMM d, yyyy") }, currentCustom.signal.map { Format.stringToDate(rawDate: $0.updatedAt) }.map { Format.dateFormatterString(date: $0, template: "MMM d, yyyy") })
    }
    
    fileprivate let configListChannelProperty = MutableProperty<UserChannel?>(nil)
    public func configureWith(_ channel: UserChannel) {
        self.configListChannelProperty.value = channel
    }
    
    fileprivate let configCustomChannelProperty = MutableProperty<ListChannel?>(nil)
    public func configureWith(_ channel: ListChannel) {
        self.configCustomChannelProperty.value = channel
    }
    
    public let channelTitleText: Signal<String, NoError>
    public let authorTitleText: Signal<String, NoError>
    public let blocksCountText: Signal<String, NoError>
    
    public var inputs: TableContentCellViewModelInputs { return self }
    public var outputs: TableContentCellViewModelOutputs { return self }
}
