//
//  ActivityViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol ActivityViewModelInputs {
    func configureWith(slug: String)
    func configureWith(channel: ListChannel)
    func configureWith(channel: UserChannel)
    func configureWith(connection: Connection)
    func didSelectedBlock(_ block: Block)
    func prevButtonTapped()
    func nextButtonTapped()
    func encodeRestorableState(coder: NSCoder)
    func viewDidLoad()
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol ActivityViewModelOutputs {
    var savedChannel: Signal<(NSCoder, ListChannel), NoError> { get }
    var titleChannelText: Signal<String, NoError> { get }
    var blocksAreLoading: Signal<Bool, NoError> { get }
    var blocks: Signal<[Block], NoError> { get }
    var blocksIsEmpty: Signal<Bool, NoError> { get }
    var asyncReloadData: Signal<(), NoError> { get }
    var goToBlock: Signal<Block, NoError> { get }
}

public protocol ActivityViewModelType {
    var inputs: ActivityViewModelInputs { get }
    var outputs: ActivityViewModelOutputs { get }
}

public final class ActivityViewModel: ActivityViewModelType, ActivityViewModelInputs, ActivityViewModelOutputs {
    
    public init() {
        
//        let activitiesEnvelope = self.viewDidLoadProperty.signal.switchMap { _ in AppEnvironment.current.apiService.getContentsChannel(slug: "4-1i82t8rcc", page: 0).materialize() }
        
        let currentChannel = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configListChannelProperty.signal.skipNil()).map(second)
        let currentConnection = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configConnectionProperty.signal.skipNil()).map(second)
        let currentUserChannel = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configUserChannelProperty.signal.skipNil()).map(second)
        
        self.savedChannel = .empty
        
        self.titleChannelText = Signal.merge(currentChannel.signal.map { $0.title }, currentConnection.signal.map { $0.title }, currentUserChannel.signal.map { $0.title })
        
        let selectedCurrentChannel = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configSlugProperty.signal.skipNil()).map(second)
        
        let requestFirstPage = Signal.merge(selectedCurrentChannel.signal, currentChannel.signal.map { $0.channelStatus.slug }, currentConnection.signal.map { $0.statusConnection.slug }, currentUserChannel.signal.map { $0.channelStatus.slug })
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
        }.skipRepeats().filter(isTrue).ignoreValues()
        
        
        let fetchFirstPage = requestFirstPage.signal.switchMap {
            AppEnvironment.current.apiService.getCompleteChannel(slug: $0, page: 1).materialize()
        }
        
        let nextBlocksPage = fetchFirstPage.values().takeWhen(self.nextTappedProperty.signal).switchMap {
            AppEnvironment.current.apiService.getCompleteChannel(slug: $0.channelStatus.slug, page: $0.page + 1).materialize()
        }
        
        
        let paginatedHotels: Signal<[Block], NoError>
        (paginatedHotels, self.blocksAreLoading, _) = paginate(requestFirstPageWith: requestFirstPage, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: true, skipRepeats: false, valuesFromEnvelope: { $0.contents }, cursorFromEnvelope: { ($0.channelStatus.slug, $0.page) }, requestFromParams: { params in AppEnvironment.current.apiService.getCompleteChannel(slug: params, page: 1) }, requestFromCursor: { (slug, count) in AppEnvironment.current.apiService.getCompleteChannel(slug: slug, page: count) }, concater: { ($0 + $1).distincts({ lhs, rhs in lhs.classBlock == .Unknown && rhs.classBlock == .Unknown}) })
        
//        self.blocksAreLoading = .empty
        
        self.blocks = paginatedHotels.signal.skip { $0.isEmpty }.skipRepeats(==)
        
        self.blocksIsEmpty = Signal.merge(self.blocks.map { $0.isEmpty }, self.blocksAreLoading.signal.mapConst(false))
            
            // Signal.merge(fetchFirstPage.values().map { $0.contents }.skip { $0.isEmpty }.skipRepeats(==) , nextBlocksPage.values().map { $0.contents }.skip { $0.isEmpty }.skipRepeats(==) )
        
        self.asyncReloadData = self.blocks.take(first: 1).ignoreValues()
        
        self.goToBlock = self.selectedBlockProperty.signal.skipNil()
    }
    
    fileprivate let configSlugProperty = MutableProperty<String?>(nil)
    public func configureWith(slug: String) {
        self.configSlugProperty.value = slug
    }
    
    fileprivate let configListChannelProperty = MutableProperty<ListChannel?>(nil)
    public func configureWith(channel: ListChannel) {
        self.configListChannelProperty.value = channel
    }
    
    fileprivate let configUserChannelProperty = MutableProperty<UserChannel?>(nil)
    public func configureWith(channel: UserChannel) {
        self.configUserChannelProperty.value = channel
    }
    
    fileprivate let configConnectionProperty = MutableProperty<Connection?>(nil)
    public func configureWith(connection: Connection) {
        self.configConnectionProperty.value = connection
    }
    
    fileprivate let selectedBlockProperty = MutableProperty<Block?>(nil)
    public func didSelectedBlock(_ block: Block) {
        self.selectedBlockProperty.value = block
    }
    
    fileprivate let prevTappedProperty = MutableProperty(())
    public func prevButtonTapped() {
        self.prevTappedProperty.value = ()
    }
    
    fileprivate let nextTappedProperty = MutableProperty(())
    public func nextButtonTapped() {
        self.nextTappedProperty.value = ()
    }
    
    fileprivate let encodeStateCoderProperty = MutableProperty<NSCoder?>(nil)
    public func encodeRestorableState(coder: NSCoder) {
        self.encodeStateCoderProperty.value = coder
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let savedChannel: Signal<(NSCoder, ListChannel), NoError>
    public let titleChannelText: Signal<String, NoError>
    public let blocksAreLoading: Signal<Bool, NoError>
    public let blocks: Signal<[Block], NoError>
    public let blocksIsEmpty: Signal<Bool, NoError>
    public let asyncReloadData: Signal<(), NoError>
    public let goToBlock: Signal<Block, NoError>
    
    public var inputs: ActivityViewModelInputs { return self }
    public var outputs: ActivityViewModelOutputs { return self }
}

/*
private func latestBlocks(contents: [Block]) -> [Block] {
    var newMixed = contents
    newMixed.reverse()
    return newMixed
}
*/
