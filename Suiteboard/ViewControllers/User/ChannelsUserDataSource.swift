//
//  ChannelsUserDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import UIKit

public final class ChannelsUserDataSource: ValueCellDataSource {
    
    public func load(channels: [ChannelUser]) {
        self.set(values: channels, cellClass: UserChannelViewCell.self, inSection: 0)
    }
    
    public func listUserAtIndexPath(_ indexPath: IndexPath) -> ChannelUser? {
        return self[indexPath] as? ChannelUser
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as UserChannelViewCell, value as ChannelUser):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized cell:\(cell) value: \(value)")
        }
    }
}
