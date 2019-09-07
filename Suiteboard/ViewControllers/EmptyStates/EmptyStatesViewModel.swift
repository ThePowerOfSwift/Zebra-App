//
//  EmptyStatesViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 11/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

public protocol EmptyStatesViewModelInputs {
    
}

public protocol EmptyStatesViewModelOutputs {
    
}

public protocol EmptyStatesViewModelType {
    var inputs: EmptyStatesViewModelInputs { get }
    var outputs: EmptyStatesViewModelOutputs { get }
}

public final class EmptyStatesViewModel: EmptyStatesViewModelType, EmptyStatesViewModelInputs, EmptyStatesViewModelOutputs {
    
    public init() {
        
    }
    
    public var inputs: EmptyStatesViewModelInputs { return self }
    public var outputs: EmptyStatesViewModelOutputs { return self }
}

