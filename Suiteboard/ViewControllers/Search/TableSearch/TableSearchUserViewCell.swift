//
//  TableSearchUserViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 23/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import ReactiveSwift
import Prelude
import UIKit

public final class TableSearchUserViewCell: UITableViewCell, ValueCell {
    
    public typealias Value = ListUser
    
    @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var blocksCountLabel: UILabel!
    @IBOutlet fileprivate weak var lastUpdatedLabel: UILabel!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configureWith(value: ListUser) {
        _ = self.usernameLabel
            |> UILabel.lens.text .~ value.username
        _ = self.blocksCountLabel
            |> UILabel.lens.text .~ "\(value.userStatus.channelCount) Channels"
    }
    
    

}
