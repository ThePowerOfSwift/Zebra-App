//
//  ContentBlockCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import RealmSwift
import ReactiveSwift
import Result

public protocol ContentBlockCellViewModelInputs {
    func configure(block: BlockEnvelope)
    func configure(block: Block)
    func localFromNotification(block: BlockLocal)
    func getImageBlock(data: Data?)
    func isFavoriteSelectedButton(selected: Bool)
    func sourceButtonTapped()
    func favoriteButtonTapped()
    func shareButtonTapped()
}

public protocol ContentBlockCellViewModelOutputs {
    var imageUrlText: Signal<URL?, NoError> { get }
    var blockClassText: Signal<String, NoError> { get }
    var hideImageClass: Signal<Bool, NoError> { get }
    var hideTextClass: Signal<Bool, NoError> { get }
    var sourceTapped: Signal<(), NoError> { get }
    var shareImageTapped: Signal<Data, NoError> { get }
    var shareLinkTapped: Signal<URL, NoError> { get }
    var shareTextTapped: Signal<String, NoError> { get }
    var setFavoriteButton: Signal<Bool, NoError> { get }
    var syncFavorite: Signal<Data, NoError> { get }
    var saveBlock: Signal<(Int, Data), NoError> { get }
    var saveTextBlock: Signal<(Int, String), NoError> { get }
    var deleteBlock: Signal<BlockLocal, NoError> { get }
}

public protocol ContentBlockCellViewModelType {
    var inputs: ContentBlockCellViewModelInputs { get }
    var outputs: ContentBlockCellViewModelOutputs { get }
}

public final class ContentBlockCellViewModel: ContentBlockCellViewModelType, ContentBlockCellViewModelInputs, ContentBlockCellViewModelOutputs {
    
    public init() {
        let blockEnv = self.configBlockProperty.signal.skipNil()
        
        self.imageUrlText = blockEnv.signal.map { $0.image }.skipNil().map { $0.origin.url }.map(URL.init(string:))
        
        self.blockClassText = blockEnv.signal.map { $0.content }.skipNil().skipRepeats()
        
        self.hideImageClass = blockEnv.signal.map { $0.classBlock == "Text" }
        
        self.hideTextClass = Signal.merge(blockEnv.signal.map { $0.classBlock == "Image" }, blockEnv.signal.map { $0.classBlock == "Link" })
        
        self.sourceTapped = self.sourceTappedProperty.signal
        
        let blockFavoriteFromNotification = blockEnv.takePairWhen(self.notifLocalBlockProperty.signal.skipNil()).filter { String($0.0.id) == $0.1.rid }.map { $0.1 }
        
        self.setFavoriteButton = Signal.merge(self.favoriteIsSelectedProperty.signal, blockEnv.signal.map { isSavedFavoriteBlock(String($0.id)) })
        
        self.setFavoriteButton.observe(on: UIScheduler()).observeValues { showed in
            print("WHAT FAVORITE STATUS: \(showed)")
        }
        
        self.syncFavorite = self.getImageBlockProperty.signal.skipNil()
        
        self.saveBlock = Signal.combineLatest(blockEnv.signal.filter { isFalse(isSavedFavoriteBlock(String($0.id))) }.map { $0.id }, self.getImageBlockProperty.signal.skipNil()).takeWhen(self.favoriteTappedProperty.signal)
        
        self.saveTextBlock = Signal.combineLatest(blockEnv.signal.filter { $0.classBlock == "Text" }.map { $0.id }, self.blockClassText.signal).skipRepeats(==).takeWhen(self.favoriteTappedProperty.signal)
        
        self.deleteBlock = Signal.merge(self.saveBlock.signal.map { isCurrentFavoriteBlock(String($0.0)) }, blockEnv.signal.map { isCurrentFavoriteBlock(String($0.id)) }).skipNil().takeWhen(self.favoriteTappedProperty.signal)
        
        self.shareImageTapped = Signal.combineLatest(blockEnv.signal.filter { $0.classBlock == "Image" }.ignoreValues(),  self.getImageBlockProperty.signal.skipNil()).map(second).takeWhen(self.shareTappedProperty.signal)
        
        self.shareLinkTapped = blockEnv.signal.filter { $0.classBlock == "Link" }.map { $0.source }.skipNil().map { $0.url }.map(URL.init(string:)).skipNil().takeWhen(self.shareTappedProperty.signal)
        
        self.shareTextTapped = blockEnv.signal.filter { $0.classBlock == "Text" }.map { $0.content }.skipNil().takeWhen(self.shareTappedProperty.signal)
    }
    
    fileprivate let configBlockProperty = MutableProperty<BlockEnvelope?>(nil)
    public func configure(block: BlockEnvelope) {
        self.configBlockProperty.value = block
    }
    
    fileprivate let configBlockTempProperty = MutableProperty<Block?>(nil)
    public func configure(block: Block) {
        self.configBlockTempProperty.value = block
    }
    
    fileprivate let notifLocalBlockProperty = MutableProperty<BlockLocal?>(nil)
    public func localFromNotification(block: BlockLocal) {
        self.notifLocalBlockProperty.value = block
    }
    
    fileprivate let getImageBlockProperty = MutableProperty<Data?>(nil)
    public func getImageBlock(data: Data?) {
        self.getImageBlockProperty.value = data
    }
    
    fileprivate let favoriteIsSelectedProperty = MutableProperty(false)
    public func isFavoriteSelectedButton(selected: Bool) {
        self.favoriteIsSelectedProperty.value = selected
    }
    
    fileprivate let sourceTappedProperty = MutableProperty(())
    public func sourceButtonTapped() {
        self.sourceTappedProperty.value = ()
    }
    
    fileprivate let favoriteTappedProperty = MutableProperty(())
    public func favoriteButtonTapped() {
        self.favoriteTappedProperty.value = ()
    }
    
    fileprivate let shareTappedProperty = MutableProperty(())
    public func shareButtonTapped() {
        self.shareTappedProperty.value = ()
    }
    
    public let imageUrlText: Signal<URL?, NoError>
    public let blockClassText: Signal<String, NoError>
    public let hideImageClass: Signal<Bool, NoError>
    public let hideTextClass: Signal<Bool, NoError>
    public let sourceTapped: Signal<(), NoError>
    public let shareImageTapped: Signal<Data, NoError>
    public let shareLinkTapped: Signal<URL, NoError>
    public let shareTextTapped: Signal<String, NoError>
    public let setFavoriteButton: Signal<Bool, NoError>
    public let syncFavorite: Signal<Data, NoError>
    public let saveBlock: Signal<(Int, Data), NoError>
    public let saveTextBlock: Signal<(Int, String), NoError>
    public let deleteBlock: Signal<BlockLocal, NoError>
    
    public var inputs: ContentBlockCellViewModelInputs { return self }
    public var outputs: ContentBlockCellViewModelOutputs { return self }
}

private func isSavedFavoriteBlock(_ localId: String) -> Bool {
    let realm = Realm.current
    guard let favoriteIndividual = realm?.objects(IndividualFavorite.self).first else { return false }
    return !favoriteIndividual.items.filter({ $0.rid == localId }).isEmpty
}

private func isCurrentFavoriteBlock(_ localId: String) -> BlockLocal? {
    let realm = Realm.current
    guard let favoriteIndividual = realm?.objects(IndividualFavorite.self).first else { return nil }
    guard let oneBlock = favoriteIndividual.items.filter({ $0.rid == localId }).first else { return nil }
    return oneBlock
}


