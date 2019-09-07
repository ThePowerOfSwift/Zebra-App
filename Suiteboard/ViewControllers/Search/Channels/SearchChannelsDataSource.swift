//
//  SearchChannelsDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 29/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import ReactiveSwift
import UIKit

public final class SearchChannelsDataSource: ValueCellDataSource {
    
    public func configureChannels(_ lists: [ListChannel]) {
        self.set(values: lists, cellClass: ChannelTableViewCell.self, inSection: 0)
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ChannelTableViewCell, value as ListChannel):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized cell: \(cell) value: \(value)")
        }
    }
}

