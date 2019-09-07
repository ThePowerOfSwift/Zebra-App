//
//  CompleteChannelDataSources.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation

public final class CompleteChannelDataSources: ValueCellDataSource {
    
    public func load(blocks: [Block]) {
        self.set(values: blocks, cellClass: BlockImageCollectionCell.self, inSection: 0)
    }
    
    public func blockAtIndexPath(_ indexPath: IndexPath) -> Block? {
        return self[indexPath] as? Block
    }
    
    public override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as BlockImageCollectionCell, value as Block):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized: \(cell)\(value)")
        }
    }
}
