//
//  SortUserViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class SortUserViewController: UIViewController {
    
    fileprivate let viewModel: SortUserViewModelType = SortUserViewModel()
    
    @IBOutlet fileprivate weak var titleUserLabel: UILabel!
    @IBOutlet fileprivate weak var sortsStackView: UIStackView!
    
    @IBOutlet fileprivate weak var channelsButton: UIButton!
    @IBOutlet fileprivate weak var followingButton: UIButton!
    @IBOutlet fileprivate weak var followersButton: UIButton!
    
    public func configureWith(_ user: User) {
        self.viewModel.inputs.configureWith(user)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
