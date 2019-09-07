//
//  BlockDetailViewController.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import Prelude
import RealmSwift
import ReactiveSwift
import UIKit

public final class BlockDetailViewController: UIViewController {
    
    @IBOutlet fileprivate weak var detailNavBarView: UIView!
    @IBOutlet fileprivate weak var backButton: UIButton!
    @IBOutlet fileprivate weak var detailTableView: UITableView!
    
    fileprivate var gradientBar: GradientLoadingBar!
    
    fileprivate let viewModel: BlockDetailViewModelType = BlockDetailViewModel()
    fileprivate let dataSource = BlockDetailDataSources()
    
    public static func configureWith(block: Block) -> BlockDetailViewController {
        let vc = Storyboards.BlockDetail.instantiate(BlockDetailViewController.self)
        vc.viewModel.inputs.configureWith(block: block)
        return vc
    }
    
    public static func configureWith(listBlock: ListBlock) -> BlockDetailViewController {
        let vc = Storyboards.BlockDetail.instantiate(BlockDetailViewController.self)
        vc.viewModel.inputs.configureWith(listBlock: listBlock)
        return vc
    }
    
    public static func configureWith(localBlock: BlockLocal) -> BlockDetailViewController {
        let vc = Storyboards.BlockDetail.instantiate(BlockDetailViewController.self)
        vc.viewModel.inputs.configureWith(local: localBlock)
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.isNavigationBarHidden = true

        
        self.backButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        self.detailTableView.register(nib: .ConnectedBlockTableViewCell)
        
        self.gradientBar = GradientLoadingBar(height: 1.0, durations: Durations(fadeIn: 0.5, fadeOut: 0.5, progress: 0.5), gradientColorList: [UIColor.red, UIColor.white], isRelativeToSafeArea: true, onView: self.detailNavBarView)
        
        // Do any additional setup after loading the view.
        self.detailTableView.dataSource = dataSource
        self.detailTableView.delegate = self
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
 
    public override func bindStyles() {
        super.bindStyles()
        _ = self
            |> baseControllerStyle()
        
        _ = self.backButton
            |> UIButton.lens.accessibilityTraits .~ .button
            |> UIButton.lens.accessibilityLabel .~ "Back"
        
        _ = self.detailTableView
                |> UITableView.lens.rowHeight .~ UITableView.automaticDimension
                |> UITableView.lens.separatorStyle .~ .none
    }
    
    public override func bindViewModel() {
        super.bindViewModel()
        
        
        self.viewModel.outputs.getBlock
            .observe(on: UIScheduler())
            .observeValues { [weak self] envelope in
                self?.dataSource.load(block: envelope)
                self?.detailTableView.reloadData()
        }
        
        self.viewModel.outputs.blockIsLoading
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                if isTrue($0) {
                    self?.gradientBar.show()
                } else {
                    self?.gradientBar.hide()
                }
        }
        
        self.viewModel.outputs.backToChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                self?.navigationController?.popViewController(animated: true)
        }
        
        self.viewModel.outputs.goToChannel
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] connection in
                self?.goToActivities(connection: connection)
        }
        
        self.viewModel.outputs.goToSource
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] in
                let urlRequest = URLRequest(url: $0)
                self?.goToSourceBrowser(requestSource: urlRequest)
        }
        
        /*
        self.viewModel.outputs.gotShareImage
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] dataImage in
                print("Got Share Images")
                self?.shareContents(dataImage)
        }
 
        
        self.viewModel.outputs.gotShareText
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] dataText in
                self?.shareTextContents(dataText)
        }
        
        
        self.viewModel.outputs.gotShareLink
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] linkText in
                self?.shareLinkContents(linkText)
        }
        */
        
        self.viewModel.outputs.gotFavorite
            .observe(on: UIScheduler())
            .observeValues {
                print("Saved Realm Favorite")
        }
    }
    
    fileprivate func goToActivities(connection: Connection) {
        let activityVC = ActivityViewController.configureWith(connection: connection)
        self.navigationController?.pushViewController(activityVC, animated: true)
    }
    
    fileprivate func goToSourceBrowser(requestSource: URLRequest) {
        let sourceVC = SourceWebViewController.configureWith(initialRequest: requestSource)
        self.navigationController?.pushViewController(sourceVC, animated: true)
    }
    
    @objc fileprivate func cancelButtonTapped() {
        self.viewModel.inputs.cancelButtonTapped()
    }
    
    @objc public func sourceButtonTapped() {
        self.viewModel.inputs.sourceButtonTapped()
    }
    
    fileprivate func saveIssuedOrder(previousBlock: Block, imageData: Data, source: String) {
        let realm = try! Realm()
        try! realm.write {
            let block = BlockLocal()
          //  block.id = previousBlock.id
            block.imageData = imageData
            block.source = source
            let favoriteList = realm.objects(IndividualFavorite.self).first!
            favoriteList.items.append(block)
            realm.add(favoriteList)
        }
    }

}

extension BlockDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DID SELECT ROW AT INDEXPATH")
        if let connection = self.dataSource.connectionAtIndexPath(indexPath) {
            print("CONNECTION DID SELECTED")
            self.viewModel.inputs.didSelect(connection: connection)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         if let contentCell = cell as? ContentBlockTableViewCell {
            contentCell.delegate = self
        }
    }
}

extension BlockDetailViewController: ContentBlockCellDetailDelegate {
    func shareViewControllerPresented(_ cell: ContentBlockTableViewCell, controller: UIActivityViewController) {
        self.present(controller, animated: true, completion: nil)
    }
    
    func sampleThinksProtocol(_ cell: ContentBlockTableViewCell, text: String) {
        print(text)
    }
    
    func getImageDataContent(_ cell: ContentBlockTableViewCell, data: Data) {
        self.viewModel.inputs.getBlockImageData(image: data)
    }
    
    func sourceMetaButtonTapped(_ cell: ContentBlockTableViewCell) {
        self.viewModel.inputs.sourceButtonTapped()
    }
    
    func shareMetaButtonTapped(_ cell: ContentBlockTableViewCell) {
        self.viewModel.inputs.shareButtonTapped()
    }
}


