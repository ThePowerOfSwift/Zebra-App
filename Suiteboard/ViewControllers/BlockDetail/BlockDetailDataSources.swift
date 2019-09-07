//
//  BlockDetailDataSources.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import UIKit

public final class BlockDetailDataSources: ValueCellDataSource {
    
    public func load(block: BlockEnvelope) {
        self.set(values: [block], cellClass: ContentBlockTableViewCell.self, inSection: 0)
//        self.set(values: [block], cellClass: MetaBlockTableViewCell.self, inSection: 1)
        self.set(values: block.connections, cellClass: ConnectedBlockTableViewCell.self, inSection: 2)
    }
    
    public func loadTemp(block: Block) {
        
    }
    
    public func connectionAtIndexPath(_ indexPath: IndexPath) -> Connection? {
        return self[indexPath] as? Connection
    }
    
    public override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ContentBlockTableViewCell, value as BlockEnvelope):
            cell.configureWith(value: value)
        case let (cell as ConnectedBlockTableViewCell, value as Connection):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized (cell, viewModel) combo.")
        }
    }
}
