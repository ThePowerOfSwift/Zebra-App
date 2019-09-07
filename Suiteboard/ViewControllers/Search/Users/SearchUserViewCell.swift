//
//  SearchUserViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

public final class SearchUserViewCell: UICollectionViewCell, ValueCell {
    
    public typealias Value = ListUser
    
    fileprivate let viewModel: SearchUserCellViewModelType = SearchUserCellViewModel()
    
    @IBOutlet fileprivate weak var channelNameLabel: UILabel!
    @IBOutlet fileprivate weak var userLabelText: UILabel!
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    public override func bindStyles() {
        super.bindStyles()
        
        
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
//        self.userNameLabel.rac.text = self.viewModel.outputs.userNameText
        self.channelNameLabel.rac.text = self.viewModel.outputs.userNameText
        self.userLabelText.rac.text = self.viewModel.outputs.userChannelText
    }
    
    
    public func configureWith(value: ListUser) {
        self.viewModel.inputs.configure(user: value)
    }
}
