//
//  TableContentsViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 30/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class TableContentsViewController: UIViewController {
    
    fileprivate let viewModel: TableContentsViewModelType = TableContentsViewModel()
    fileprivate let dataSource = TableContentsDataSource()
    
    @IBOutlet fileprivate weak var contentsTableView: UITableView!
    @IBOutlet fileprivate weak var contentsInputLabel: UILabel!
    @IBOutlet fileprivate weak var contentsNavView: UIView!
    
    fileprivate var gradientBar: GradientLoadingBar!
    
    fileprivate var selectedChannel: ListChannel? = nil
    
    fileprivate var defaultSelectedChannel: IndexPath {
        return IndexPath(row: 0, section: 0)
    }
    
    public static func instantiate() -> TableContentsViewController {
        let tableContentVC = Storyboards.TableContents.instantiate(TableContentsViewController.self)
        return tableContentVC
    }
    
    public static func instantiateSplit() -> SuiteSpliteViewController {
        let splitVC = SuiteSpliteViewController()
        splitVC.restorationIdentifier = "SuiteTableContentsRestorationID"
        splitVC.presentsWithGesture = false
        splitVC.suitePrimaryColumnWidth = .narrow
        let tableContentVC = Storyboards.TableContents.instantiate(TableContentsViewController.self)
        let manyNavigationContents = ManyDelegateNavigationController(rootViewController: tableContentVC)
        
        splitVC.setInitialPrimaryViewController(manyNavigationContents)
        
        splitVC.dimsDetailViewControllerAutomatically = true
        
        splitVC.tabBarItem = tableContentVC.tabBarItem
        
        return splitVC
    }
    
   public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contentsTableView.dataSource = dataSource
        self.contentsTableView.delegate = self
    
        self.gradientBar = BottomGradientLoadingBar(height: 1.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.white], isRelativeToSafeArea: true, onView: self.contentsNavView)
    
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.inputs.viewDidAppear(animated)
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
        
        _ = self.contentsTableView
            |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
            |> UITableView.lens.separatorStyle .~ .none
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.channels
            .observe(on: UIScheduler())
            .observeValues { [weak self] lists in
                self?.dataSource.fetchSource(lists: lists)
                self?.contentsTableView.reloadData()
        }
        
        self.viewModel.outputs.contentsAreLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                if isTrue($0) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.goToChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] channel in
                print("Go To Channel")
                self?.goToActivityChannel(channel)
        }
    }

    fileprivate func goToActivityChannel(_ list: UserChannel) {
        let activityVC = ActivityViewController.configureWith(channel: list)
        self.navigationController?.pushViewController(activityVC, animated: true)
    }
}

/*
extension TableContentsViewController: SuiteSplitViewControllerDetailProvider {
    public func initialDetailViewControllerForSplitView(_ splitView: SuiteSpliteViewController) -> UIViewController? {
        
       if let channel = self.selectedChannel {
            return ActivityViewController.configureWith(channel: channel)
       } else {
            return ActivityViewController.instantiate()
        }
        
//        return nil
    }
}
*/

extension TableContentsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let curated = self.dataSource[indexPath] as? UserChannel else { return }
        self.viewModel.inputs.tappedCurated(curated)
//        tableView.deselectRow(at: indexPath, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
