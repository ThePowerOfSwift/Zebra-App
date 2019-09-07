//
//  FavoritesViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import Prelude
import ArenaAPIModels
import RealmSwift
import ReactiveSwift
import Result

internal protocol FavoritesViewModelInputs {
    func tappedLocal(_ block: BlockLocal)
    func settingsButtonTapped()
    func viewDidLoad()
    func viewDidAppear()
}

internal protocol FavoritesViewModelOutputs {
    var issuedList: Signal<List<BlockLocal>, NoError> { get }
    var showEmptyState: Signal<Bool, NoError> { get }
    var goToBlockDetail: Signal<BlockLocal, NoError> { get }
    var goToSettings: Signal<(), NoError> { get }
}

internal protocol FavoritesViewModelType {
    var inputs: FavoritesViewModelInputs { get }
    var outputs: FavoritesViewModelOutputs { get }
}

internal final class FavoritesViewModel: FavoritesViewModelType, FavoritesViewModelInputs, FavoritesViewModelOutputs {
    
    public init() {
        let current = self.viewDidAppearProperty.signal.map { _ in getFavoritesBlocks() }
        
        self.issuedList = current.signal.skipNil()
        
        self.showEmptyState = self.issuedList.signal.map { $0.isEmpty }
        
        self.goToBlockDetail = self.tappedLocalBlockProperty.signal.skipNil()
        
        self.goToSettings = self.settingsTappedProperty.signal
    }
    
    fileprivate let tappedLocalBlockProperty = MutableProperty<BlockLocal?>(nil)
    func tappedLocal(_ block: BlockLocal) {
        self.tappedLocalBlockProperty.value = block
    }
    
    fileprivate let settingsTappedProperty = MutableProperty(())
    func settingsButtonTapped() {
        self.settingsTappedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let viewDidAppearProperty = MutableProperty(())
    func viewDidAppear() {
        self.viewDidAppearProperty.value = ()
    }
    
    public let issuedList: Signal<List<BlockLocal>, NoError>
    public let showEmptyState: Signal<Bool, NoError>
    public let goToBlockDetail: Signal<BlockLocal, NoError>
    public let goToSettings: Signal<(), NoError>
    
    var inputs: FavoritesViewModelInputs { return self }
    var outputs: FavoritesViewModelOutputs { return self }
}

private func getFavoritesBlocks() -> List<BlockLocal>? {
    let realm = Realm.current
    guard let indivFavorites = realm?.objects(IndividualFavorite.self).first else { return nil }
    return indivFavorites.items
}
