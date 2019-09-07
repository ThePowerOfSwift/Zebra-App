//
//  UserViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class UserViewController: UIViewController {
    
    public var viewModel: UserViewModelType = UserViewModel()
    
    private weak var channelsUserViewController: ChannelsUserViewController!
    private weak var sortUserViewController: SortUserViewController!
    
    public static func configureWith(_ user: ListUser) -> UserViewController {
        let userVC = Storyboards.User.instantiate(UserViewController.self)
        userVC.viewModel.inputs.configureWith(user)
        return userVC
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.channelsUserViewController = self.children.compactMap { $0 as? ChannelsUserViewController }.first
        self.sortUserViewController = self.children.compactMap { $0 as? SortUserViewController }.first
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.subInitUser
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] user in
//                self?.sortUserViewController.configureWith(user)
                self?.channelsUserViewController.configureWith(user)
        }
    }
}


public final class UserChannelsViewController: UICollectionViewController {
    
    
    public override func viewDidLoad() {
        
        self.collectionView.delegate = self
    }
    
    
    
}
