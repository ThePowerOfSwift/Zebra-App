//
//  Nib.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import UIKit

public enum Nib: String {
    case ConnectedBlockTableViewCell
    case ChannelTableViewCell
    case ChannelCollectViewCell
    case BlockImageCollectionCell
}

extension UITableView {
    public func register(nib: Nib, inBundle bundle: Bundle = .framework) {
        self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellReuseIdentifier: nib.rawValue)
    }
}

extension UICollectionView {
    public func register(nib: Nib, inBundle bundle: Bundle = .framework) {
        self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellWithReuseIdentifier: nib.rawValue)
    }
}
