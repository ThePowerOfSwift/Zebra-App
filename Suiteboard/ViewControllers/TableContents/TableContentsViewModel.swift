//
//  TableContentsViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 30/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import ArenaAPIModels
import ReactiveSwift
import Result

public protocol TableContentsViewModelInputs {
    func configureWith(_ user: ListUser)
    func tappedCurated(_ channel: UserChannel)
    func viewDidLoad()
    func viewDidAppear(_ animated: Bool)
}

public protocol TableContentsViewModelOutputs {
    var contentsAreLoading: Signal<Bool, NoError> { get }
    var subInitUser: Signal<ListUser, NoError> { get }
    var channels: Signal<[UserChannel], NoError> { get }
    var goToChannel: Signal<UserChannel, NoError> { get }
}


public protocol TableContentsViewModelType {
    var inputs: TableContentsViewModelInputs { get }
    var outputs: TableContentsViewModelOutputs { get }
}

public final class TableContentsViewModel: TableContentsViewModelType, TableContentsViewModelInputs, TableContentsViewModelOutputs {
    
    public init() {
        let current = Signal.merge(self.viewDidLoadProperty.signal, self.viewDidAppearProperty.signal.ignoreValues().skipRepeats(==)).map { _ in "102941" }
        
        let tablesAreLoading = MutableProperty(false)
        let fetchTables = current.signal.switchMap {
            AppEnvironment.current.apiService.getUserFollowings(id: $0).on(started: { tablesAreLoading.value = true  }, terminated: { tablesAreLoading.value = false }).materialize()
        }
        self.contentsAreLoading = tablesAreLoading.signal
        
        self.subInitUser = .empty
        self.channels = fetchTables.values().map { $0.followings }
        
        self.goToChannel = self.tappedCuratedChannelProperty.signal.skipNil()
    }
    
    fileprivate let configListUserProperty = MutableProperty<ListUser?>(nil)
    public func configureWith(_ user: ListUser) {
        self.configListUserProperty.value = user
    }
    
    fileprivate let tappedCuratedChannelProperty = MutableProperty<UserChannel?>(nil)
    public func tappedCurated(_ channel: UserChannel) {
        self.tappedCuratedChannelProperty.value = channel
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewDidAppearProperty = MutableProperty(false)
    public func viewDidAppear(_ animated: Bool) {
        self.viewDidAppearProperty.value = animated
    }
    
    public let contentsAreLoading: Signal<Bool, NoError>
    public let subInitUser: Signal<ListUser, NoError>
    public let channels: Signal<[UserChannel], NoError>
    public let goToChannel: Signal<UserChannel, NoError>
    
    public var inputs: TableContentsViewModelInputs { return self }
    public var outputs: TableContentsViewModelOutputs { return self }
}
