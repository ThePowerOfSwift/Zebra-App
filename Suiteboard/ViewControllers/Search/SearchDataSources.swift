//
//  SearchDataSources.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 08/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Foundation
import UIKit

internal final class SearchDataSources: ValueCellDataSource {
    
    func load(lists: [ListChannel]) {
        self.set(values: lists, cellClass: ChannelCollectViewCell.self, inSection: 0)
    }
    
    override func configureCell(collectionCell cell: UICollectionViewCell, withValue value: Any) {
        switch (cell, value) {
        case let (cell as ChannelCollectViewCell, value as ListChannel):
            cell.configureWith(value: value)
        default:
            fatalError("Unrecognized error instanced: \(cell)\(value)")
        }
    }
}
