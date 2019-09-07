//
//  SearchChannelsViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 29/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SearchChannelsViewModelInputs {
    func viewDidLoad()
    func viewWillAppear(animated: Bool)
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
    func searchTextChanged(_ text: String)
}

public protocol SearchChannelsViewModelOutputs {
    var channelsAreLoading: Signal<Bool, NoError> { get }
    var channels: Signal<[ListChannel], NoError> { get }
//    var searchFieldText: Signal<String, NoError> { get }
    var goToChannel: Signal<ListChannel, NoError> { get }
}

public protocol SearchChannelsViewModelType {
    var inputs: SearchChannelsViewModelInputs { get }
    var outputs: SearchChannelsViewModelOutputs { get }
}

public final class SearchChannelsViewModel: SearchChannelsViewModelType, SearchChannelsViewModelInputs, SearchChannelsViewModelOutputs {
    
    public init() {
        
        let viewWillAppearNotAnimated = self.viewWillAppearAnimatedProperty.signal.filter(isFalse).ignoreValues()
        
        let query = Signal.merge(viewWillAppearNotAnimated.signal.mapConst("").take(first: 1), self.searchTextChangedProperty.signal.skipNil())
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
            }.skipRepeats().filter(isTrue).ignoreValues()
        
        let requestFirstPageWith = query.signal.filter { !$0.isEmpty }.map { return $0 }
        
        let (paginatedChannels, isLoading, _) = paginateSearchChannel(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.channels }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchChannels(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchChannels(term: term, page: page) })
        
        self.channelsAreLoading = isLoading.signal
        self.channels = paginatedChannels.signal
        self.goToChannel = .empty
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearAnimatedProperty = MutableProperty(false)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearAnimatedProperty.value = animated
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    fileprivate let searchTextChangedProperty = MutableProperty<String?>(nil)
    public func searchTextChanged(_ text: String) {
        self.searchTextChangedProperty.value = text
    }
    
    public let channelsAreLoading: Signal<Bool, NoError>
    public let channels: Signal<[ListChannel], NoError>
    public let goToChannel: Signal<ListChannel, NoError>
    
    public var inputs: SearchChannelsViewModelInputs { return self }
    public var outputs: SearchChannelsViewModelOutputs { return self }
}
