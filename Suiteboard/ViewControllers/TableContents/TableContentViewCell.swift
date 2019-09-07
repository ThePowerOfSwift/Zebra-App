//
//  TableContentViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 30/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class TableContentViewCell: UITableViewCell, ValueCell {

    
    public typealias Value = UserChannel
    
    fileprivate let viewModel: TableContentCellViewModelType = TableContentCellViewModel()
    
    @IBOutlet fileprivate weak var contentStackView: UIStackView!
    @IBOutlet fileprivate weak var channelTitleLabel: UILabel!
    @IBOutlet fileprivate weak var channelAuthorLabel: UILabel!
    @IBOutlet fileprivate weak var channelCountLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self.channelTitleLabel
            |> UILabel.lens.accessibilityTraits .~ .staticText
        
        _ = self.channelAuthorLabel
            |> UILabel.lens.accessibilityTraits .~ .staticText
        
        _ = self.channelCountLabel
            |> UILabel.lens.accessibilityTraits .~ .staticText
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
//        self.channelTitleLabel.rac.text = self.viewModel.outputs.channelTitleText
//        self.channelAuthorLabel.rac.text = self.viewModel.outputs.authorTitleText
//        self.channelCountLabel.rac.text = self.viewModel.outputs.blocksCountText
        
        self.viewModel.outputs.channelTitleText
            .observe(on: UIScheduler())
            .observeValues { [weak self] title in
                self?.channelTitleLabel.text = title
                self?.channelTitleLabel.accessibilityValue = title
        }
        
        self.viewModel.outputs.authorTitleText
            .observe(on: UIScheduler())
            .observeValues { [weak self] author in
                self?.channelAuthorLabel.text = author
                self?.channelAuthorLabel.accessibilityValue = author
        }
        
        self.viewModel.outputs.blocksCountText
            .observe(on: UIScheduler())
            .observeValues { [weak self] count in
                self?.channelCountLabel.text = count
                self?.channelCountLabel.accessibilityValue = count
        }
        
    }

    public func configureWith(value: UserChannel) {
        self.viewModel.inputs.configureWith(value)
    }
    
}
