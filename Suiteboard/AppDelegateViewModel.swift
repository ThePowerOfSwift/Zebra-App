//
//  AppDelegateViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 31/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result
import UIKit

public protocol AppDelegateViewModelInputs {
    func applicationDidFinishLaunching(application: UIApplication?, launchOptions: [AnyHashable: Any]?)
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    func foundRedirectUrl(_ url: URL)
}


public protocol AppDelegateViewModelOutputs {
    var applicationDidFinishLaunchingReturnValue: Bool { get }
    
    var presentViewController: Signal<UIViewController, NoError> { get }
}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs { get }
    var outputs: AppDelegateViewModelOutputs { get }
}

public final class AppDelegateViewModel: AppDelegateViewModelType, AppDelegateViewModelInputs, AppDelegateViewModelOutputs {
    
    public init() {
        
        /*
        let testRepresentBlockAreNa = self.applicationLaunchOptionsProperty.signal.switchMap { _ -> SignalProducer<Signal<BlockEnvelope, ErrorEnvelope>.Event, NoError> in AppEnvironment.current.apiService.getBlock(id: "3960443").materialize() }
        
        let testRepresentContentsChannelAreNa = self.applicationLaunchOptionsProperty.signal.switchMap { _ -> SignalProducer<Signal<ContentsChannelEnvelope, ErrorEnvelope>.Event, NoError> in AppEnvironment.current.apiService.getContentsChannel(slug: "screenshots--9").materialize() }
        
        let testRepresentCompleteChannelAreNa = self.applicationLaunchOptionsProperty.signal.switchMap { _ -> SignalProducer<Signal<CompleteChannelEnvelope, ErrorEnvelope>.Event, NoError> in AppEnvironment.current.apiService.getCompleteChannel(slug: "screenshots--9").materialize() }
        
        testRepresentCompleteChannelAreNa.values().observe(on: UIScheduler()).observeValues { block in
            print("IS THIS CONTENTS WHAT IM LOOKING FOR: \(block)")
        }
        */
        
        self.presentViewController = .empty
    }
    
    fileprivate typealias ApplicationWithOptions = (application: UIApplication?, options: [AnyHashable: Any]?)
    fileprivate let applicationLaunchOptionsProperty = MutableProperty<ApplicationWithOptions?>(nil)
    public func applicationDidFinishLaunching(application: UIApplication?, launchOptions: [AnyHashable : Any]?) {
        self.applicationLaunchOptionsProperty.value = (application, launchOptions)
    }
    
    fileprivate let applicationWillEnterForegroundProperty = MutableProperty(())
    public func applicationWillEnterForeground() {
        self.applicationWillEnterForegroundProperty.value = ()
    }
    
    fileprivate let applicationDidEnterBackgroundProperty = MutableProperty(())
    public func applicationDidEnterBackground() {
        self.applicationDidEnterBackgroundProperty.value = ()
    }
    
    private let foundRedirectUrlProperty = MutableProperty<URL?>(nil)
    public func foundRedirectUrl(_ url: URL) {
        self.foundRedirectUrlProperty.value = url
    }
    
    fileprivate let applicationDidFinishLaunchingReturnValueProperty = MutableProperty(true)
    public var applicationDidFinishLaunchingReturnValue: Bool {
        return applicationDidFinishLaunchingReturnValueProperty.value
    }
    
    public let presentViewController: Signal<UIViewController, NoError>
    
    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }
}
