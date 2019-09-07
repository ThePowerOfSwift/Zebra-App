//
//  BaseStyles.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import UIKit

public enum Styles {
    public static let cornerRadius: CGFloat = 0
    public static let columnMargin: CGFloat = 10
    public static let rowMargin: CGFloat = 28
    
    public static var minimumColumnWidth: CGFloat {
        get {
            return UIDevice.isLandscapePad() ? 350 : UIDevice.isLandscapePadMini() ? 300 : UIDevice.isPad() ? 300 : 400
        }
    }
    
    public static let cellImageInset: CGFloat = 4
    public static let cellImageRatio: CGFloat = 1
}

public func baseControllerStyle <VC: UIViewControllerProtocol> () -> ((VC) -> VC) {
    return VC.lens.view.backgroundColor .~ .black
        <> (VC.lens.navigationController..navBarLens) %~ { $0.map(baseNavigationBarStyle) }
}

public func baseTableControllerStyle<TVC: UITableViewControllerProtocol> (estimatedRowHeight: CGFloat = 480.0) -> ((TVC) -> TVC) {
    let style = baseControllerStyle()
        <> TVC.lens.view.backgroundColor .~ .black
        <> TVC.lens.tableView.rowHeight .~ UITableView.automaticDimension
        <> TVC.lens.tableView.estimatedRowHeight .~ estimatedRowHeight
    
    #if os(iOS)
    return style <> TVC.lens.tableView.separatorStyle .~ .none
    #else
    return
    #endif
}


public func cellWidthForFrameWidth(_ width: CGFloat) -> CGFloat {
    let numberOfColumns = max(1, trunc(width / Styles.minimumColumnWidth))
    let numberOfMargins = numberOfColumns + 1
    let marginsWidth = numberOfMargins * Styles.columnMargin
    let columnsWidth = width - marginsWidth
    let columnWidth = trunc(columnsWidth / numberOfColumns)
    return columnWidth
}

public func cellHeightForCellWidth(_ width: CGFloat) -> CGFloat {
    let imageHeight = (width - Styles.cellImageInset) * Styles.cellImageRatio
    return imageHeight
}

public func cellHeightForFrameWidth(_ width: CGFloat) -> CGFloat {
    let cellWidth = cellWidthForFrameWidth(width)
    return cellHeightForCellWidth(cellWidth)
}

public func cellSizeForFrameWidth(_ width: CGFloat) -> CGSize {
    let cellWidth = cellWidthForFrameWidth(width)
    let cellHeight = cellHeightForCellWidth(cellWidth)
    return CGSize(width: cellWidth.zeroIfNaN(), height: cellHeight.zeroIfNaN())
}

private let navBarLens: Lens<UINavigationController?, UINavigationBar?> = Lens(
    view: { $0?.navigationBar },
    set: { _, whole in whole }
)

private let baseNavigationBarStyle =   UINavigationBar.lens.titleTextAttributes .~ [
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.font: UIFont(name: "IBMPlexMono-Medium", size: 15.0)!
    ]
    <> UINavigationBar.lens.translucent .~ false
    <> UINavigationBar.lens.barTintColor .~ .black
    <> UINavigationBar.lens.tintColor .~ .white

extension CGFloat {
    func zeroIfNaN() -> CGFloat {
        return self.isNaN ? 0.0 : self
    }
}
