//
//  FavoritesViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 06/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude
import RealmSwift
import ReactiveSwift
import UIKit

internal final class FavoritesViewController: UIViewController {
    
    fileprivate let viewModel: FavoritesViewModelType = FavoritesViewModel()
    
    @IBOutlet fileprivate weak var favoritesNavBarView: UIView!
    @IBOutlet fileprivate weak var favoritesLabel: UILabel!
    @IBOutlet fileprivate weak var favoritesCollectionView: UICollectionView!
    
    @IBOutlet fileprivate weak var settingsButton: UIButton!
    
    fileprivate var emptyStatesController: EmptyStatesViewController?
    
  //  fileprivate var blocksResult = List<BlockLocal>()
//    fileprivate let blocksGroup = Realm.current?.objects(IndividualFavorite.self).first!
    fileprivate var notificationToken: NotificationToken? = nil
    fileprivate var selectedFavorites = List<BlockLocal>()
    
    static func instantiate() -> FavoritesViewController {
        let favoriteVC = Storyboards.Favorites.instantiate(FavoritesViewController.self)
        return favoriteVC
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        self.favoritesCollectionView.dataSource = self
        self.favoritesCollectionView.delegate = self
        
        self.favoritesCollectionView.register(nib: .BlockImageCollectionCell)
        
        
        let emptyVC = EmptyStatesViewController.instantiate()
        self.emptyStatesController = emptyVC
        self.addChild(emptyVC)
        self.favoritesCollectionView.addSubview(emptyVC.view)
        emptyVC.didMove(toParent: self)
 
 
        self.viewModel.inputs.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.inputs.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.emptyStatesController?.view.frame = self.favoritesCollectionView.frame
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.favoritesCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.issuedList
            .observe(on: UIScheduler())
            .observeValues { [weak self] issues in
                guard let _self = self else { return }
                _self.selectedFavorites = issues
                _self.notificationToken = self?.setupNotifications(_self.selectedFavorites)
        }
        
        
        self.viewModel.outputs.showEmptyState
            .observe(on: UIScheduler())
            .observeValues { [weak self] show in
                if isTrue(show) {
                    self?.favoritesCollectionView.bounces = false
                    self?.showEmptyStates()
                } else {
                    self?.favoritesCollectionView.bounces = true
                    self?.emptyStatesController?.view.alpha = 0
                    self?.emptyStatesController?.view.isHidden = true
                }
                
        }
        
        
        self.viewModel.outputs.goToBlockDetail
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] goToDetail in
                self?.goToBlockDetailController(goToDetail)
        }
        
        self.viewModel.outputs.goToSettings
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                self?.goToSettings()
        }
    }
    
    private func favoriteResultAtIndexPath(_ indexPath: IndexPath) -> BlockLocal? {
        return self.selectedFavorites[indexPath.row]
    }
    
    private func setupNotifications(_ list: List<BlockLocal>) -> NotificationToken {
        return list.observe { [weak self] changes in
            switch changes {
            case .initial:
                print("Setup Notifications..")
                self?.favoritesCollectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                print("Whats here of deletions: \(deletions)")
                self?.favoritesCollectionView.performBatchUpdates({
                    self?.favoritesCollectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    self?.favoritesCollectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    self?.favoritesCollectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                }, completion: nil)
                break
            case .error(let error):
                fatalError(String(describing: "Why Something Occured on Error: \(error)"))
                break
            }
        }
    }
    
    private func showEmptyStates() {
        guard let emptyVC = self.emptyStatesController else { return }
        print("Empty View Controller is Showed")
        emptyVC.view.isHidden = false
        self.view.bringSubviewToFront(emptyVC.view)
        UIView.animate(withDuration: 0.3, animations: {
            self.emptyStatesController?.view.alpha = 1.0
        })
    }
    
    private func goToBlockDetailController(_ local: BlockLocal) {
        let detailVC = BlockDetailViewController.configureWith(localBlock: local)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func goToSettings() {
        let settingsVC = SettingsViewController.instantiate()
        let navVC = UINavigationController(rootViewController: settingsVC)
        navVC.modalPresentationStyle = .formSheet
        self.present(navVC, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        self.viewModel.inputs.settingsButtonTapped()
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        
        return cellSizeForFrameWidth(parentViewWidth)
    }
}


extension FavoritesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Favorite Counts: \(self.selectedFavorites.count)")
        return self.selectedFavorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let favoriteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockImageCollectionCell", for: indexPath) as! BlockImageCollectionCell
            let localBlock = self.selectedFavorites[indexPath.row]
            favoriteCell.configureLocalWith(value: localBlock)
            return favoriteCell
        
        
    }
}


extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedBlock = self.favoriteResultAtIndexPath(indexPath) {
            self.viewModel.inputs.tappedLocal(selectedBlock)
        }
    }
    
    
}

