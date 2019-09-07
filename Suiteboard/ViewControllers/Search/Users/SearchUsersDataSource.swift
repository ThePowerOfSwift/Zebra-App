//
//  SearchUsersDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 29/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import UIKit

public final class SearchUsersDataSource: ValueCellDataSource {
    
    public func load(users: [ListUser]) {
        self.set(values: users, cellClass: SearchUserViewCell.self, inSection: 0)
    }
    
    public func listUserAtIndexPath(_ indexPath: IndexPath) -> ListUser? {
        return self[indexPath] as? ListUser
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SearchUserViewCell, value as ListUser):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized instance cell:\(cell) value:\(value)")
        }
    }
}
