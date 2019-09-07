//
//  TableSearchChannelViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 23/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import UIKit
import ArenaAPIModels
import Prelude
import ReactiveSwift

public final class TableSearchChannelViewCell: UITableViewCell, ValueCell {
    
    public typealias Value = ListChannel
    
    fileprivate let viewModel: TableContentCellViewModelType = TableContentCellViewModel()
    
    @IBOutlet fileprivate weak var lastUpdatedLabel: UILabel!
    @IBOutlet fileprivate weak var channelTitleLabel: UILabel!
    
    @IBOutlet fileprivate weak var channelAuthorLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self.channelTitleLabel
            |> UILabel.lens.isAccessibilityElement .~ true
            |> UILabel.lens.accessibilityTraits .~ .staticText
        
        _ = self.channelAuthorLabel
            |> UILabel.lens.isAccessibilityElement .~ true
            |> UILabel.lens.accessibilityTraits .~ .staticText
        
        self.channelTitleLabel.adjustsFontForContentSizeCategory = true
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.channelTitleLabel.rac.text = self.viewModel.outputs.channelTitleText
        self.channelAuthorLabel.rac.text = self.viewModel.outputs.authorTitleText
        self.lastUpdatedLabel.rac.text = self.viewModel.outputs.blocksCountText
    }
    
    public func configureWith(value: ListChannel) {
        self.viewModel.inputs.configureWith(value)
    }
}
