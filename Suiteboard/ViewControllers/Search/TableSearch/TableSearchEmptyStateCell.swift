//
//  TableSearchEmptyStateCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 09/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

public final class TableSearchEmptyStateCell: UITableViewCell, ValueCell {
    
    public typealias Value = String
    
    @IBOutlet fileprivate weak var emptyStateLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configureWith(value: String) {
        
    }
}
