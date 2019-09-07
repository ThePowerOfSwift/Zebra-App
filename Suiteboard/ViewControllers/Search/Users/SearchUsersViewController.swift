//
//  SearchUsersViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 21/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class SearchUsersViewController: UITableViewController {
    
    fileprivate let viewModel: SearchUsersViewModelType = SearchUsersViewModel()
    fileprivate let dataSource = SearchUsersDataSource()
    
    public static func instantiate() -> SearchUsersViewController {
        let searchVC = Storyboards.Search.instantiate(SearchUsersViewController.self)
        return searchVC
    }
    
    public func searchTextChanged(_ text: String) {
        self.viewModel.inputs.searchTextChanged(text)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
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
        
        self.viewModel.outputs.users
            .observe(on: UIScheduler())
            .observeValues { [weak self] userLists in
                
                self?.dataSource.load(users: userLists)
                self?.tableView.reloadData()
        }
        
        self.viewModel.outputs.goToUser
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] user in
                self?.goToUserViewController(user)
        }
    }
    
    fileprivate func goToUserViewController(_ user: ListUser) {
        let userVC = UserViewController.configureWith(user)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath), outOf: self.dataSource.numberOfItems())
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("DID SELECT ROW AT INDEXPATH")
        if let user = self.dataSource.listUserAtIndexPath(indexPath) {
//            print("CONNECTION DID SELECTED")
            self.viewModel.inputs.tapped(user: user)
        }
    }
}

