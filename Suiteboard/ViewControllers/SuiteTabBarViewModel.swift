//
//  SuiteTabBarViewModel.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import Prelude
import ReactiveSwift
import Result

public struct TabBarItemsData {
    public let items: [TabBarItem]
}

public enum TabBarItem {
    case activity(index: Int)
    case profile(index: Int)
    case search(index: Int)
}

public protocol SuiteTabBarViewModelInputs {
    func viewDidLoad()
}

public protocol SuiteTabBarViewModelOutputs {
    var setViewControllers: Signal<[UIViewController], NoError> { get }
    var tabBarItemsData: Signal<TabBarItemsData, NoError> { get }
}

public protocol SuiteTabBarViewModelType {
    var inputs: SuiteTabBarViewModelInputs { get }
    var outputs: SuiteTabBarViewModelOutputs { get }
}

public final class SuiteTabBarViewModel: SuiteTabBarViewModelType, SuiteTabBarViewModelInputs, SuiteTabBarViewModelOutputs {
    
    public init() {
        
        let standardViewControllers = self.viewDidLoadProperty.signal.map { _ in
            [TableContentsViewController.instantiate(), TableSearchViewController.instantiate(), FavoritesViewController.instantiate()]
        }
        
        self.setViewControllers = standardViewControllers.signal.map { $0.map(UINavigationController.init(rootViewController:)) }
        
        self.tabBarItemsData = self.viewDidLoadProperty.signal.mapConst(tabData())
    }
    
    fileprivate let viewDidLoadProperty = MutableProperty(())
    public func viewDidLoad() {
        self.viewDidLoadProperty.value = ()
    }
    
    public let setViewControllers: Signal<[UIViewController], NoError>
    public let tabBarItemsData: Signal<TabBarItemsData, NoError>
    
    public var inputs: SuiteTabBarViewModelInputs { return self }
    public var outputs: SuiteTabBarViewModelOutputs { return self }
}

private func tabData() -> TabBarItemsData {
    let items: [TabBarItem] = [.activity(index: 0), .search(index: 1), .profile(index: 2)]
    
    return TabBarItemsData(items: items)
}

extension TabBarItemsData: Equatable {
    public static func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
        return lhs.items == rhs.items
    }
}

extension TabBarItem: Equatable {
    public static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        switch (lhs, rhs) {
        case let (.activity(lhs), .activity(index: rhs)):
            return lhs == rhs
        case let (.profile(lhs), .profile(index: rhs)):
            return lhs == rhs
        case let (.search(lhs), .search(index: rhs)):
            return lhs == rhs
        default: return false
        }
    }
}

private func first<VC: UIViewController>(_ viewController: VC.Type) -> ([UIViewController]) -> VC? {
    return { viewControllers in
        viewControllers
            .index { $0 is VC }
            .flatMap { viewControllers[$0] as? VC }
    }
}
