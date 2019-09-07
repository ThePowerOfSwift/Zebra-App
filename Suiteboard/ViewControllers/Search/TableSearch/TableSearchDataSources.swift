//
//  TableSearchDataSources.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 23/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation

public final class TableSearchDataSources: ValueCellDataSource {
    
    public enum Section: Int {
        case SearchUser
        case SearchChannel
    }
    
    public func fetchSearch(_ users: [ListUser], channels: [ListChannel]) {
        self.set(values: users, cellClass: TableSearchUserViewCell.self, inSection: Section.SearchUser.rawValue)
        self.set(values: channels, cellClass: TableSearchChannelViewCell.self, inSection: Section.SearchChannel.rawValue)
    }
    
    public func fetchSearch(channels: [ListChannel]) {
        self.set(values: channels, cellClass: TableSearchChannelViewCell.self, inSection: 0)
    }
    
    public func showEmptyStates() {
        self.set(values: ["Nothing Happen Here, Don't be perfect"], cellClass: TableSearchEmptyStateCell.self, inSection: Section.SearchChannel.rawValue)
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as TableSearchUserViewCell, value as ListUser):
            cell.configureWith(value: value)
        case let (cell as TableSearchChannelViewCell, value as ListChannel):
            cell.configureWith(value: value)
        case let (cell as TableSearchEmptyStateCell, value as String):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized instance cell:\(cell) value:\(value)")
        }
    }
}
