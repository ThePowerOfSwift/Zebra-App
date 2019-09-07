//
//  SearchUsersViewModel.swift
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

public protocol SearchUsersViewModelInputs {
    //    func searchFieldDidBeginEditing()
    //    func searchTextChanged(_ searchText: String)
    //    func searchTextEditingDidEnd()
    func searchTextChanged(_ searchtext: String)
    func viewWillAppear(animated: Bool)
    func tapped(user: ListUser)
    func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol SearchUsersViewModelOutputs {
    var usersIsLoading: Signal<Bool, NoError> { get }
    var users: Signal<[ListUser], NoError> { get }
    var searchFieldText: Signal<String, NoError> { get }
    var goToUser: Signal<ListUser, NoError> { get }
}

public protocol SearchUsersViewModelType {
    var inputs: SearchUsersViewModelInputs { get }
    var outputs: SearchUsersViewModelOutputs { get }
}

public final class SearchUsersViewModel: SearchUsersViewModelType, SearchUsersViewModelInputs, SearchUsersViewModelOutputs {
    
    public init() {
        let viewWillAppearNotAnimated = self.viewWillAppearProperty.signal.filter(isFalse).ignoreValues()
        
        let query = self.searchTextChangedProperty.signal.skipNil()
        
        let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil().map { row, total in
            row >= total - 3 && row > 0
            
            }.skipRepeats().filter(isTrue).ignoreValues()
        
        let requestFirstPageWith = query.filter { !$0.isEmpty }.map { return $0 }
        
        let (paginatedUsers, isLoading, _) = paginateSearchUsers(requestFirstPageWith: requestFirstPageWith, requestNextPageWhen: isCloseToBottom, clearOnNewRequest: false, valuesFromEnvelope: { $0.users }, cursorFromEnvelope: { ($0.term, $0.currentPage) }, requestFromParams: { term in AppEnvironment.current.apiService.getSearchUsers(term: term, page: 1) }, requestFromCursor: { term, page in AppEnvironment.current.apiService.getSearchUsers(term: term, page: page) })
        
        self.usersIsLoading = isLoading.signal
        
        self.users = paginatedUsers.signal
        self.searchFieldText = .empty
        
        self.goToUser = self.tappedUserProperty.signal.skipNil()
        
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
    
    fileprivate let tappedUserProperty = MutableProperty<ListUser?>(nil)
    public func tapped(user: ListUser) {
        self.tappedUserProperty.value = user
    }
    
    fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
    public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
        self.willDisplayRowProperty.value = (row, totalRows)
    }
    
    public let usersIsLoading: Signal<Bool, NoError>
    public let users: Signal<[ListUser], NoError>
    public let goToUser: Signal<ListUser, NoError>
    public let searchFieldText: Signal<String, NoError>
    
    public var inputs: SearchUsersViewModelInputs { return self }
    public var outputs: SearchUsersViewModelOutputs { return self }
}
