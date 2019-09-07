//
//  CompleteChannelViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result


public protocol CompleteChannelViewModelInputs {
    func configureWith(connection: Connection)
    func configureWith(channel: ListChannel)
    func configureWith(userChannel: ChannelUser)
    func didSelectedBlock(block: Block)
    func backButtonTapped()
    func viewDidLoad()
    func viewWillAppear()
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol CompleteChannelViewModelOutputs {
    var hideEmptyState: Signal<(), NoError> { get }
    var blocks: Signal<[Block], NoError> { get }
    var blocksAreLoading: Signal<Bool, NoError> { get }
    var titleChannelText: Signal<String, NoError> { get }
    var dismissChannel: Signal<(), NoError> { get }
    var goToBlock: Signal<Block, NoError> { get }
    var showEmptyState: Signal<(), NoError> { get }
}

public protocol CompleteChannelViewModelType {
    var inputs: CompleteChannelViewModelInputs { get }
    var outputs: CompleteChannelViewModelOutputs { get }
}

public final class CompleteChannelViewModel: CompleteChannelViewModelType, CompleteChannelViewModelInputs, CompleteChannelViewModelOutputs {
    
    public init() {
        
        let current = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configConnectionProperty.signal.skipNil()).map(second)
        let currentListChannel = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configListChannelProperty.signal.skipNil()).map(second)
        let currentUserChannel = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configUserChannelProperty.signal.skipNil()).map(second)
        
        let requestFirstPage = Signal.merge(current.signal.map { $0.statusConnection.slug }, currentListChannel.signal.map { $0.channelStatus.slug }, currentUserChannel.signal.map { $0.channelStatus.slug })
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
            }.skipRepeats().filter(isTrue).ignoreValues()
        
        let paginatedBlocks: Signal<[Block], NoError>
        (paginatedBlocks, self.blocksAreLoading, _) = paginate(requestFirstPageWith: requestFirstPage, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: true, skipRepeats: false, valuesFromEnvelope: { $0.contents }, cursorFromEnvelope: { ( $0.channelStatus.slug, $0.page) }, requestFromParams: { params in AppEnvironment.current.apiService.getCompleteChannel(slug: params, page: 1) }, requestFromCursor: { (slug, count) in AppEnvironment.current.apiService.getCompleteChannel(slug: slug, page: count) }, concater: { ($0 + $1).distincts() })
        
        self.titleChannelText = Signal.merge(current.signal.map { $0.title }, currentListChannel.signal.map { $0.title }, currentUserChannel.signal.map { $0.title })
        
        self.blocks = paginatedBlocks.signal
        
        self.showEmptyState = paginatedBlocks.signal.filter { $0.isEmpty }.ignoreValues()
        
        self.hideEmptyState = Signal.merge(self.viewWillAppearProperty.signal.take(first: 1), paginatedBlocks.filter { !$0.isEmpty }.ignoreValues())
        
        self.dismissChannel = self.backButtonTappedProperty.signal
        
        self.goToBlock = self.didSelectedBlockProperty.signal.skipNil()
    }
    
    fileprivate let configConnectionProperty = MutableProperty<Connection?>(nil)
    public func configureWith(connection: Connection) {
        self.configConnectionProperty.value = connection
    }
    
    fileprivate let configListChannelProperty = MutableProperty<ListChannel?>(nil)
    public func configureWith(channel: ListChannel) {
        self.configListChannelProperty.value = channel
    }
    
    fileprivate let configUserChannelProperty = MutableProperty<ChannelUser?>(nil)
    public func configureWith(userChannel: ChannelUser) {
        self.configUserChannelProperty.value = userChannel
    }
    
    fileprivate let didSelectedBlockProperty = MutableProperty<Block?>(nil)
    public func didSelectedBlock(block: Block) {
        self.didSelectedBlockProperty.value = block
    }
    
    fileprivate let backButtonTappedProperty = MutableProperty(())
    public func backButtonTapped() {
        self.backButtonTappedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty(())
    public func viewWillAppear() {
        self.viewWillAppearProperty.value = ()
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let hideEmptyState: Signal<(), NoError>
    public let blocks: Signal<[Block], NoError>
    public let blocksAreLoading: Signal<Bool, NoError>
    public let titleChannelText: Signal<String, NoError>
    public let dismissChannel: Signal<(), NoError>
    public let goToBlock: Signal<Block, NoError>
    public let showEmptyState: Signal<(), NoError>
    
    public var inputs: CompleteChannelViewModelInputs { return self }
    public var outputs: CompleteChannelViewModelOutputs { return self }
}
