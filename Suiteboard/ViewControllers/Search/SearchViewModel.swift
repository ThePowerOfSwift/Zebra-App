//
//  SearchViewModel.swift
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

public protocol SearchViewModelInputs {
    func clearSearchText()
    func searchFieldDidBeginEditing()
    func searchTextChanged(_ searchText: String)
    func searchTextEditingDidEnd()
    func viewDidLoad()
    func viewWillAppear(animated: Bool)
    func tapped(channel: ListChannel)
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol SearchViewModelOutputs {
    var allChannelsIsLoading: Signal<Bool, NoError> { get }
    var channels: Signal<[ListChannel], NoError> { get }
    var scrollToChannelRow: Signal<Int, NoError> { get }
    var searchFieldText: Signal<String, NoError> { get }
    var goToChannel: Signal<ListChannel, NoError> { get }
}

public protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

public final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
    
    public init() {
        let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isFalse).ignoreValues()
        
        let query = Signal
            .merge(self.searchTextChangedProperty.signal, viewWillAppearNotAnimated.mapConst("").take(first: 1))
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
            }.skipRepeats().filter(isTrue).ignoreValues()
        

        let requestFirstPageWith = query.skipNil().filter { !$0.isEmpty }.map { return $0 }
        
        let (paginatedChannels, isLoading, _) = paginateSearchChannel(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.channels }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchChannels(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchChannels(term: term, page: page) })
        
        self.allChannelsIsLoading = isLoading.signal
        
        self.channels = paginatedChannels.signal
        self.scrollToChannelRow = .empty
        self.searchFieldText = .empty
        
        self.goToChannel = self.tappedChannelProperty.signal.skipNil()
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
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearAnimatedProperty = MutableProperty(false)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearAnimatedProperty.value = animated
    }
    
    fileprivate let tappedChannelProperty = MutableProperty<ListChannel?>(nil)
    public func tapped(channel: ListChannel) {
        self.tappedChannelProperty.value = channel
    }

    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let allChannelsIsLoading: Signal<Bool, NoError>
    public let channels: Signal<[ListChannel], NoError>
    public let scrollToChannelRow: Signal<Int, NoError>
    public let searchFieldText: Signal<String, NoError>
    public let goToChannel: Signal<ListChannel, NoError>
    
    public var inputs: SearchViewModelInputs { return self }
    public var outputs: SearchViewModelOutputs { return self }
}
