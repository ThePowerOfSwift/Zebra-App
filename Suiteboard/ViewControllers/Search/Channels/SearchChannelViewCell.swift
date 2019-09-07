//
//  SearchChannelViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 13/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

public final class SearchChannelViewCell: UICollectionViewCell, ValueCell {
    
    public typealias Value = ListChannel
    
    fileprivate let viewModel: ChannelTableCellViewModelType = ChannelTableCellViewModel()
    
    @IBOutlet fileprivate weak var channelNameLabel: UILabel!
    
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.channelNameLabel.rac.text = self.viewModel.outputs.titleText
    }
    
    public func configureWith(value: ListChannel) {
        print("Channel Initialized: \(value.title)")
        self.viewModel.inputs.configure(connection: value)
    }
    
}
