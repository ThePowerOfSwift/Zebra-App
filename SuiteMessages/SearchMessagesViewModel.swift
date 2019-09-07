//
//  SearchMessagesViewModel.swift
//  SuiteMessages
//
//  Created by Firas Rafislam on 10/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SearchMessagesViewModelInputs {
    func viewDidLoad()
}

public protocol SearchMessagesViewModelOutputs {
    var blocks: Signal<[Block], NoError> { get }
    var searchFieldText: Signal<String, NoError> { get }
}

public protocol SearchMessagesViewModelType {
    var inputs: SearchMessagesViewModelInputs { get }
    var outputs: SearchMessagesViewModelOutputs { get }
}

public final class SearchMessagesViewModel: SearchMessagesViewModelType, SearchMessagesViewModelInputs, SearchMessagesViewModelOutputs {
    
    
    public init() {
        self.blocks = .empty
        self.searchFieldText = .empty
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let blocks: Signal<[Block], NoError>
    public let searchFieldText: Signal<String, NoError>
    
    public var inputs: SearchMessagesViewModelInputs { return self }
    public var outputs: SearchMessagesViewModelOutputs { return self }
}
