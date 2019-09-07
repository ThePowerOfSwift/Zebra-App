//
//  Storyboards.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/02/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

public enum Storyboards: String {
    case ActiveFeed
    case EmptyStates
    case Main
    case Discovery
    case Profile
    case Search
    case User
    case BlockDetail
    case ChannelDetail
    case Channels
    case CompleteChannel
    case TableContents
    case Favorites
    case SourceBrowser
    case Settings
    
    public func instantiate<VC: UIViewController>(_ viewController: VC.Type, inBundle bundle: Bundle = .framework) -> VC {
        guard
            let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.bundleIdentifier!))
                .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
            else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }
        
        return vc
    }
}
