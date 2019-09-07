//
//  MetaBlockCellViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//
import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol MetaBlockCellViewModelInputs {
    func configure(block: BlockEnvelope)
    func sourceButtonTapped()
    func favoriteButtonTapped()
}

public protocol MetaBlockCellViewModelOutputs {
    var titleText: Signal<String, NoError> { get }
    var sourceTapped: Signal<(), NoError> { get }
    var favoriteTapped: Signal<(), NoError> { get }
    var infoText: Signal<String, NoError> { get }
}

public protocol MetaBlockCellViewModelType {
    var inputs: MetaBlockCellViewModelInputs { get }
    var outputs: MetaBlockCellViewModelOutputs { get }
}

public final class MetaBlockCellViewModel: MetaBlockCellViewModelType, MetaBlockCellViewModelInputs, MetaBlockCellViewModelOutputs {
    
    public init() {
        
        let block = self.configBlockProperty.signal.skipNil()
        
        self.titleText = Signal.merge(block.signal.map { $0.title }.skipNil(), block.signal.map { $0.generatedTitle })
        
        self.infoText = block.signal.map { $0.content }.skipNil()
        
        self.sourceTapped = self.sourceButtonTappedProperty.signal
        
        self.favoriteTapped = self.favoriteButtonTappedProperty.signal
    }
    
    fileprivate let configBlockProperty = MutableProperty<BlockEnvelope?>(nil)
    public func configure(block: BlockEnvelope) {
        self.configBlockProperty.value = block
    }
    
    fileprivate let sourceButtonTappedProperty = MutableProperty(())
    public func sourceButtonTapped() {
        self.sourceButtonTappedProperty.value = ()
    }
    
    fileprivate let favoriteButtonTappedProperty = MutableProperty(())
    public func favoriteButtonTapped() {
        self.favoriteButtonTappedProperty.value = ()
    }
    
    public let titleText: Signal<String, NoError>
    public let sourceTapped: Signal<(), NoError>
    public let favoriteTapped: Signal<(), NoError>
    public let infoText: Signal<String, NoError>
    
    public var inputs: MetaBlockCellViewModelInputs { return self }
    public var outputs: MetaBlockCellViewModelOutputs { return self }
}
