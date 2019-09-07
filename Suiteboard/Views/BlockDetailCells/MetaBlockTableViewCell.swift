//
//  MetaBlockTableViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public protocol MetaBlockCellDelegate: class {
    func sourceMetaButtonTapped()
    func favoriteButtonTapped()
}

public final class MetaBlockTableViewCell: UITableViewCell, ValueCell {
    
    public typealias Value = BlockEnvelope
    
    fileprivate let viewModel: MetaBlockCellViewModelType = MetaBlockCellViewModel()
    
//    @IBOutlet fileprivate weak var titleBlock: UILabel!
    @IBOutlet fileprivate weak var sourceButton: UIButton!
    @IBOutlet fileprivate weak var favouriteButton: UIButton!
    
//    @IBOutlet fileprivate weak var infoBlock: UILabel!
    
    weak var delegate: MetaBlockCellDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sourceButton.addTarget(self, action: #selector(sourceButtonTapped), for: .touchUpInside)
        self.favouriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> UITableViewCell.lens.selectionStyle .~ .none
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
//        self.titleBlock.rac.text = self.viewModel.outputs.titleText
        
//        self.infoBlock.rac.text = self.viewModel.outputs.infoText
        
        
        self.viewModel.outputs.sourceTapped
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                guard let _self = self else { return }
                _self.delegate?.sourceMetaButtonTapped()
        }
        
        self.viewModel.outputs.favoriteTapped
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                guard let _self = self else { return }
                _self.delegate?.favoriteButtonTapped()
        }
        
        /*
        self.viewModel.outputs.sourceUrl
            .observe(on: QueueScheduler.main)
            .on(event: { [weak self] _ in
                
            }).skipNil()
            .observeValues { [weak self] sourceUrl in
                print
        }
        */
    }
    
    public func configureWith(value: BlockEnvelope) {
        self.viewModel.inputs.configure(block: value)
    }
    
    @objc fileprivate func sourceButtonTapped() {
        self.viewModel.inputs.sourceButtonTapped()
    }
    
    @objc fileprivate func favoriteButtonTapped() {
        self.viewModel.inputs.favoriteButtonTapped()
    }
}
