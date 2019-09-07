//
//  AppDelegate.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 03/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

// Adding Files from WiFi
// Management Data
// Multitasking iPad Pro
// Adding files from multitasking
// Adding files from sharing photos
// Adding files from Browse files
// Give Security Screen Code
// And Aesthetic Board with Black or White Background

// AddFeedVC
// SettingsBoardVC
//

// Being Stack on Realm, because of invalid position row
// Then Gifs bugs, duplicates on rows

import ArenaAPIModels
import RealmSwift
import UIKit

protocol SuiteSplashController {
    var splashView: UIView { get }
    
    func toggleSplashView(hide: Bool)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SuiteSplashController {

    static var needsAuthenticated = false
    
    var window: UIWindow?
    fileprivate let viewModel: AppDelegateViewModelType = AppDelegateViewModel()
    
    internal var rootTabBarController: SuiteTabBarVC? {
        return self.window?.rootViewController as? SuiteTabBarVC
    }
    
    var splashView: UIView = UIView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UIView.doBadSwizzleStuff()
        UIViewController.doBadSwizzleStuff()
        
        self.setDefaultRealmForSuite()
        
        AppEnvironment.replaceCurrentEnvironment(
            AppEnvironment.fromStorage(ubiquitousStore: NSUbiquitousKeyValueStore.default, userDefaults: UserDefaults.standard)
        )
        
//        AppEnvironment.current.apiService.getBlock(id: "3960443")
        
        /*
        let discoverer = SuiteMediaFileDiscoverer()
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        discoverer.directoryPath = searchPaths.first!
        discoverer.delegate = self
        discoverer.startDiscovering()
        */
        
        
        
        self.viewModel.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppDelegate.needsAuthenticated = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func toggleSplashView(hide: Bool) {
        
        
    }
    
    private func setDefaultRealmForSuite() {
        /*
        var config = Realm.Configuration()
        
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("suiteboard.realm")
        config.objectTypes = [BlockLocal.self, IndividualFavorite.self, ChannelFavorite.self, ChannelGroupFavorite.self]
        
        Realm.Configuration.defaultConfiguration = config
        */
        
        let realm = Realm.current
        guard let defaultRealmConfiguration = realm?.configuration else { return }
        Realm.Configuration.defaultConfiguration = defaultRealmConfiguration
        realm?.execute({ realm in
            if realm.isEmpty {
                let individualFavorite = IndividualFavorite()
                realm.add(individualFavorite, update: true)
            }
        })
    }
    
    private func isDefaultRealmConfigured() -> Bool {
        return try! !Realm().isEmpty
    }
}


extension AppDelegate: SuiteMediaFileDiscovererDelegate {
    func mediaFilesFoundRequiringAdditionToStorageBackground(foundFiles: [String]) {
        
    }
    
    func mediaFileAdded(filePath: String, loading: Bool) {
        
    }
    
    func mediaFileChanged(filePath: String, size: CUnsignedLongLong) {
        
    }
    
    func mediaFileDeleted(filePath: String) {
        
    }
}
