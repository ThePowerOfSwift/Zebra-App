//
//  SuiteCollectionViewLayout.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 14/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

public protocol SuiteCollectionDelegateLayout: UICollectionViewDelegate {
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                        heightForHeaderInSection section: Int) -> CGFloat
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                        heightForFooterInSection section: Int) -> CGFloat
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                        insetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                        columnCountForSection section: Int) -> Int
}

public enum SuiteCollectionLayoutRenderDirection {
    case shortestFirst
    case leftToRight
    case rightToLeft
}

public class SuiteCollectionViewLayout: UICollectionViewLayout {
    
    public var minimumColumSpacing: CGFloat = 1.0
    public var minimumInteritemSpacing: CGFloat = 1.0
    
    public var currentOrientation: UIInterfaceOrientation!
    
    private var columnHeights: [[CGFloat]] = []
    private var sectionItemAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var allItemAttributes: [UICollectionViewLayoutAttributes] = []
    private var moreLoaderAttributes: [UICollectionViewLayoutAttributes] = []
    private var unionRects: [NSValue] = []
    private let unionSize = 20
    private let columnCount = 2
    
    public var itemRenderDirection: SuiteCollectionLayoutRenderDirection = .shortestFirst
    
    public weak var delegate: SuiteCollectionDelegateLayout?
    
    /*
    public override init() {
        super.init()
        
        self.unionRects = []
    }
    */
    
    public override func prepare() {
        super.prepare()
        
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        for section in 0 ..< numberOfSections {
            let columnCount = self.columnCountForSection(section)
            var sectionColumnHeights: [CGFloat] = []
            for idx in 0 ..< columnCount {
                sectionColumnHeights.append(CGFloat(idx))
            }
            self.columnHeights.append(sectionColumnHeights)
        }
        
        var attributes = UICollectionViewLayoutAttributes()
        var moreAttributes = UICollectionViewLayoutAttributes()
        
        for section in 0 ..< numberOfSections {
            
            let sectionInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            
            let width = self.collectionView!.bounds.size.width - sectionInsets.left - sectionInsets.right
            let columnCount = self.columnCountForSection(section)
            let spaceColumnCount = CGFloat(columnCount - 1)
            let itemWidth = floor((width - (spaceColumnCount * self.minimumColumSpacing)) / CGFloat(columnCount))
            
            let itemCount = self.collectionView!.numberOfItems(inSection: section)
            var itemAttributes: [UICollectionViewLayoutAttributes] = []
            
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = self.nextColumnIndexForItem(idx, section: section)
                let xOffset = sectionInsets.left + (itemWidth + self.minimumColumSpacing) * CGFloat(columnIndex)
                
                let yOffset = ((self.columnHeights[section] as AnyObject).object (at: columnIndex) as AnyObject).doubleValue
                let itemSize = self.delegate?.collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: CGFloat = 0.0
                if itemSize!.height > CGFloat(0) && itemSize!.width > CGFloat(0) {
                    itemHeight = floor(itemSize!.height * itemWidth / itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset!), width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                
                moreAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "MoreLoader", with: indexPath)
                
                /*
                if self.currentOrientation.isPortrait {
                    moreAttributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset!) - CGSize(width: 50, height: 50).height, width: itemWidth, height: itemHeight)
                } else {
                    moreAttributes.frame = CGRect(x: xOffset - CGSize(width: 50, height: 50).height, y: CGFloat(yOffset!), width: itemWidth, height: itemHeight)
                }
                */
 
                self.allItemAttributes.append(attributes)
                
                
                self.columnHeights[section][columnIndex] = attributes.frame.maxY + minimumInteritemSpacing
            }
            self.sectionItemAttributes.append(itemAttributes)
        }
        
        var idx = 0
        let itemCounts = self.allItemAttributes.count
        while idx < itemCounts {
            let rect1 = self.allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = self.allItemAttributes[idx].frame
            self.unionRects.append(NSValue(cgRect: rect1.union(rect2)))
            idx += 1
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        let numberOfSections = self.collectionView?.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = self.collectionView!.bounds.size as CGSize
        
        if columnHeights.count > 0 {
            if let height = self.columnHeights[columnHeights.count - 1].first {
                contentSize.height = height
                return contentSize
            }
        }
        
        return CGSize.zero
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath as NSIndexPath).section >= self.sectionItemAttributes.count {
            return nil
        }
        let list = self.sectionItemAttributes[indexPath.section]
        if (indexPath as NSIndexPath).item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }
    
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes()
    }
    
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = self.unionRects.count
        var attrs: [UICollectionViewLayoutAttributes] = []
        
        for i in 0 ..< end {
            let unionRect = self.unionRects[i]
            if rect.intersects(unionRect.cgRectValue) {
                begin = i * unionSize
            }
        }
        for i in (0 ..< self.unionRects.count).reversed() {
            let unionRect = self.unionRects[i]
            if rect.intersects(unionRect.cgRectValue) {
                end = min((i + 1) * unionSize, self.allItemAttributes.count)
                break
            }
        }
        
        
        for i in begin ..< end {
            let attr = self.allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        
        return attrs
    }
    
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width {
            return true
        }
        return false
    }
    
    private func shortestColumnIndexInSection(_ section: Int) -> Int {
        var index = 0
        var shortestHeight = CGFloat.greatestFiniteMagnitude
        for (idx, height) in self.columnHeights[section].enumerated() {
            if height < shortestHeight {
                shortestHeight = height
                index = idx
            }
        }
        return index
    }
    
    private func longestColumnIndexInSection(_ section: Int) -> Int {
        var index = 0
        var longestHeight: CGFloat = 0.0
        
        for (idx, height) in self.columnHeights[section].enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        return index
    }
    
    private func columnCountForSection(_ section: Int) -> Int {
        if let columnCount = self.delegate?.collectionView(self.collectionView!, layout: self, columnCountForSection: section) {
            return columnCount
        } else {
            return self.columnCount
        }
    }
    
    private func nextColumnIndexForItem(_ item: Int, section: Int) -> Int {
        var index = 0
        let columnCount = self.columnCountForSection(section)
        switch self.itemRenderDirection {
        case .shortestFirst:
            index = self.shortestColumnIndexInSection(section)
        case .leftToRight:
            index = (item % columnCount)
        case .rightToLeft:
            index = (columnCount - 1) - (item % columnCount)
        }
        return index
    }
 
    
}
