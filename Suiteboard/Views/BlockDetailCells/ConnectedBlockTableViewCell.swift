//
//  ConnectedBlockTableViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

class ConnectedBlockTableViewCell: UITableViewCell, ValueCell {
    
    typealias Value = Connection
    
    @IBOutlet fileprivate weak var connectedStackView: UIStackView!
    @IBOutlet fileprivate weak var connectionNameLabel: UILabel!
    @IBOutlet fileprivate weak var authorNameLabel: UILabel!
    
    @IBOutlet fileprivate weak var connectionSeparatorView: UIView!
    
    fileprivate let viewModel: ConnectedBlockCellViewModelType = ConnectedBlockCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> UITableViewCell.lens.selectionStyle .~ .none
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.connectionNameLabel.rac.text = self.viewModel.outputs.titleText
        self.authorNameLabel.rac.text = self.viewModel.outputs.userChannelText
    }
    
    func configureWith(value: Connection) {
        self.viewModel.inputs.configure(connection: value)
    }
    
}
