//
//  TableContentsDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation

public final class TableContentsDataSource: ValueCellDataSource {
    
    public func fetchSource(lists: [UserChannel]) {
        self.set(values: lists, cellClass: TableContentViewCell.self, inSection: 0)
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as TableContentViewCell, value as UserChannel):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized cell:\(cell) value:\(value)")
        }
    }
}
