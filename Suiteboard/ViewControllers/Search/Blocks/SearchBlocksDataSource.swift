//
//  SearchBlocksDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 20/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import UIKit

public final class SearchBlocksDataSource: ValueCellDataSource {
    
    public func load(blocks: [ListBlock]) {
        self.clearValues()
        self.set(values: blocks, cellClass: SearchBlockViewCell.self, inSection: 0)
    }
    
    public func load(users: [ListUser]) {
        self.clearValues()
        self.set(values: users, cellClass: SearchUserViewCell.self, inSection: 0)
    }
    
    public func load(channels: [ListChannel]) {
        self.clearValues()
        self.set(values: channels, cellClass: SearchChannelViewCell.self, inSection: 0)
    }
    
    public func blockAtIndexPath(_ indexPath: IndexPath) -> ListBlock? {
        return self[indexPath] as? ListBlock
    }
    
    public override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as SearchBlockViewCell, value as ListBlock):
            cell.configureWith(value: value)
        case let (cell as SearchUserViewCell, value as ListUser):
            cell.configureWith(value: value)
        case let (cell as SearchChannelViewCell, value as ListChannel):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized (cell, viewModel) combo.")
        }
    }
}
