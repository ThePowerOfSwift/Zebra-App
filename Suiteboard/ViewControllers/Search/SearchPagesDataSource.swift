//
//  SearchPagesDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 21/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

internal final class SearchPagesDataSource: NSObject, UIPageViewControllerDataSource {
    
    private let viewControlelrs: [UIViewController]
    
    /*
    internal init(delegate: UIViewController) {
        let channelsController = SearchChannelsViewController.instantiate()
//        channelsController.searchTextChanged("24")
        let blocksController = SearchBlocksViewController.instantiate()
        let usersController = SearchUsersViewController.instantiate()
        
        self.viewControlelrs = [channelsController, blocksController, usersController]
    }
    */
    
    internal init(delegate: UIViewController, term: String) {
        let channelsController = SearchChannelsViewController.instantiate()
        channelsController.searchTextChanged(term)
        let blocksController = SearchBlocksViewController.instantiate()
        blocksController.configureWith(term: term)
        let usersController = SearchUsersViewController.instantiate()
        usersController.searchTextChanged(term)
        
        self.viewControlelrs = [channelsController, blocksController, usersController]
    }
    
    internal func controllerFor(tab: ManagedSearchTab) -> UIViewController? {
        guard let index = indexFor(tab: tab) else { return nil }
        return self.viewControlelrs[index]
    }
    
    internal func indexFor(controller: UIViewController) -> Int? {
        return self.viewControlelrs.firstIndex(of: controller)
    }
    
    internal func indexFor(tab: ManagedSearchTab) -> Int? {
        return ManagedSearchTab.allTabs.firstIndex(of: tab)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIdx = self.viewControlelrs.firstIndex(of: viewController) else {
            fatalError("Couldn't find \(viewController) in \(self.viewControlelrs)")
        }
        
        let previousPageIdx = pageIdx - 1
        
        guard previousPageIdx >= 0 else {
            return nil
        }
        
        guard previousPageIdx < self.viewControlelrs.count else {
            return nil
        }
        
        return self.viewControlelrs[previousPageIdx]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIdx = self.viewControlelrs.firstIndex(of: viewController) else {
            fatalError("Couln't find \(viewController) in \(self.viewControlelrs)")
        }
        
        let nextPageIdx = pageIdx + 1
        
        let vcCount = self.viewControlelrs.count
        
        guard vcCount != nextPageIdx else {
            return nil
        }
        
        guard vcCount > nextPageIdx else {
            return nil
        }
        
        return self.viewControlelrs[nextPageIdx]
    }
    
    private func tabFor(controller: UIViewController) -> ManagedSearchTab? {
        guard let index = self.viewControlelrs.firstIndex(of: controller) else { return nil }
        
        return ManagedSearchTab.allTabs[index]
    }
}
