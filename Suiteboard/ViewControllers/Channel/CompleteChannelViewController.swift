//
//  CompleteChannelViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 05/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class CompleteChannelViewController: UIViewController {
    
    fileprivate let viewModel: CompleteChannelViewModelType = CompleteChannelViewModel()
    fileprivate let dataSource = CompleteChannelDataSources()
    
    fileprivate var emptyStatesController: EmptyStatesViewController?
    
    @IBOutlet fileprivate weak var channelNavBar: UIView!
    @IBOutlet fileprivate weak var titleChannelLabel: UILabel!
    @IBOutlet fileprivate weak var backButton: UIButton!
    @IBOutlet fileprivate weak var blockCollectionView: UICollectionView!
    
    fileprivate let layoutCollect = SuiteCollectionViewLayout()
    
    fileprivate var gradientBar: GradientLoadingBar!
    
    public static func configureWith(connection: Connection) -> CompleteChannelViewController {
        let vc = Storyboards.CompleteChannel.instantiate(CompleteChannelViewController.self)
        vc.viewModel.inputs.configureWith(connection: connection)
        return vc
    }
    
    public static func configureWith(channel: ListChannel) -> CompleteChannelViewController {
        let vc = Storyboards.CompleteChannel.instantiate(CompleteChannelViewController.self)
        vc.viewModel.inputs.configureWith(channel: channel)
        return vc
    }
    
    public static func configureWith(listChannel: ChannelUser) -> CompleteChannelViewController {
        let vc = Storyboards.CompleteChannel.instantiate(CompleteChannelViewController.self)
        // VC View Model Inputs
        vc.viewModel.inputs.configureWith(userChannel: listChannel)
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        self.gradientBar = GradientLoadingBar(height: 1.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.white], isRelativeToSafeArea: true, onView: self.channelNavBar)
        
//        layoutCollect.minimumColumnSpacing = 1.0
//        layoutCollect.minimumInteritemSpacing = 1.0
        
        // Do any additional setup after loading the view.
//        self.blockCollectionView.collectionViewLayout = layoutCollect
        self.blockCollectionView.register(nib: .BlockImageCollectionCell)
        self.blockCollectionView.dataSource = dataSource
        self.blockCollectionView.delegate = self
        
        self.blockCollectionView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        self.blockCollectionView.alwaysBounceVertical = true
        
        let emptyVC = EmptyStatesViewController.instantiate()
        self.emptyStatesController = emptyVC
        self.addChild(emptyVC)
        self.blockCollectionView.addSubview(emptyVC.view)
        emptyVC.didMove(toParent: self)
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.blockCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
    }

    public override func bindViewModel() {
        super.bindViewModel()
        
        self.titleChannelLabel.rac.text = self.viewModel.outputs.titleChannelText
        
        self.viewModel.outputs.blocksAreLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] loading in
                if isTrue(loading) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.blocks
            .observe(on: UIScheduler())
            .observeValues { [weak self] blocks in
                self?.dataSource.load(blocks: blocks)
                self?.blockCollectionView.reloadData()
        }
        
        self.viewModel.outputs.showEmptyState
            .observe(on: UIScheduler())
            .observeValues { [weak self] isEmpty in
                self?.showEmptyState()
        }
        
        self.viewModel.outputs.hideEmptyState
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.emptyStatesController?.view.alpha = 0
                self?.emptyStatesController?.view.isHidden = true
        }
        
        self.viewModel.outputs.dismissChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                self?.navigationController?.popViewController(animated: true)
        }
        
        self.viewModel.outputs.goToBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
              self?.goToBlockDetail($0)
        }
    }
    
    fileprivate func goToBlockDetail(_ block: Block) {
        let blockDetailVC = BlockDetailViewController.configureWith(block: block)
        self.navigationController?.pushViewController(blockDetailVC, animated: true)
    }
    
    fileprivate func showEmptyState() {
        guard let emptyVC = self.emptyStatesController else { return }
        emptyVC.view.isHidden = false
        self.blockCollectionView.bringSubviewToFront(emptyVC.view)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.emptyStatesController?.view.alpha = 1.0
        }, completion: nil)
    }
    
    @objc fileprivate func backButtonTapped() {
        self.viewModel.inputs.backButtonTapped()
    }
}

extension CompleteChannelViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let block = self.dataSource.blockAtIndexPath(indexPath) {
            self.viewModel.inputs.didSelectedBlock(block: block)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath), outOf: self.dataSource.numberOfItems())
    }
}


extension CompleteChannelViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        
        return cellSizeForFrameWidth(parentViewWidth)
    }
}
