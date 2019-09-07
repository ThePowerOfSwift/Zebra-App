//
//  BlockTableCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import Result
import Foundation

public protocol BlockCollectionCellViewModelInputs {
    func configure(block: Block)
    func configure(localBlock: BlockLocal)
    func configure(listBlock: ListBlock)
}

public protocol BlockCollectionCellViewModelOutputs {
    var imageUrlText: Signal<URL?, NoError> { get }
    var imageData: Signal<Data, NoError> { get }
    var startedGifAnimated: Signal<(), NoError> { get }
    var hideImageClass: Signal<Bool, NoError> { get }
    var gifUrlText: Signal<URL?, NoError> { get }
    var contentBlockText: Signal<String, NoError> { get }
    var hideBlockText: Signal<Bool, NoError> { get }
}

public protocol BlockCollectionCellViewModelType {
    var inputs: BlockCollectionCellViewModelInputs { get }
    var outputs: BlockCollectionCellViewModelOutputs { get }
}

public final class BlockCollectionCellViewModel: BlockCollectionCellViewModelType, BlockCollectionCellViewModelInputs, BlockCollectionCellViewModelOutputs {
    
    public init() {
        let block = self.configBlockProperty.signal.skipNil()
        let listBlock = self.configListBlockProperty.signal.skipNil()
        let localBlock = self.configLocalBlockProperty.signal.skipNil()
        
        let imagePrefer = Signal.merge(block.signal.map { $0.image }.skipNil(), listBlock.signal.map { $0.image }.skipNil())
        
        self.imageUrlText = imagePrefer.signal.map { $0.large.url }.map(URL.init(string:)).skipRepeats(==)
        
        self.imageData = localBlock.signal.map { $0.imageData }.skipNil()
        
        self.hideImageClass = Signal.merge(block.signal.map { $0.classBlock == .Text }, listBlock.signal.map { $0.classBlock == .Text })
        
        self.startedGifAnimated = imagePrefer.signal.filter { isTrue($0.large.url.contains(
            "gif")) }.ignoreValues().takeWhen(self.imageUrlText.signal.ignoreValues())
        
        self.gifUrlText = imagePrefer.signal.filter { isTrue($0.large.url.contains(
            "gif")) }.map { $0.origin.url }.map(URL.init(string:)).skipRepeats(==)
        
        self.contentBlockText = Signal.merge(block.signal.map { $0.content }.skipNil(), localBlock.signal.map { $0.textData }.skipNil()).skipRepeats()
        
        self.hideBlockText = self.contentBlockText.signal.map { $0.isEmpty }
    }
    
    fileprivate let configListBlockProperty = MutableProperty<ListBlock?>(nil)
    public func configure(listBlock: ListBlock) {
        self.configListBlockProperty.value = listBlock
    }
    
    fileprivate let configLocalBlockProperty = MutableProperty<BlockLocal?>(nil)
    public func configure(localBlock: BlockLocal) {
        self.configLocalBlockProperty.value = localBlock
    }
    
    fileprivate let configBlockProperty = MutableProperty<Block?>(nil)
    public func configure(block: Block) {
        self.configBlockProperty.value = block
    }
    
    public let imageUrlText: Signal<URL?, NoError>
    public let imageData: Signal<Data, NoError>
    public let startedGifAnimated: Signal<(), NoError>
    public let hideImageClass: Signal<Bool, NoError>
    public let gifUrlText: Signal<URL?, NoError>
    public let contentBlockText: Signal<String, NoError>
    public let hideBlockText: Signal<Bool, NoError>
    
    public var inputs: BlockCollectionCellViewModelInputs { return self }
    public var outputs: BlockCollectionCellViewModelOutputs { return self }
}
