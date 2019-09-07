//
//  UserChannelViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public protocol UserChannelCellDelegate: class {
    func selectedChannel(cell: UserChannelViewCell, channel: ChannelUser)
}

public final class UserChannelViewCell: UITableViewCell, ValueCell {
    
    public typealias Value = ChannelUser
    
    fileprivate let viewModel: UserChannelCellViewModelType = UserChannelCellViewModel()
    fileprivate let channelDataSource = ChannelblocksCollectionDataSource()
    
//    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet fileprivate weak var channelTitleButton: UIButton!
    @IBOutlet fileprivate weak var blocksCollectionView: UICollectionView!
    
    public weak var delegate: UserChannelCellDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.channelTitleButton.addTarget(self, action: #selector(channelTitleButtonTapped), for: .touchUpInside)
        
        self.blocksCollectionView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        self.blocksCollectionView.alwaysBounceVertical = true
        
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.blocksCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.channelTitleButton.rac.title = self.viewModel.outputs.channelTitleText
        
        self.viewModel.outputs.firstBlocks
            .observe(on: UIScheduler())
            .observeValues { [weak self] blocks in
                print("WHATS LOAD IN THERE")
                self?.channelDataSource.load(blocks)
                self?.blocksCollectionView.reloadData()
        }
        
        self.viewModel.outputs.callSelectedChannel
            .observe(on: UIScheduler())
            .observeValues { [weak self] inner in
                guard let _self = self else { return }
                _self.delegate?.selectedChannel(cell: _self, channel: inner)
        }
        
    }
    
    public func configureWith(value: ChannelUser) {
        self.blocksCollectionView.dataSource = channelDataSource
        self.viewModel.inputs.configureWith(channel: value)
    }
    
    @objc fileprivate func channelTitleButtonTapped() {
        self.viewModel.inputs.channelTitleButtonTapped()
    }
}

extension UserChannelViewCell: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        print("Parent View Width: \(parentViewWidth)")
        return cellSizeForFrameWidth(parentViewWidth)
    }
}
