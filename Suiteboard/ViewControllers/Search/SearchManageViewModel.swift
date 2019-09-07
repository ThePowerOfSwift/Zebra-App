//
//  SearchManageViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 21/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public enum ManagedSearchTab {
    case channels
    case blocks
    case users
    
    public static let allTabs: [ManagedSearchTab] = [.channels, .blocks, .users]
}


public protocol ManagedSearchViewModelInputs {
    func clearSearchText()
    func searchFieldDidBeginEditing()
    func searchTextChanged(_ searchText: String)
    func searchTextEditingDidEnd()
    func channelsButtonTapped()
    func blocksButtonTapped()
    func usersButtonTapped()
    func pageTransition(completed: Bool)
    func viewDidLoad()
    func willTransition(toPage nextPage: Int)
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
    func navigateToCollections(_ tab: ManagedSearchTab)
}

public protocol ManagedSearchViewModelOutputs {
    
    var blocks: Signal<[ListBlock], NoError> { get }
    var channels: Signal<[ListChannel], NoError> { get }
    var users: Signal<[ListUser], NoError> { get }
    //
    var configurePagesDataSource: Signal<ManagedSearchTab, NoError> { get }
    var currentSelectedTab: ManagedSearchTab { get }
    var navigateToTab: Signal<ManagedSearchTab, NoError> { get }
    var currentSearchUpdate: Signal<(ManagedSearchTab, String), NoError> { get }
    var setSelectedButton: Signal<ManagedSearchTab, NoError> { get }
}

public protocol ManagedSearchViewModelType {
    var inputs: ManagedSearchViewModelInputs { get }
    var outputs: ManagedSearchViewModelOutputs { get }
}

public final class ManagedSearchViewModel: ManagedSearchViewModelType, ManagedSearchViewModelInputs, ManagedSearchViewModelOutputs {
    
    public init() {
        
        self.configurePagesDataSource = self.viewDidLoadProperty.signal.map { .channels }
        
//        let swipedToTab = self.willTransitionNextPageProperty.signal.takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue)).map { ManagedSearchTab.allTabs[$0] }
        
        self.navigateToTab = Signal.merge(self.viewDidLoadProperty.signal.map { .channels }, self.channelsButtonTappedProperty.signal.mapConst(.channels), self.blocksButtonTappedProperty.signal.mapConst(.blocks), self.usersButtonTappedProperty.signal.mapConst(.users))
        
        /*
        let requestFirstPageWith = Signal.combineLatest(self.searchTextChangedProperty.signal.skipNil(), self.navigateCollectTabProperty.signal.filter { $0 == .blocks }.ignoreValues()).map(first)
        
        let requestChannelPageWith = Signal.combineLatest(self.searchTextChangedProperty.signal.skipNil(), self.navigateCollectTabProperty.signal.filter { $0 == .channels }.ignoreValues()).map(first)
        
        let requestUserPageWith = Signal.combineLatest(self.searchTextChangedProperty.signal.skipNil(), self.navigateCollectTabProperty.signal.filter { $0 == .users }.ignoreValues()).map(first)
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
        }.skipRepeats().filter(isTrue).ignoreValues()
        
        
        let (paginatedBlocks, isBlocksLoading, _) = paginateSearchBlock(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.blocks }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchBlocks(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchBlocks(term: term, page: page) })
        
        let (paginatedUsers, isUsersLoading, _) = paginateSearchUsers(requestFirstPageWith: requestUserPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.users }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchUsers(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchUsers(term: term, page: page) })
        
        let (paginatedChannels, isChannelsLoading, _) = paginateSearchChannel(requestFirstPageWith: requestChannelPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.channels }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchChannels(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchChannels(term: term, page: page) }
        )
        */
        
        self.blocks = .empty
        self.channels = .empty
        self.users = .empty
        
        self.currentSearchUpdate = .empty
        
        self.setSelectedButton = self.navigateToTab.signal
    }
    
    fileprivate let clearSearchTextProperty = MutableProperty(())
    public func clearSearchText() {
        self.clearSearchTextProperty.value = ()
    }
    
    fileprivate let searchFieldBeginEditingProperty = MutableProperty(())
    public func searchFieldDidBeginEditing() {
        self.searchFieldBeginEditingProperty.value = ()
    }
    
    fileprivate let searchTextChangedProperty = MutableProperty<String?>(nil)
    public func searchTextChanged(_ searchText: String) {
        self.searchTextChangedProperty.value = searchText
    }
    
    fileprivate let searchTextEndedProperty = MutableProperty(())
    public func searchTextEditingDidEnd() {
        self.searchTextEndedProperty.value = ()
    }
    
    fileprivate let channelsButtonTappedProperty = MutableProperty(())
    public func channelsButtonTapped() {
        self.channelsButtonTappedProperty.value = ()
    }
    
    fileprivate let blocksButtonTappedProperty = MutableProperty(())
    public func blocksButtonTapped() {
        self.blocksButtonTappedProperty.value = ()
    }
    
    fileprivate let usersButtonTappedProperty = MutableProperty(())
    public func usersButtonTapped() {
        self.usersButtonTappedProperty.value = ()
    }
    
    fileprivate let pageTransitionCompletedProperty = MutableProperty(false)
    public func pageTransition(completed: Bool) {
        self.pageTransitionCompletedProperty.value = completed
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let willTransitionNextPageProperty = MutableProperty<Int>(0)
    public func willTransition(toPage nextPage: Int) {
        self.willTransitionNextPageProperty.value = nextPage
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    fileprivate let navigateCollectTabProperty = MutableProperty<ManagedSearchTab?>(nil)
    public func navigateToCollections(_ tab: ManagedSearchTab) {
        self.navigateCollectTabProperty.value = tab
    }
    
    private let currentSelectedTabProperty = MutableProperty<ManagedSearchTab>(.channels)
    public var currentSelectedTab: ManagedSearchTab {
        return self.currentSelectedTabProperty.value
    }
    
    public let blocks: Signal<[ListBlock], NoError>
    public let channels: Signal<[ListChannel], NoError>
    public let users: Signal<[ListUser], NoError>
    
    public let configurePagesDataSource: Signal<ManagedSearchTab, NoError>
    public let navigateToTab: Signal<ManagedSearchTab, NoError>
    public let setSelectedButton: Signal<ManagedSearchTab, NoError>
    public let currentSearchUpdate: Signal<(ManagedSearchTab, String), NoError>
    
    public var inputs: ManagedSearchViewModelInputs { return self }
    public var outputs: ManagedSearchViewModelOutputs { return self }
}
