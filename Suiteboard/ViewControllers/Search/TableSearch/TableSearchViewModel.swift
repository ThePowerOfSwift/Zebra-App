//
//  TableSearchViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 23/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import ArenaAPIModels
import Prelude
import ReactiveSwift
import Result

public protocol TableSearchViewModelInputs {
    /// Call when the cancel button is pressed.
    func cancelButtonPressed()
    
    /// Call when the search clear button is tapped.
    func clearSearchText()
    
    /// Call when the search field begins editing.
    func searchFieldDidBeginEditing()
    
    /// Call when the user enters a new search term.
    func searchTextChanged(_ searchText: String)
    
    /// Call when the user taps the return key.
    func searchTextEditingDidEnd()
    
    /// Call when the project navigator has transitioned to a new project with its index.
//    func transitionedToProject(at row: Int, outOf totalRows: Int)
    
    /// Call when the view loads.
    func viewDidLoad()
    
    /// Call when the view will appear.
    func viewWillAppear(animated: Bool)
    
    /// Call when a channel is tapped.
    func tapped(channel: ListChannel)
    
    // Call when a user is tapped
    func tapped(user: ListUser)
    
    /**
     Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.
     
     - parameter row:       The 0-based index of the row displaying.
     - parameter totalRows: The total number of rows in the table view.
     */
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol TableSearchViewModelOutputs {
    var users: Signal<[ListUser], NoError> { get }
    var channels: Signal<[ListChannel], NoError> { get }
    var channelsIsEmpty: Signal<Bool, NoError> { get }
    var goToChannel: Signal<ListChannel, NoError> { get }
    var searchIsLoading: Signal<Bool, NoError> { get}
    var searchFieldText: Signal<String, NoError> { get }
}

public protocol TableSearchViewModelType {
    var inputs: TableSearchViewModelInputs { get }
    var outputs: TableSearchViewModelOutputs { get }
}

public final class TableSearchViewModel: TableSearchViewModelType, TableSearchViewModelInputs, TableSearchViewModelOutputs {
    
    public init() {
        
        let viewWillAppearNotAnimated = self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues()
        
        let requestFirstPageWith = Signal.merge(self.searchTextChangedProperty.signal.skipNil(), viewWillAppearNotAnimated.mapConst("").take(first: 1), self.cancelTappedProperty.signal.mapConst(""))
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3
        }.skipRepeats().filter(isTrue).ignoreValues()
        
        let (paginatedChannels, isLoading, _) = paginateSearchChannel(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.channels }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { text in AppEnvironment.current.apiService.getSearchChannels(term: text, page: 1) }, requestFromCursor: { text, page in AppEnvironment.current.apiService.getSearchChannels(term: text, page: page) })
        
        self.searchIsLoading = isLoading.signal
        
        self.users = .empty
        self.channels = paginatedChannels.signal
        
        self.channelsIsEmpty = Signal.merge(self.channels.map { $0.isEmpty }, isLoading.filter { isTrue($0) }.mapConst(false))
        
        self.goToChannel = self.tappedListChannelProperty.signal.skipNil()
        
        self.searchFieldText = .empty
    }
    
    fileprivate let cancelTappedProperty = MutableProperty(())
    public func cancelButtonPressed() {
        self.cancelTappedProperty.value = ()
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
    
    fileprivate let searchTextEndEditingProperty = MutableProperty(())
    public func searchTextEditingDidEnd() {
        self.searchTextEndEditingProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewWillAppearProperty = MutableProperty(false)
    public func viewWillAppear(animated: Bool) {
        self.viewWillAppearProperty.value = animated
    }
    
    fileprivate let tappedListUserProperty = MutableProperty<ListUser?>(nil)
    public func tapped(user: ListUser) {
        self.tappedListUserProperty.value = user
    }
    
    fileprivate let tappedListChannelProperty = MutableProperty<ListChannel?>(nil)
    public func tapped(channel: ListChannel) {
        self.tappedListChannelProperty.value = channel
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(Int, Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let users: Signal<[ListUser], NoError>
    public let channels: Signal<[ListChannel], NoError>
    public let channelsIsEmpty: Signal<Bool, NoError>
    public let goToChannel: Signal<ListChannel, NoError>
    public let searchIsLoading: Signal<Bool, NoError>
    public let searchFieldText: Signal<String, NoError>
    
    public var inputs: TableSearchViewModelInputs { return self }
    public var outputs: TableSearchViewModelOutputs { return self }
}
