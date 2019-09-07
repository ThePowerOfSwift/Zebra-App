//
//  ChannelTableViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 08/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

public final class ChannelTableViewCell: UITableViewCell, ValueCell {

    public typealias Value = ListChannel
    
    fileprivate let viewModel: ChannelTableCellViewModelType = ChannelTableCellViewModel()
    
    @IBOutlet fileprivate weak var authorNameLabel: UILabel!
    @IBOutlet fileprivate weak var channelStackView: UIStackView!
    @IBOutlet fileprivate weak var channelNameLabel: UILabel!
    @IBOutlet fileprivate weak var channelSeparatorView: UIView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        _ = self
            |> UITableViewCell.lens.selectionStyle .~ .none
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.channelNameLabel.rac.text = self.viewModel.outputs.titleText
        self.authorNameLabel.rac.text = self.viewModel.outputs.userChannelText
    }
    
    public func configureWith(value: ListChannel) {
        self.viewModel.inputs.configure(connection: value)
    }
    
}
