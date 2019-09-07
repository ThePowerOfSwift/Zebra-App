//
//  SourceWebViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol SourceWebViewModelInputs {
    func configureWith(initialRequest: URLRequest)
    func webViewConfirm(_ isLoading: Bool)
    func reloadButtonTapped()
    func safariButtonTapped()
    func viewDidLoad()
}

public protocol SourceWebViewModelOutputs {
    var showAlert: Signal<String, NoError> { get }
    var webViewLoadRequest: Signal<URLRequest, NoError> { get }
    var webIsLoading: Signal<Bool, NoError> { get }
    var goToSafari: Signal<URL, NoError> { get }
    var reloadWeb: Signal<(), NoError> { get }
}

public protocol SourceWebViewModelType {
    var inputs: SourceWebViewModelInputs { get }
    var outputs: SourceWebViewModelOutputs { get }
}

public final class SourceWebViewModel: SourceWebViewModelType, SourceWebViewModelInputs, SourceWebViewModelOutputs {
    
    public init() {
        let currentLinkRequest = Signal.combineLatest(self.viewDidLoadProperty.signal, self.configInitialRequestProperty.signal.skipNil()).map(second)
        
        self.showAlert = .empty
        self.webViewLoadRequest = currentLinkRequest.signal
        self.webIsLoading = self.webViewConfirmedLoadingProperty.signal
        
        self.goToSafari = self.webViewLoadRequest.signal.map { $0.url }.skipNil().takeWhen(self.safariTappedProperty.signal)
        self.reloadWeb = self.reloadTappedProperty.signal
    }
    
    fileprivate let configInitialRequestProperty = MutableProperty<URLRequest?>(nil)
    public func configureWith(initialRequest: URLRequest) {
        self.configInitialRequestProperty.value = initialRequest
    }
    
    fileprivate let webViewConfirmedLoadingProperty = MutableProperty(false)
    public func webViewConfirm(_ isLoading: Bool) {
        self.webViewConfirmedLoadingProperty.value = isLoading
    }
    
    fileprivate let reloadTappedProperty = MutableProperty(())
    public func reloadButtonTapped() {
        self.reloadTappedProperty.value = ()
    }
    
    fileprivate let safariTappedProperty = MutableProperty(())
    public func safariButtonTapped() {
        self.safariTappedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let showAlert: Signal<String, NoError>
    public let webViewLoadRequest: Signal<URLRequest, NoError>
    public let webIsLoading: Signal<Bool, NoError>
    public let goToSafari: Signal<URL, NoError>
    public let reloadWeb: Signal<(), NoError>
    
    public var inputs: SourceWebViewModelInputs { return self }
    public var outputs: SourceWebViewModelOutputs { return self }
}
