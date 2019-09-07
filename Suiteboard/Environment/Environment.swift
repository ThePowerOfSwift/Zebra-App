//
//  Environment.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 31/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import ReactiveSwift

public struct Environment {
    public let apiService: ArenaServiceType
    public let apiDelayInterval: DispatchTimeInterval
    public let calendar: Calendar
    public let dateType: DateProtocol.Type
    public let debounceInterval: DispatchTimeInterval
    public let device: UIDeviceType
    public let isVoiceOverRunning: Bool
    public let language: Language
    public let locale: Locale
    public let mainBundle: NSBundleType
    public let scheduler: DateScheduler
    public let ubiquitousStore: KeyValueStoreType
    public let userDefaults: KeyValueStoreType
    
    public init(apiService: ArenaServiceType = ArenaServices(),
                apiDelayInterval: DispatchTimeInterval = .seconds(0),
                calendar: Calendar = Calendar.current,
                dateType: DateProtocol.Type = Date.self,
                debounceInterval: DispatchTimeInterval = .milliseconds(300),
                device: UIDeviceType = UIDevice.current,
                isVoiceOverRunning: Bool = UIAccessibility.isVoiceOverRunning,
                language: Language = Language(languageStrings: Locale.preferredLanguages) ?? Language.en,
                locale: Locale = Locale.current,
                mainBundle: NSBundleType = Bundle.main,
                scheduler: DateScheduler = QueueScheduler.main,
                ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default,
                userDefaults: KeyValueStoreType = UserDefaults.standard) {
        self.apiService = apiService
        self.apiDelayInterval = apiDelayInterval
        self.calendar = calendar
        self.dateType = dateType
        self.debounceInterval = debounceInterval
        self.device = device
        self.isVoiceOverRunning = isVoiceOverRunning
        self.language = language
        self.locale = locale
        self.mainBundle = mainBundle
        self.scheduler = scheduler
        self.ubiquitousStore = ubiquitousStore
        self.userDefaults = userDefaults
    }
}
