//
//  SearchBlocksViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 20/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SearchBlocksViewModelInputs {
//    func searchFieldDidBeginEditing()
//    func searchTextChanged(_ searchText: String)
//    func searchTextEditingDidEnd()
    func searchTextChanged(_ searchText: String)
    func viewWillAppear(animated: Bool)
    func tapped(block: ListBlock)
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol SearchBlocksViewModelOutputs {
    var blocksIsLoading: Signal<Bool, NoError> { get }
    var blocks: Signal<[ListBlock], NoError> { get }
    var searchFieldText: Signal<String, NoError> { get }
    var goToBlock: Signal<ListBlock, NoError> { get }
}

public protocol SearchBlocksViewModelType {
    var inputs: SearchBlocksViewModelInputs { get }
    var outputs: SearchBlocksViewModelOutputs { get }
}

public final class SearchBlocksViewModel: SearchBlocksViewModelType, SearchBlocksViewModelInputs, SearchBlocksViewModelOutputs {
    
    public init() {
        let viewWillAppearNotAnimated = self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues()
        
        let query = Signal.merge(self.searchTextChangedProperty.signal, viewWillAppearNotAnimated.mapConst("editorial").take(first: 1))
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
            
        }.skipRepeats().filter(isTrue).ignoreValues()
        
        let requestFirstPageWith = query.skipNil().filter { !$0.isEmpty }.map { return $0 }
        
        let (paginatedBlocks, isLoading, _) = paginateSearchBlock(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.blocks }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchBlocks(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchBlocks(term: term, page: page) })
        
        self.blocksIsLoading = isLoading.signal
        
        self.blocks = paginatedBlocks.signal
        self.searchFieldText = .empty
        
        self.goToBlock = self.tappedBlockProperty.signal.skipNil()
        
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
    
    fileprivate let viewWillAppearProperty = MutableProperty(false)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    fileprivate let tappedBlockProperty = MutableProperty<ListBlock?>(nil)
    public func tapped(block: ListBlock) {
        self.tappedBlockProperty.value = block
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let blocksIsLoading: Signal<Bool, NoError>
    public let blocks: Signal<[ListBlock], NoError>
    public let goToBlock: Signal<ListBlock, NoError>
    public let searchFieldText: Signal<String, NoError>
    
    public var inputs: SearchBlocksViewModelInputs { return self }
    public var outputs: SearchBlocksViewModelOutputs { return self }
}
