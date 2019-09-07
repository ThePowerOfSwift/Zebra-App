 //
//  ChannelBlocksCollectionDataSource.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import UIKit

 public final class ChannelblocksCollectionDataSource: ValueCellDataSource {
    
    public func load(_ blocks: [Block]) {
//     print("DATA SOURCE DETECTED")
        self.set(values: blocks, cellClass: ChannelBlockCollectionViewCell.self, inSection: 0)
    }
    
    public override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ChannelBlockCollectionViewCell, value as Block):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized cell:\(cell) value:\(value)")
        }
    }
 }
