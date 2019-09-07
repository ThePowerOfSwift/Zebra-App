//
//  SourceBrowserViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result
import WebKit

public protocol SourceBrowserViewModelInputs {
    func configureWith(source: String)
    func decidePolicyFor(navigationAction: WKNavigationActionData)
    func backBlockTapped()
    func viewDidLoad()
    func webViewDidFailProvisionalNavigation(withError error: Error)
    func webViewDidFinishNavigation()
    func webViewDidStartProvisionalNavigation()
}

public protocol SourceBrowserViewModelOutputs {
    var decidedPolicyForNavigationAction: WKNavigationActionPolicy { get }
    var loadWebViewRequest: Signal<URLRequest, NoError> { get }
    var goBackToBlock: Signal<(), NoError> { get }
    var showErrorAlert: Signal<Error, NoError> { get }
}

public protocol SourceBrowserViewModelType {
    var inputs: SourceBrowserViewModelInputs { get }
    var outputs: SourceBrowserViewModelOutputs { get }
}


public final class SourceBrowserViewModel: SourceBrowserViewModelType, SourceBrowserViewModelInputs, SourceBrowserViewModelOutputs {
    
    public init() {
        let source = Signal.combineLatest(self.sourceProperty.signal.skipNil(), self.viewDidLoadProperty.signal).map(first)
        
        let sourceURL = source.map { URL(string: $0) }.skipNil()
        
        self.loadWebViewRequest = sourceURL.map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }
        
        self.goBackToBlock = self.backBlockTappedProperty.signal
        
        self.showErrorAlert = self.webViewDidFailProvisionalNavigationProperty.signal.skipNil()
    }
    
    fileprivate let sourceProperty = MutableProperty<String?>(nil)
    public func configureWith(source: String) {
        self.sourceProperty.value = source
    }
    
    fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
    public func decidePolicyFor(navigationAction: WKNavigationActionData) {
        self.policyForNavigationActionProperty.value = navigationAction
    }
    
    fileprivate let backBlockTappedProperty = MutableProperty(())
    public func backBlockTapped() {
        self.backBlockTappedProperty.value = ()
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    fileprivate let webViewDidFailProvisionalNavigationProperty = MutableProperty(Error?.none)
    public func webViewDidFailProvisionalNavigation(withError error: Error) {
        self.webViewDidFailProvisionalNavigationProperty.value = error
        
    }
    
    fileprivate let webViewDidFinishNavigationProperty = MutableProperty(())
    public func webViewDidFinishNavigation() {
        self.webViewDidFinishNavigationProperty.value = ()
    }
    
    fileprivate let webViewDidStartProvisionalNavigationProperty = MutableProperty(())
    public func webViewDidStartProvisionalNavigation() {
        self.webViewDidStartProvisionalNavigationProperty.value = ()
    }
    fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
    public var decidedPolicyForNavigationAction: WKNavigationActionPolicy {
        return self.policyDecisionProperty.value
    }
    
    public let loadWebViewRequest: Signal<URLRequest, NoError>
    public let goBackToBlock: Signal<(), NoError>
    public let showErrorAlert: Signal<Error, NoError>
    
    public var inputs: SourceBrowserViewModelInputs { return self }
    public var outputs: SourceBrowserViewModelOutputs { return self }
}
