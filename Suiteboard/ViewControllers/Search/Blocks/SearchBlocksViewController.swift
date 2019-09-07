//
//  SearchBlocksViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 20/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

private let reuseIdentifier = "Cell"

public final class SearchBlocksViewController: UICollectionViewController {
    
    fileprivate let viewModel: SearchBlocksViewModelType = SearchBlocksViewModel()
    fileprivate let dataSource = SearchBlocksDataSource()
    
    public static func instantiate() -> SearchBlocksViewController {
        let blocksVC = Storyboards.Search.instantiate(SearchBlocksViewController.self)
        return blocksVC
    }
    
    public func configureWith(term: String) {
        self.viewModel.inputs.searchTextChanged(term)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
//        self.collectionView.register(nib: .ChannelCollectViewCell)

        // Register cell classes
        self.collectionView.dataSource = dataSource
        self.collectionView.delegate = self
        
        

        // Do any additional setup after loading the view.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.blocks
            .observe(on: UIScheduler())
            .observeValues { [weak self] blocks in
                self?.dataSource.load(blocks: blocks)
                self?.collectionView.reloadData()
        }
        
        self.viewModel.outputs.goToBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] block in
                self?.goToBlockDetail(block)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let block = self.dataSource.blockAtIndexPath(indexPath) {
            self.viewModel.inputs.tapped(block: block)
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath), outOf: self.dataSource.numberOfItems())
    }
    
    fileprivate func goToBlockDetail(_ listBlock: ListBlock) {
        let detailVC = BlockDetailViewController.configureWith(listBlock: listBlock)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension SearchBlocksViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        
        return cellSizeForFrameWidth(parentViewWidth)
    }
}
