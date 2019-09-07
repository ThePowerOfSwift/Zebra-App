//
//  ChannelBlocksCollectionViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

import Foundation

public protocol ChannelBlocksCollectionViewModelInputs {
    
}

public protocol ChannelBlocksCollectionViewModelOutputs {
    
}


public protocol ChannelBlocksCollectionViewModelType {
    var inputs: ChannelBlocksCollectionViewModelInputs { get }
    var outputs: ChannelBlocksCollectionViewModelOutputs { get }
}

public final class ChannelBlocksCollectionViewModel: ChannelBlocksCollectionViewModelType, ChannelBlocksCollectionViewModelInputs, ChannelBlocksCollectionViewModelOutputs {
    
    
    
    public var inputs: ChannelBlocksCollectionViewModelInputs { return self }
    public var outputs: ChannelBlocksCollectionViewModelOutputs { return self }
}
