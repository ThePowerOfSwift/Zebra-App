//
//  CollectionType+Helpers.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 12/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

extension BidirectionalCollection {
    public func lastIndex(where predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Index? {
        if let idx = try reversed().firstIndex(where: predicate) {
            return self.index(before: idx.base)
        }
        return nil
    }
}

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
