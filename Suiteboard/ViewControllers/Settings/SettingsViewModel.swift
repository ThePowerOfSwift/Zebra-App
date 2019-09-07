//
//  SettingsViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 07/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol SettingsViewModelInputs {
    func feedbackButtonTapped()
    func viewDidLoad()
}

public protocol SettingsViewModelOutputs {
    var goToFeedback: Signal<(), NoError> { get }
    var buildVersionText: Signal<String, NoError> { get }
}

public protocol SettingsViewModelType {
    var inputs: SettingsViewModelInputs { get }
    var outputs: SettingsViewModelOutputs { get }
}

public final class SettingsViewModel: SettingsViewModelType, SettingsViewModelInputs, SettingsViewModelOutputs {
    
    public init() {
        
        self.buildVersionText = self.viewDidLoadProperty.signal.map { _ in "v\(AppEnvironment.current.mainBundle.version)" }
        
        self.goToFeedback = self.feedbackTappedProperty.signal
    }
    
    fileprivate let feedbackTappedProperty = MutableProperty(())
    public func feedbackButtonTapped() {
        self.feedbackTappedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let goToFeedback: Signal<(), NoError>
    public let buildVersionText: Signal<String, NoError>
    
    public var inputs: SettingsViewModelInputs { return self }
    public var outputs: SettingsViewModelOutputs { return self }
}
