//
//  AppEnvironment.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 31/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import ReactiveSwift

public struct AppEnvironment {
    internal static let environmentStorageKey = "firasrafislam.Suiteboard.AppEnvironment.current"
    
    fileprivate static var stack: [Environment] = [Environment()]
    
    public static var current: Environment! {
        return stack.last
    }
    
    public static func pushEnvironment(_ env: Environment) {
        stack.append(env)
    }
    
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }
    
    
    public static func pushEnvironment(apiService: ArenaServiceType = AppEnvironment.current.apiService, apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval, calendar: Calendar = AppEnvironment.current.calendar, dateType: DateProtocol.Type = AppEnvironment.current.dateType, debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval, device: UIDeviceType = AppEnvironment.current.device, isVoiceOverRunning: Bool = AppEnvironment.current.isVoiceOverRunning, language: Language = AppEnvironment.current.language, locale: Locale = AppEnvironment.current.locale, mainBundle: NSBundleType = AppEnvironment.current.mainBundle, scheduler: DateScheduler = AppEnvironment.current.scheduler, ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore, userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {
        pushEnvironment(Environment(apiService: apiService, apiDelayInterval: apiDelayInterval, calendar: calendar, dateType: dateType, debounceInterval: debounceInterval, device: device, isVoiceOverRunning: isVoiceOverRunning, language: language, locale: locale, mainBundle: mainBundle, scheduler: scheduler, ubiquitousStore: ubiquitousStore, userDefaults: userDefaults))
    }
    
    public static func replaceCurrentEnvironment(apiService: ArenaServiceType = AppEnvironment.current.apiService, apiDelayInterval: DispatchTimeInterval = AppEnvironment.current.apiDelayInterval, calendar: Calendar = AppEnvironment.current.calendar, dateType: DateProtocol.Type = AppEnvironment.current.dateType, debounceInterval: DispatchTimeInterval = AppEnvironment.current.debounceInterval, device: UIDeviceType = AppEnvironment.current.device, isVoiceOverRunning: Bool = AppEnvironment.current.isVoiceOverRunning, language: Language = AppEnvironment.current.language, locale: Locale = AppEnvironment.current.locale, mainBundle: NSBundleType = AppEnvironment.current.mainBundle, scheduler: DateScheduler = AppEnvironment.current.scheduler, ubiquitousStore: KeyValueStoreType = AppEnvironment.current.ubiquitousStore, userDefaults: KeyValueStoreType = AppEnvironment.current.userDefaults) {
        replaceCurrentEnvironment(Environment(
            apiService: apiService, apiDelayInterval: apiDelayInterval, calendar: calendar, dateType: dateType, debounceInterval: debounceInterval, device: device, isVoiceOverRunning: isVoiceOverRunning, language: language, locale: locale, mainBundle: mainBundle, scheduler: scheduler, ubiquitousStore: ubiquitousStore, userDefaults: userDefaults
        ))
    }
    
    public static func fromStorage(ubiquitousStore: KeyValueStoreType, userDefaults: KeyValueStoreType) -> Environment {
        var service = current.apiService
        
        return Environment(apiService: service)
    }
}
