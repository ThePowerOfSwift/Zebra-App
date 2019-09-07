//
//  ChannelBlockCollectionViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import ReactiveSwift
import UIKit

public final class ChannelBlockCollectionViewCell: UICollectionViewCell, ValueCell {
    
    public typealias Value = Block
    
    fileprivate let viewModel: BlockCollectionCellViewModelType = BlockCollectionCellViewModel()
    
    @IBOutlet fileprivate weak var blockImageView: UIImageView!
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        /*
        self.viewModel.outputs.imageUrlText
            .observe(on: UIScheduler())
            .on(event: { [weak self] _ in
                print("Some Photos is nil")
                self?.blockImageView.af_cancelImageRequest()
                self?.blockImageView.image = nil
            })
            .skipNil()
            .observeValues { [weak self] imageUrl in
                self?.blockImageView.ss_setImageWithURL(imageUrl)
        }
        */
    }
    
    public func configureWith(value: Block) {
        print("IS IT REACHED INTO CHANNEL BLOCK COLLECTION VIEW CELl")
        self.viewModel.inputs.configure(block: value)
    }
    
}
