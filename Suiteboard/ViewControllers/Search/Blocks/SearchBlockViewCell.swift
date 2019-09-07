//
//  SearchBlockViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 21/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class SearchBlockViewCell: UICollectionViewCell, ValueCell {
    
    public typealias Value = ListBlock
    
    fileprivate let viewModel: BlockCollectionCellViewModelType = BlockCollectionCellViewModel()
    
    @IBOutlet fileprivate weak var blockImageView: UIImageView!
//    @IBOutlet fileprivate weak var blockContentTextLabel: UILabel!
    
    public override func bindStyles() {
        super.bindStyles()
        
//        _ = self.blockContentTextLabel
//            |> UILabel.lens.isHidden .~ true
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.blockImageView.rac.hidden = self.viewModel.outputs.hideImageClass
        
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
        
        self.viewModel.outputs.contentBlockText
            .observe(on: UIScheduler())
            .observeValues { [weak self] content in
//                self?.blockContentTextLabel.text = content
        }
        
        self.viewModel.outputs.gifUrlText
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] imageUrl in
//                self?.blockImageView.image = UIImage.gif
        }
    }
    
    public func configureWith(value: ListBlock) {
        self.viewModel.inputs.configure(listBlock: value)
    }
    


}
