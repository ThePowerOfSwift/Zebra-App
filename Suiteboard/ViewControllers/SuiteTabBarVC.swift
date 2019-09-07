//
//  SuiteTabBarVC.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import ReactiveSwift
import UIKit

public final class SuiteTabBarVC: UITabBarController {
    
    fileprivate let viewModel: SuiteTabBarViewModelType = SuiteTabBarViewModel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "IBMPlexMono", size: 16.0)!
            ], for: UIControl.State.normal)
        
        _ = self.tabBar
            |> UITabBar.lens.barTintColor .~ .black
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.setViewControllers
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.setViewControllers($0, animated: false)
        }
        
        self.viewModel.outputs.tabBarItemsData
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.setTabBarItemStyles(withData: $0)
        }
    }
    
    fileprivate func setTabBarItemStyles(withData data: TabBarItemsData) {
        data.items.forEach { item in
            switch item {
            case let .activity(index: index):
                _ = tabBarItem(atIndex: index) ?|> activityTabBarItemStyle
            case let .search(index: index):
                _ = tabBarItem(atIndex: index) ?|> searchTabBarItemStyle
            case let .profile(index: index):
                _ = tabBarItem(atIndex: index) ?|> favoriteTabBarItemStyle
            }
        }
    }
    
    fileprivate func tabBarItem(atIndex index: Int) -> UITabBarItem? {
        if (self.tabBar.items?.count ?? 0) > index {
            if let item = self.tabBar.items?[index] {
                return item
            }
        }
        return nil
    }
}

extension SuiteTabBarVC: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
