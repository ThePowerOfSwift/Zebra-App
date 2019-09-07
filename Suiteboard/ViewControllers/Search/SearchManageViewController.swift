//
//  SearchManageViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 21/05/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import ReactiveSwift
import UIKit

internal protocol SearchManageViewControllerDelegate: class {
    func sortTab(_ viewController: UIViewController, selectedTab tab: ManagedSearchTab)
}

internal final class SearchManageViewController: UIViewController {
    
    @IBOutlet fileprivate weak var channelsButton: UIButton!
    @IBOutlet fileprivate weak var blocksButton: UIButton!
    @IBOutlet fileprivate weak var usersButton: UIButton!
    @IBOutlet fileprivate weak var searchButtonsStackView: UIStackView!
    
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    
    fileprivate weak var pageViewController: UICollectionViewController!
    
    fileprivate let viewModel: ManagedSearchViewModelType = ManagedSearchViewModel()
    fileprivate var pagesDataSource: SearchPagesDataSource!
    fileprivate let collectionDataSource = SearchBlocksDataSource()
    
    static func instantiate() -> SearchManageViewController {
        let vc = Storyboards.Search.instantiate(SearchManageViewController.self)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pageViewController = self.children.compactMap { $0 as? UICollectionViewController }.first
//        self.pageViewController.collectionView.register(nib: .SearchB)
        self.pageViewController.collectionView.dataSource = collectionDataSource
        self.pageViewController.collectionView.delegate = self
        
        self.channelsButton.addTarget(self, action: #selector(channelsButtonTapped), for: .touchUpInside)
        self.blocksButton.addTarget(self, action: #selector(blocksButtonTapped), for: .touchUpInside)
        self.usersButton.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchBar.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    
    override func bindStyles() {
        super.bindStyles()
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.navigateToTab
            .observe(on: UIScheduler())
            .observeValues { [weak self] navigate in
                print("What Collection Tab: \(navigate)")
                self?.viewModel.inputs.navigateToCollections(navigate)
        }
        
        self.viewModel.outputs.blocks
            .observe(on: UIScheduler())
            .observeValues { [weak self] blocks in
                self?.collectionDataSource.load(blocks: blocks)
                self?.pageViewController.collectionView.reloadData()
        }
        
        self.viewModel.outputs.users
            .observe(on: UIScheduler())
            .observeValues { [weak self] users in
                print("What User List: \(users)")
                self?.collectionDataSource.load(users: users)
                self?.pageViewController.collectionView.reloadData()
        }
        
        self.viewModel.outputs.channels
            .observe(on: UIScheduler())
            .observeValues { [weak self] channels in
                self?.collectionDataSource.load(channels: channels)
                self?.pageViewController.collectionView.reloadData()
        }
    }
    
    @objc fileprivate func searchTextChanged(_ textField: UITextField) {
        self.viewModel.inputs.searchTextChanged(textField.text ?? "")
    }
    
    @objc fileprivate func searchTextEditingDidEnd() {
        self.viewModel.inputs.searchTextEditingDidEnd()
    }
    
    @objc fileprivate func channelsButtonTapped() {
        self.viewModel.inputs.channelsButtonTapped()
    }
    
    @objc fileprivate func blocksButtonTapped() {
        self.viewModel.inputs.blocksButtonTapped()
    }
    
    @objc fileprivate func usersButtonTapped() {
        self.viewModel.inputs.usersButtonTapped()
    }
}

extension SearchManageViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        return cellSizeForFrameWidth(parentViewWidth)
    }
}

extension SearchManageViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.inputs.searchFieldDidBeginEditing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.inputs.searchTextChanged(searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.viewModel.inputs.searchTextEditingDidEnd()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.viewModel.inputs.searchFieldDidBeginEditing()
    }
}

extension SearchManageViewController: UICollectionViewDelegate {
     
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.collectionDataSource.itemIndexAt(indexPath), outOf: self.collectionDataSource.numberOfItems())
    }
}


/*
extension SearchManageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.viewModel.inputs.pageTransition(completed: completed)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let idx = pendingViewControllers.first.flatMap(self.pagesDataSource.indexFor(controller:)) else { return }
        
        self.viewModel.inputs.willTransition(toPage: idx)
    }
}
*/
