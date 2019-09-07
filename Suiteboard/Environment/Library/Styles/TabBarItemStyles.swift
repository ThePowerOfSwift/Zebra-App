//
//  TabBarItemStyles.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import UIKit

private let baseTabBarItemStyle = UITabBarItem.lens.title .~ nil

public let activityTabBarItemStyle = baseTabBarItemStyle
    <> UITabBarItem.lens.image %~ { _ in UIImage(named: "contents-tab-icon") }
    <> UITabBarItem.lens.accessibilityLabel %~ { _ in "Table Contents" }
    <> UITabBarItem.lens.imageInsets %~ { _ in UIEdgeInsets(top: 6, left: 0, bottom: -4, right: 0) }

public let favoriteTabBarItemStyle = baseTabBarItemStyle
    <> UITabBarItem.lens.image %~ { _ in UIImage(named: "favorites-tab-icon") }
    <> UITabBarItem.lens.accessibilityLabel %~ { _ in "Favorites" }
    <> UITabBarItem.lens.imageInsets %~ { _ in UIEdgeInsets(top: 6, left: 0, bottom: -4, right: 0) }

public let searchTabBarItemStyle = baseTabBarItemStyle
    <> UITabBarItem.lens.image %~ { _ in UIImage(named: "search-tab-icon") }
    <> UITabBarItem.lens.accessibilityLabel %~ { _ in "Search" }
    <> UITabBarItem.lens.imageInsets %~ { _ in UIEdgeInsets(top: 6, left: 0, bottom: -4, right: 0) }
