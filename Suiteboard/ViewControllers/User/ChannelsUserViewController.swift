//
//  ChannelsUserViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class ChannelsUserViewController: UITableViewController {
    
    fileprivate let viewModel: ChannelsUserViewModelType = ChannelsUserViewModel()
    fileprivate let dataSource = ChannelsUserDataSource()
    
    public func configureWith(_ user: ListUser) {
        self.viewModel.inputs.configureWith(user: user)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.tableView.dataSource = dataSource

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
            |> UITableView.lens.rowHeight .~ 300.0
            |> UITableView.lens.separatorStyle .~ .none
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.channels
            .observe(on: UIScheduler())
            .observeValues { [weak self] channels in
                self?.dataSource.load(channels: channels)
                self?.tableView.reloadData()
        }
        
        self.viewModel.outputs.goToChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] selected in
                self?.goToActivityChannel(selected.channelStatus.slug)
        }
    }
    
    fileprivate func goToCompleteChannel(_ channel: ChannelUser) {
        let channelVC = CompleteChannelViewController.configureWith(listChannel: channel)
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    fileprivate func goToActivityChannel(_ slug: String) {
        let activityVC = ActivityViewController.configureWith(slug: slug)
        self.navigationController?.pushViewController(activityVC, animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let channelCell = cell as? UserChannelViewCell {
            channelCell.delegate = self
        }
    }

}

extension ChannelsUserViewController: UserChannelCellDelegate {
    public func selectedChannel(cell: UserChannelViewCell, channel: ChannelUser) {
        self.viewModel.inputs.tapped(channel)
    }
    
}
