//
//  FavoriteEmptyStateCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 31/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

public final class FavoriteEmptyStateCell: UICollectionViewCell, ValueCell {
    public typealias Value = String
    
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    public func configureWith(value: String) {
        
    }
}
