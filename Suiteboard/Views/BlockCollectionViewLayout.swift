//
//  BlockCollectionViewLayout.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 17/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit


public final class BlockCollectionViewLayout: UICollectionViewLayout {
    
    private var gridCellSpacing = CGSize(width: 10, height: 10)
    private var moreLoaderSize = CGSize(width: 50, height: 50)
    private var moreLoaderAttributes: UICollectionViewLayoutAttributes!
    
    public override func prepare() {
        
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        
        
        return result
    }
}
