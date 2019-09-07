//
//  ConnectedBlockCellViewModel.swift
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

public protocol ConnectedBlockCellViewModelInputs {
    func configure(connection: Connection)
}

public protocol ConnectedBlockCellViewModelOutputs {
    var titleText: Signal<String, NoError> { get }
    var userChannelText: Signal<String, NoError> { get }
}

public protocol ConnectedBlockCellViewModelType {
    var inputs: ConnectedBlockCellViewModelInputs { get }
    var outputs: ConnectedBlockCellViewModelOutputs { get }
}

public final class ConnectedBlockCellViewModel: ConnectedBlockCellViewModelType, ConnectedBlockCellViewModelInputs, ConnectedBlockCellViewModelOutputs {
    
    public init() {
        let connection = self.configConnectionProperty.signal.skipNil()
        
        self.titleText = connection.signal.map { $0.title }
        
        self.userChannelText = connection.signal.map { $0.user.fullName }
    }
    
    fileprivate let configConnectionProperty = MutableProperty<Connection?>(nil)
    public func configure(connection: Connection) {
        self.configConnectionProperty.value = connection
    }
    
    public let titleText: Signal<String, NoError>
    public let userChannelText: Signal<String, NoError>
    
    public var inputs: ConnectedBlockCellViewModelInputs { return self }
    public var outputs: ConnectedBlockCellViewModelOutputs { return self }
}

