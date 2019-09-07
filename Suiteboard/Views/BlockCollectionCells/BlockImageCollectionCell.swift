//
//  BlockImageCollectionCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import PINRemoteImage
import Prelude
import ReactiveSwift
import UIKit

internal final class BlockImageCollectionCell: UICollectionViewCell, ValueCell {

    public typealias Value = Block
    
    typealias ImageLoaderSuccessBlock = () -> Void
    typealias ImageLoaderFailureBlock = (Error?) -> Void
    
    fileprivate let viewModel: BlockCollectionCellViewModelType = BlockCollectionCellViewModel()
    
    private var successHandler: ImageLoaderSuccessBlock?
    private var errorHandler: ImageLoaderFailureBlock?
    @IBOutlet fileprivate weak var blockImageView: FLAnimatedImageView!
    @IBOutlet fileprivate weak var blockContentTextLabel: UILabel!
    //    @IBOutlet fileprivate weak var blockContentTextLabel: UILabel!
    
    private var aspectRatioConstraint: NSLayoutConstraint? = nil
    
    override func bindStyles() {
        super.bindStyles()
        
        _ = self.blockImageView
            |> UIImageView.lens.accessibilityTraits .~ .image
            |> UIImageView.lens.accessibilityLabel .~ "Block Image"
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.blockImageView.rac.hidden = self.viewModel.outputs.hideImageClass
        self.blockContentTextLabel.rac.text = self.viewModel.outputs.contentBlockText
        self.blockContentTextLabel.rac.hidden = self.viewModel.outputs.hideBlockText
        
        self.viewModel.outputs.imageUrlText
            .observe(on: QueueScheduler.main)
            .on(event: { [weak self] _ in
                self?.blockImageView.pin_cancelImageDownload()
                self?.blockImageView.image = nil
            })
            .skipNil()
            .observeValues { [weak self] imageUrl in
                self?.loadImage(imageUrl)
        }
        
        self.viewModel.outputs.imageData
            .observe(on: UIScheduler())
            .observeValues { [weak self] data in
                let dataLocal = FLAnimatedImage(animatedGIFData: data)
                let dataStatic = UIImage(data: data)
                self?.blockImageView.pin_updateUI(with: dataStatic, animatedImage: dataLocal)
        }
    }
    
    
    func configureWith(value: Block) {
        self.viewModel.inputs.configure(block: value)
    }
    
    func configureLocalWith(value: BlockLocal) {
        self.viewModel.inputs.configure(localBlock: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    private func callSuccessHandler() {
        guard successHandler != nil else {
            return
        }
        DispatchQueue.main.async {
            self.successHandler?()
        }
    }
    
    private func callErrorHandler(with error: Error?) {
        guard let error = error, (error as NSError).code != NSURLErrorCancelled else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.errorHandler?(error)
        }
    }
    
    private func loadImage(_ url: URL) {
        self.blockImageView.pin_setImage(from: url) { [weak self] result in
            guard let _self = self else { return }
            if result.resultType != .memoryCache {
                _self.blockImageView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    _self.blockImageView.alpha = 1.0
                }
            } else {
                _self.blockImageView.alpha = 1.0
            }
            
            _self.layoutIfNeeded()
        }
    }
}
