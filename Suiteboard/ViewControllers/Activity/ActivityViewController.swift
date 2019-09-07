//
//  ActivityViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import ArenaAPIModels
import Prelude
import ReactiveSwift
import UIKit

public final class ActivityViewController: UIViewController {
    
    fileprivate static let restorableActivityPathKey: String = "RestorableActivityPathKey"
    
    fileprivate let viewModel: ActivityViewModelType = ActivityViewModel()
    fileprivate let dataSource = ActivityDataSource()

    @IBOutlet fileprivate weak var activityCollectionView: UICollectionView!
 //   @IBOutlet fileprivate weak var nextButton: UIButton!
   // @IBOutlet fileprivate weak var prevButton: UIButton!
    
    fileprivate var emptyStatesController: EmptyStatesViewController?
    fileprivate var gradientBar: GradientLoadingBar!
    
    public static func instantiate() -> ActivityViewController {
        let vc = Storyboards.ActiveFeed.instantiate(ActivityViewController.self)
        vc.viewModel.inputs.configureWith(slug: "people-xue_qmbrt-c")
        return vc
    }
    
    public static func configureWith(slug: String) -> ActivityViewController {
        let vc = Storyboards.ActiveFeed.instantiate(ActivityViewController.self)
        vc.viewModel.inputs.configureWith(slug: slug)
        return vc
    }
    
    public static func configureWith(channel: UserChannel) -> ActivityViewController {
        let vc = Storyboards.ActiveFeed.instantiate(ActivityViewController.self)
        vc.viewModel.inputs.configureWith(channel: channel)
        return vc
    }
    
    public static func configureWith(channel: ListChannel) -> ActivityViewController {
        let vc = Storyboards.ActiveFeed.instantiate(ActivityViewController.self)
        vc.viewModel.inputs.configureWith(channel: channel)
        return vc
    }
    
    public static func configureWith(connection: Connection) -> ActivityViewController {
        let vc = Storyboards.ActiveFeed.instantiate(ActivityViewController.self)
        vc.viewModel.inputs.configureWith(connection: connection)
        return vc
    }
    
    /*
    public static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let path = coder.decodeObject(forKey: restorableActivityPathKey) as? ListChannel else {
            return nil
        }
        
        let activeVC = ActivityViewController.configureWith(channel: path)
        return activeVC
    }
    
    public override func encodeRestorableState(with coder: NSCoder) {
        self.viewModel.inputs.encodeRestorableState(coder: coder)
        super.encodeRestorableState(with: coder)
    }
    */
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        self.activitiesTableView.dataSource = dataSource
//        let layoutCollect = SuiteCollectionViewLayout()
//        layoutCollect.delegate = self
        
  //      self.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        self.activityCollectionView.register(nib: .BlockImageCollectionCell)
        
        self.activityCollectionView.dataSource = dataSource
        self.activityCollectionView.delegate = self
        
        self.activityCollectionView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        self.activityCollectionView.alwaysBounceVertical = true
        
        self.gradientBar = BottomGradientLoadingBar(height: 1.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.white], isRelativeToSafeArea: true, onView: self.navigationController?.navigationBar)
        
//        self.activityCollectionView.collectionViewLayout = layoutCollect
        
        self.navigationItem.title = "L00K"
        
        let emptyVC = EmptyStatesViewController.instantiate()
        self.emptyStatesController = emptyVC
        self.addChild(emptyVC)
        self.activityCollectionView.addSubview(emptyVC.view)
        NSLayoutConstraint.activate([
            emptyVC.view.topAnchor.constraint(equalTo: self.activityCollectionView.topAnchor),
            emptyVC.view.leadingAnchor.constraint(equalTo: self.activityCollectionView.leadingAnchor),
            emptyVC.view.bottomAnchor.constraint(equalTo: self.activityCollectionView.bottomAnchor),
            emptyVC.view.trailingAnchor.constraint(equalTo: self.activityCollectionView.trailingAnchor)
            ])
        emptyVC.didMove(toParent: self)
        
        // Do any additional setup after loading the view.
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.activityCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    public override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> baseControllerStyle()
        
//        _ = self.activitiesTableView
//            |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
//            |> UITableView.lens.separatorStyle .~ .none
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.titleChannelText
            .observe(on: UIScheduler())
            .observeValues { [weak self] text in
                self?.title = text
        }
        
        self.viewModel.outputs.blocks
            .observe(on: UIScheduler())
            .observeValues { [weak self] blocks in
                self?.dataSource.load(blocks: blocks)
                self?.activityCollectionView.reloadData()
        }
        
        self.viewModel.outputs.blocksIsEmpty
            .observe(on: UIScheduler())
            .observeValues { [weak self] isEmpty in
                if isTrue(isEmpty) {
                    self?.showEmptyStates()
                } else {
                    self?.emptyStatesController?.view.alpha = 0
                    self?.emptyStatesController?.view.isHidden = true
                }
        }
        
        self.viewModel.outputs.asyncReloadData
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                DispatchQueue.main.async {
                    self?.activityCollectionView.reloadData()
                }
        }
        
        self.viewModel.outputs.blocksAreLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                if isTrue($0) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.goToBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] block in
                self?.goToBlockDetail(block)
        }
    }
    
    fileprivate func goToBlockDetail(_ block: Block) {
        let vc = BlockDetailViewController.configureWith(block: block)
        vc.modalTransitionStyle = .partialCurl
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @objc fileprivate func prevButtonTapped() {
        
    }
    
    @objc fileprivate func nextButtonTapped() {
        self.activityCollectionView.reloadData()
        self.viewModel.inputs.nextButtonTapped()
    }
}

extension ActivityViewController: UIViewControllerRestoration {
    public static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        return ActivityViewController()
    }
    
}

extension ActivityViewController: UIDataSourceModelAssociation {
    public func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String? {
        if let item = self.dataSource.issueAtIndexPath(idx) {
            return String(item.id)
        }
        return nil
    }
    
    public func indexPathForElement(withModelIdentifier identifier: String, in view: UIView) -> IndexPath? {
        if let blockIndexPath = self.dataSource.indexPath(forCategoryId: identifier) {
            return blockIndexPath
        }
        return nil
    }
    
    
}

extension ActivityViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let block = self.dataSource.issueAtIndexPath(indexPath) {
            self.viewModel.inputs.didSelectedBlock(block)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath), outOf: self.dataSource.numberOfItems())
    }
}

extension ActivityViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let parentViewWidth = collectionView.frame.size.width
        
        return cellSizeForFrameWidth(parentViewWidth)
    }
}

@objc open class ActivityViewCollectionViewLayout: UICollectionViewFlowLayout {
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return shouldInvalidateForNewBounds(newBounds)
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = shouldInvalidateForNewBounds(newBounds)
        
        return context
    }
    
    fileprivate func shouldInvalidateForNewBounds(_ newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        
        return (newBounds.width != collectionView.bounds.width || newBounds.height != collectionView.bounds.height)
    }
}

