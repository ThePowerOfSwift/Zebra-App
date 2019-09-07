//
//  SearchChannelsViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 29/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import ReactiveSwift
import UIKit

public protocol SearchChannelsControllerDelegate: class {
    func searchChannelsDelegate(_ text: String)
}

public final class SearchChannelsViewController: UITableViewController {
    
    fileprivate let viewModel: SearchChannelsViewModelType = SearchChannelsViewModel()
    fileprivate let dataSource = SearchChannelsDataSource()
    
    public weak var delegate: SearchChannelsControllerDelegate?
    
    public static func instantiate() -> SearchChannelsViewController {
        let vc = Storyboards.Search.instantiate(SearchChannelsViewController.self)
        return vc
    }
    
    public func searchTextChanged(_ text: String) {
        self.viewModel.inputs.searchTextChanged(text)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(nib: .ChannelTableViewCell)
        
        self.tableView.dataSource = dataSource
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
        
        _ = self.tableView
            |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
            |> UITableView.lens.separatorStyle .~ .none
    }

    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.channels
            .observe(on: UIScheduler())
            .observeValues { [weak self] listChannels in
                self?.dataSource.configureChannels(listChannels)
                self?.tableView.reloadData()
        }
        
    }
}
