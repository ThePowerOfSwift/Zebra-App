//
//  ChannelCollectViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 13/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

public final class ChannelCollectViewCell: UICollectionViewCell, ValueCell {
    public typealias Value = ListChannel
    
    fileprivate let viewModel: ChannelTableCellViewModelType = ChannelTableCellViewModel()
    
    @IBOutlet fileprivate weak var channelStackView: UIStackView!
    @IBOutlet fileprivate weak var channelNameLabel: UILabel!
    @IBOutlet fileprivate weak var channelUserLabel: UILabel!
    @IBOutlet fileprivate weak var channelSeparatorView: UIView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.channelNameLabel.rac.text = self.viewModel.outputs.titleText
        self.channelUserLabel.rac.text = self.viewModel.outputs.userChannelText
    }
    
    public func configureWith(value: ListChannel) {
        self.viewModel.inputs.configure(connection: value)
    }
    
    

}
