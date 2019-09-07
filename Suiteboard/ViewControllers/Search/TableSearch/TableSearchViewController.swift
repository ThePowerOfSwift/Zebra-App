//
//  TableSearchViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 23/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class TableSearchViewController: UIViewController {
    
    fileprivate let viewModel: TableSearchViewModelType = TableSearchViewModel()
    fileprivate let dataSource = TableSearchDataSources()
    
    @IBOutlet fileprivate weak var searchInputLabel: UILabel!
    @IBOutlet fileprivate weak var searchBarView: UIView!
    @IBOutlet fileprivate weak var tableSearchBar: UISearchBar!
    @IBOutlet fileprivate weak var searchTableView: UITableView!
    
    fileprivate var gradientBar: BottomGradientLoadingBar!
    
    public static func instantiate() -> TableSearchViewController {
        let vc = Storyboards.Search.instantiate(TableSearchViewController.self)
        return vc
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchTableView.dataSource = dataSource
        self.searchTableView.delegate = self
        
        self.tableSearchBar.delegate = self
        
        self.gradientBar = BottomGradientLoadingBar(height: 1.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.white], isRelativeToSafeArea: true, onView: self.searchBarView)

        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        startListeningToNotifications()
        self.viewModel.inputs.viewWillAppear(animated: animated)
    }
    
    
    public override func bindStyles() {
        super.bindStyles()
        _ = self
            |> baseControllerStyle()
        
        _ = self.searchTableView
            |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
            |> UITableView.lens.separatorStyle .~ .none
        
        _ = self.tableSearchBar
            |> UISearchBar.lens.accessibilityTraits .~ .searchField
            |> UISearchBar.lens.accessibilityHint .~ "Write and search the channels of content here"
    
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.channels
            .observe(on: UIScheduler())
            .observeValues { [weak self] listChannel in
                self?.dataSource.fetchSearch(channels: listChannel)
                self?.searchTableView.reloadData()
        }
        
        self.viewModel.outputs.searchIsLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] isLoading in
                if isTrue(isLoading) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.channelsIsEmpty
            .observe(on: UIScheduler())
            .observeValues { [weak self] isEmpty in
                if isTrue(isEmpty) {
                    self?.dataSource.showEmptyStates()
                    self?.searchTableView.reloadData()
                }
        }
        
        self.viewModel.outputs.goToChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] channel in
                self?.view.endEditing(true)
                self?.goToActivityChannel(channel)
        }
    }
    

    fileprivate func goToActivityChannel(_ channel: ListChannel) {
        let activityVC = ActivityViewController.configureWith(channel: channel)
        self.navigationController?.pushViewController(activityVC, animated: true)
    }
    
    fileprivate func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func refreshInsets(forKeyboardFrame keyboardFrame: CGRect) {
        let referenceView: UIScrollView = self.searchTableView
        
        let scrollInsets = UIEdgeInsets(top: referenceView.scrollIndicatorInsets.top, left: 0, bottom: view.frame.maxY - keyboardFrame.minY, right: 0)
        let contentInsets = UIEdgeInsets(top: referenceView.contentInset.top, left: 0, bottom: view.frame.maxY - keyboardFrame.minY, right: 0)
        
        self.searchTableView.scrollIndicatorInsets = scrollInsets
        self.searchTableView.contentInset = contentInsets
    }
    
    
    @objc fileprivate func keyboardWillShow(_ notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject], let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        refreshInsets(forKeyboardFrame: keyboardFrame)
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Foundation.Notification) {
        guard
            let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        refreshInsets(forKeyboardFrame: keyboardFrame)
        //        dismissOptionsViewControllerIfNecessary()
    }
    
    @objc fileprivate func cancelButtonPressed() {
        self.viewModel.inputs.cancelButtonPressed()
    }
    
}

extension TableSearchViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.viewModel.inputs.searchFieldDidBeginEditing()
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.viewModel.inputs.searchTextEditingDidEnd()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.inputs.searchTextChanged(searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}


extension TableSearchViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath), outOf: self.dataSource.numberOfItems())
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let curated = self.dataSource[indexPath] as? ListChannel else { return }
        self.viewModel.inputs.tapped(channel: curated)
        //        tableView.deselectRow(at: indexPath, animated: true)
    }
}
