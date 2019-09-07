//
//  BlockDetailViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import AlamofireImage
import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import RealmSwift
import Result

public protocol BlockDetailViewModelInputs {
    func configureWith(block: Block)
    func configureWith(local: BlockLocal)
    func configureWith(listBlock: ListBlock)
    func getBlockImageData(image: Data)
    func didSelect(connection: Connection)
    func cancelButtonTapped()
    func sourceButtonTapped()
    func favoriteButtonTapped()
    func shareButtonTapped()
    func viewDidLoad()
}

public protocol BlockDetailViewModelOutputs {
    var backToChannel: Signal<(), NoError> { get }
    var blockIsLoading: Signal<Bool, NoError> { get }
    var goToChannel: Signal<Connection, NoError> { get }
    var goToSource: Signal<URL, NoError> { get }
    var getBlock: Signal<BlockEnvelope, NoError> { get }
    var gotFavorite: Signal<(), NoError> { get }
    var gotShareImage: Signal<Data, NoError> { get }
    var gotShareText: Signal<String, NoError> { get }
    var gotShareLink: Signal<URL, NoError> { get }
}

public protocol BlockDetailViewModelType {
    var inputs: BlockDetailViewModelInputs { get }
    var outputs: BlockDetailViewModelOutputs { get }
}

public final class BlockDetailViewModel: BlockDetailViewModelType, BlockDetailViewModelInputs, BlockDetailViewModelOutputs {
    
    public init() {
        let currentBlock = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configBlockProperty.signal.skipNil()).map(second)
        
        let currentListBlock = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configListBlockProperty.signal.skipNil()).map(second)
        
        let currentLocalBlock = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configLocalBlockProperty.signal.skipNil()).map(second)
        
        let isLoading = MutableProperty(false)
        let fetchService = Signal.merge(currentBlock.signal.map { String($0.id) }, currentListBlock.signal.map { $0.id }, currentLocalBlock.signal.map { $0.rid }.skipNil()).switchMap { AppEnvironment.current.apiService.getBlock(id: $0).ss_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler).on(started: { isLoading.value = true }, terminated: { isLoading.value = false }).materialize() }
    
        self.blockIsLoading = isLoading.signal
        
        self.backToChannel = self.cancelTappedProperty.signal
        
        self.getBlock = fetchService.values()
        
        self.goToChannel = self.didSelectConnectionProperty.signal.skipNil()
        
        self.goToSource = self.getBlock.signal.map { $0.source }.skipNil().map { $0.url }.map(URL.init(string:)).skipNil().takeWhen(self.sourceTappedProperty.signal)
        
        self.gotFavorite = .empty
        
        self.gotShareImage = Signal.combineLatest(fetchService.values().signal.filter { $0.classBlock == "Image" }.ignoreValues(),  self.getBlockImageDataProperty.signal.skipNil()).map(second).takeWhen(self.shareTappedProperty
        .signal)
        
        self.gotShareText = fetchService.values().signal.filter { $0.classBlock == "Text" }.map { $0.content }.skipNil().takeWhen(self.shareTappedProperty.signal)
        
        self.gotShareLink = fetchService.values().signal.filter { $0.classBlock == "Link" }.map { $0.source }.skipNil().map { $0.url }.map(URL.init(string:)).skipNil().takeWhen(self.shareTappedProperty.signal)
        
    }
    
    fileprivate let configBlockProperty = MutableProperty<Block?>(nil)
    public func configureWith(block: Block) {
        self.configBlockProperty.value = block
    }
    
    fileprivate let configLocalBlockProperty = MutableProperty<BlockLocal?>(nil)
    public func configureWith(local: BlockLocal) {
        self.configLocalBlockProperty.value = local
    }
    
    fileprivate let configListBlockProperty = MutableProperty<ListBlock?>(nil)
    public func configureWith(listBlock: ListBlock) {
        self.configListBlockProperty.value = listBlock
    }
    
    fileprivate let getBlockImageDataProperty = MutableProperty<Data?>(nil)
    public func getBlockImageData(image: Data) {
        self.getBlockImageDataProperty.value = image
    }
    
    fileprivate let didSelectConnectionProperty = MutableProperty<Connection?>(nil)
    public func didSelect(connection: Connection) {
        self.didSelectConnectionProperty.value = connection
    }
    
    fileprivate let cancelTappedProperty = MutableProperty(())
    public func cancelButtonTapped() {
        self.cancelTappedProperty.value = ()
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
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let backToChannel: Signal<(), NoError>
    public let blockIsLoading: Signal<Bool, NoError>
    public let goToChannel: Signal<Connection, NoError>
    public let goToSource: Signal<URL, NoError>
    public let getBlock: Signal<BlockEnvelope, NoError>
    public let gotFavorite: Signal<(), NoError>
    public let gotShareImage: Signal<Data, NoError>
    public let gotShareText: Signal<String, NoError>
    public let gotShareLink: Signal<URL, NoError>
    
    public var inputs: BlockDetailViewModelInputs { return self }
    public var outputs: BlockDetailViewModelOutputs { return self }
}

