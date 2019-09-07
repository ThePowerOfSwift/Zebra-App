//
//  BlockTableViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import UIKit

public final class BlockTableViewCell: UITableViewCell, ValueCell {
    public typealias Value = Block
    
    @IBOutlet private weak var blockImageView: UIImageView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public override func bindStyles() {
        super.bindStyles()

    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureWith(value: Block) {
        self.blockImageView.ss_setImageWithURL(URL(string: (value.image?.large.url)!)!)
    }

}
