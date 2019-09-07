//
//  ActivityDataSources.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import UIKit


internal final class ActivityDataSource: ValueCellDataSource {
    
    internal func load(blocks: [Block]) {
        self.set(values: blocks, cellClass: BlockImageCollectionCell.self, inSection: 0)
    }
    
    internal func issueAtIndexPath(_ indexPath: IndexPath) -> Block? {
        return self[indexPath] as? Block
    }
    
    internal func indexPath(forCategoryId categoryId: String?) -> IndexPath? {
        for (idx, value) in self[section: 0].enumerated() {
            guard let row = value as? Block else { continue }
            if String(row.id) == categoryId {
                return IndexPath(item: idx, section: 0)
            }
        }
        
        return nil
    }
    
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as BlockImageCollectionCell, value as Block):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized (cell, viewModel) combo.")
        }
    }
}
