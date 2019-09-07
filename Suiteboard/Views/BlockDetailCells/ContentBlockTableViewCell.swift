//
//  ContentBlockTableViewCell.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 04/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import ArenaAPIModels
import PINRemoteImage
import Prelude
import RealmSwift
import ReactiveSwift
import UIKit

typealias OnHeightMismatch = (CGFloat) -> Void

internal protocol ContentBlockCellDetailDelegate: class {
    func sampleThinksProtocol(_ cell: ContentBlockTableViewCell, text: String)
    func getImageDataContent(_ cell: ContentBlockTableViewCell, data: Data)
    func sourceMetaButtonTapped(_ cell: ContentBlockTableViewCell)
    func shareMetaButtonTapped(_ cell: ContentBlockTableViewCell)
    func shareViewControllerPresented(_ cell: ContentBlockTableViewCell, controller: UIActivityViewController)
}

internal final class ContentBlockTableViewCell: UITableViewCell, ValueCell {
    
    public typealias Value = BlockEnvelope
    
    fileprivate let viewModel: ContentBlockCellViewModelType = ContentBlockCellViewModel()
    
    @IBOutlet fileprivate weak var blockImageView: FLAnimatedImageView!
    @IBOutlet fileprivate weak var blockTextView: UITextView!
    @IBOutlet fileprivate weak var favoriteButton: UIButton!
    @IBOutlet fileprivate weak var shareButton: UIButton!
    @IBOutlet fileprivate weak var sourceButton: UIButton!
    
    internal weak var delegate: ContentBlockCellDetailDelegate?
    
    private enum Delta: Int {
        case prev = -1
        case next = 1
    }
    
//    fileprivate var imagePanGesture: UIPanGestureRecognizer!
    fileprivate var imagePanGesture: UIPanGestureRecognizer!
    fileprivate var imageScaleGesture: UIPinchGestureRecognizer!
//    fileprivate var zoomOutGesture: UITapGestureRecognizer!
    
    private var onHeightMismatch: OnHeightMismatch?
    private var imageSize: CGSize?
    private var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }
    private var currentImageFrame: CGRect = .zero
    private var imageScale: CGFloat = 1
    private var imageOffset: CGPoint = .zero
    private var tempOffset: CGPoint?
    private var isZooming = false
    
    private var aspectRatioConstraint: NSLayoutConstraint? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.clipsToBounds = false
        self.selectionStyle = .none
        
        self.sourceButton.addTarget(self, action: #selector(sourceButtonTapped), for: .touchUpInside)
        self.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        self.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
//       self.imagePanGesture =
//        self.blockImageView.addGestureRecognizer(self.imagePanGesture)
        
        self.imagePanGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanGestureMovement(gesture:)))
        self.imagePanGesture.delegate = self
        self.blockImageView.addGestureRecognizer(self.imagePanGesture)
        
        self.imageScaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureMovement(gesture:)))
        self.imageScaleGesture.delegate = self
        self.blockImageView.addGestureRecognizer(self.imageScaleGesture)

        self.blockImageView.addInteraction(UIDragInteraction(delegate: self))
        self.blockTextView.textDragDelegate = self
        self.blockTextView.textDragOptions = .stripTextColorFromPreviews
        
//        self.blockImageView.addGestureRecognizer(self.zoomOutGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func bindStyles() {
        super.bindStyles()
        
        _ = self
            |> UITableViewCell.lens.selectionStyle .~ .none
        
        _ = self.favoriteButton
            |> UIButton.lens.accessibilityTraits .~ .button
            |> UIButton.lens.accessibilityLabel .~ "Favorite"
            |> UIButton.lens.accessibilityHint .~ "Favorite this content, if you like it"
        
        _ = self.shareButton
            |> UIButton.lens.accessibilityTraits .~ .button
            |> UIButton.lens.accessibilityLabel .~ "Share"
            |> UIButton.lens.accessibilityHint .~ "Share this content"
        
        _ = self.sourceButton
            |> UIButton.lens.accessibilityTraits .~ .button
            |> UIButton.lens.accessibilityLabel .~ "Source"
            |> UIButton.lens.accessibilityHint .~ "Source web of this content"
        
//        _ = self.blockTextView
//            |> UITextView.lens.translatesAutoresizingMaskIntoConstraints .~ false
        
        _ = self.blockImageView
            |> UIImageView.lens.contentMode .~ .scaleAspectFit
            |> UIImageView.lens.accessibilityTraits .~ .image
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.blockImageView.rac.hidden = self.viewModel.outputs.hideImageClass
//        self.blockTextLabel.rac.text = self.viewModel.outputs.blockClassText
        self.favoriteButton.rac.selected = self.viewModel.outputs.setFavoriteButton
        
        self.viewModel.outputs.hideImageClass
            .observe(on: UIScheduler())
            .observeValues { [weak self] hidden in
                guard let _self = self else { return }
                _ = _self.blockImageView
                    |> UIImageView.lens.isHidden .~ hidden
        }
        
        self.viewModel.outputs.hideTextClass
            .observe(on: UIScheduler())
            .observeValues { [weak self] hideText in
                guard let _self = self else { return }
                _self.blockTextView.isHidden = hideText
        }
        
        self.viewModel.outputs.blockClassText
            .observe(on: UIScheduler())
            .observeValues { [weak self] text in
                self?.blockTextView.text = text
                self?.blockTextView.accessibilityValue = text
                self?.blockTextView.accessibilityTraits = .staticText
                self?.blockTextView.layoutIfNeeded()
        }
        
        self.viewModel.outputs.imageUrlText
            .observe(on: QueueScheduler.main)
            .on(event: { [weak self] _ in
                print("Some Photos is nil")
                self?.blockImageView.pin_cancelImageDownload()
                self?.blockImageView.alpha = 0
            })
            .skipNil()
            .observeValues { [weak self] imageUrl in
                guard let _self = self else { return }
                _self.loadImage(imageUrl)
            }
 
        
        self.viewModel.outputs.syncFavorite
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] data in
                guard let _self = self else { return }
                print("Sync Favorite: \(String(describing: data))")
                _self.delegate?.getImageDataContent(_self, data: data)
        }
 
        
        self.viewModel.outputs.sourceTapped
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                guard let _self = self else { return }
                _self.delegate?.sourceMetaButtonTapped(_self)
        }
        
        self.viewModel.outputs.shareImageTapped
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] imageData in
                guard let _self = self else { return }
                _self.shareContents(imageData)
        }
        
        self.viewModel.outputs.shareTextTapped
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] textData in
                guard let _self = self else { return }
                _self.shareTextContents(textData)
        }
        
        self.viewModel.outputs.shareLinkTapped
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] linkData in
                guard let _self = self else { return }
                _self.shareLinkContents(linkData)

        }
        
        self.viewModel.outputs.saveBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] id, dataImage in
                guard let _self = self else { return }
                print("Save Block Here..")
                _self.saveIssuedOrder(idBlock: id, imageData: dataImage)
                _self.viewModel.inputs.isFavoriteSelectedButton(selected: true)
        }
        
        self.viewModel.outputs.saveTextBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] id, dataText in
                guard let _self = self else { return }
                _self.saveTextOrder(idBlock: id, textData: dataText)
                _self.viewModel.inputs.isFavoriteSelectedButton(selected: true)
        }
        
        self.viewModel.outputs.deleteBlock
            .observe(on: QueueScheduler.main)
            .observeValues { [weak self] favoriteBlock in
                self?.deleteIssuedOrder(local: favoriteBlock)
                self?.viewModel.inputs.isFavoriteSelectedButton(selected: false)
        }
 
    }
    
    func configureWith(value: BlockEnvelope) {
        self.viewModel.inputs.configure(block: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let aspectRatio = aspectRatio, let imageSize = imageSize {
            let width = min(imageSize.width, frame.width - 0)
            let actualHeight: CGFloat = ceil(width / aspectRatio) + 10
            if abs(actualHeight - frame.height) > 1 {
                onHeightMismatch?(actualHeight)
            }
        }
    }
    
    private func loadImage(_ url: URL) {
        self.blockImageView.pin_setImage(from: url) { [weak self] result in
            guard let _self = self else { return }
            
            _self.imageSize = result.imageSize
            
             _ = _self.blockImageView
                |> UIImageView.lens.translatesAutoresizingMaskIntoConstraints .~ true
            if result.resultType != .memoryCache {
                _self.blockImageView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    _self.blockImageView.alpha = 1.0
                    
                }
            } else {
                _self.blockImageView.alpha = 1.0
            }
            
            _self.currentImageFrame = _self.blockImageView.frame
            
            if let imageAnimatedData = result.animatedImage {
                _self.viewModel.inputs.getImageBlock(data: imageAnimatedData.data)
            } else if let imageStatic = result.image {
                _self.saveImageToSharedContainer(imageStatic)
            }
            
            /*
            guard let imageData = result.image else { return }
            
            if !result.animatedImage.isNil {
                
            }
            
            _self.saveImageToSharedContainer(imageData)
            */
            
            
            _self.layoutIfNeeded()
        }
    }
    
    private func saveImageToSharedContainer(_ image: UIImage) {
        guard let encodedMedia = image.JPEGEncoded() else {
            return
        }
        print("What Encoded Media here: \(String(describing: encodedMedia))")
        self.viewModel.inputs.getImageBlock(data: encodedMedia)
    }
    
    private func saveIssuedOrder(idBlock: Int, imageData: Data, source: String? = "") {
        let realm = Realm.current
        let favoriteBlock = BlockLocal()
        favoriteBlock.rid = String(idBlock)
        favoriteBlock.imageData = imageData
        favoriteBlock.source = source
        guard let favoriteList = realm?.objects(IndividualFavorite.self).first else { return }
        try! realm?.write {
            print("Executing Realm Here....")
            favoriteList.items.append(favoriteBlock)
            //            self.viewModel.inputs.isFavoriteSelectedButton(selected: true)
            self.viewModel.inputs.localFromNotification(block: favoriteBlock)
        }
    }
    
    private func saveTextOrder(idBlock: Int, textData: String) {
        let realm = Realm.current
        try! realm?.write {
            print("Executing Realm Here....")
            let favoriteBlock = BlockLocal()
            favoriteBlock.rid = String(idBlock)
            favoriteBlock.textData = textData
            guard let favoriteList = realm?.objects(IndividualFavorite.self).first else { return }
            favoriteList.items.append(favoriteBlock)
            self.viewModel.inputs.localFromNotification(block: favoriteBlock)
        }
    }
    
    
    private func deleteIssuedOrder(local: BlockLocal) {
        guard !local.isInvalidated else {
            return
        }
        let realm = Realm.current
        guard let favoriteList = realm?.objects(IndividualFavorite.self).first else { return }
        try! realm?.write {
            if let blockIndex = favoriteList.items.lastIndex(where: { $0.rid == local.rid }) {
                favoriteList.items.remove(at: blockIndex)
            }
        }
        
    }
    
    private func shareContents(_ imageData: Data) {
        var activityItems = [Data]()
        activityItems.append(imageData)
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if AppEnvironment.current.device.userInterfaceIdiom == .pad {
            activityController.modalPresentationStyle = .popover
            
            activityController.popoverPresentationController?.sourceView = self.shareButton.imageView
            activityController.popoverPresentationController?.sourceRect = self.shareButton.bounds
        }
        self.delegate?.shareViewControllerPresented(self, controller: activityController)
    }
    
    fileprivate func shareTextContents(_ dataText: String) {
        var activityItems = [String]()
        activityItems.append(dataText)
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if AppEnvironment.current.device.userInterfaceIdiom == .pad {
            activityController.modalPresentationStyle = .popover
            
            activityController.popoverPresentationController?.sourceView = self.shareButton.imageView
            activityController.popoverPresentationController?.sourceRect = self.shareButton.bounds
        }
        self.delegate?.shareViewControllerPresented(self, controller: activityController)
    }
    
    fileprivate func shareLinkContents(_ dataLink: URL) {
        var activityItems = [URL]()
        activityItems.append(dataLink)
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if AppEnvironment.current.device.userInterfaceIdiom == .pad {
            activityController.modalPresentationStyle = .popover
            
            activityController.popoverPresentationController?.sourceView = self.shareButton.imageView
            activityController.popoverPresentationController?.sourceRect = self.shareButton.bounds
        }
        //        guard let popOverVC = activityController.popoverPresentationController else { return }
        self.delegate?.shareViewControllerPresented(self, controller: activityController)
    }
    
    private func updateTransformImage() {
        self.imagePanGesture.isEnabled = true
        
        var transformImage = CATransform3DIdentity
        transformImage = CATransform3DScale(transformImage, imageScale, imageScale, 1.01)
        transformImage = CATransform3DTranslate(transformImage, imageOffset.x, imageOffset.y, 0)
        
        UIView.animate(withDuration: 0.3) {
            self.blockImageView.layer.transform = transformImage
        }
    }
    
    private func normalizeImageTransform() {
        var adjusted = false
        if imageScale < 1 {
            imageScale = 1
            imageOffset = .zero
            adjusted = true
        } else {
            guard let imageSize = self.blockImageView.image?.size else { return }
            
            let actualImageScale = min(self.blockImageView.frame.width / imageSize.width, self.blockImageView.frame.height / imageSize.height)
            let actualImageSize = CGSize(width: imageSize.width * actualImageScale, height: imageSize.height * actualImageScale)
            let adjustedActualFrame = CGRect(x: self.blockImageView.frame.minX + (self.blockImageView.frame.width - actualImageSize.width) / 2, y: self.blockImageView.frame.minY + (self.blockImageView.frame.height - actualImageSize.height) / 2, width: actualImageSize.width, height: actualImageSize.height)
            
            if adjustedActualFrame.width < self.currentImageFrame.width {
                if adjustedActualFrame.minX < self.currentImageFrame.minX {
                    let delta = currentImageFrame.minX - adjustedActualFrame.minX
                    imageOffset.x += delta / imageScale
                    adjusted = true
                } else if adjustedActualFrame.maxX > self.currentImageFrame.maxX {
                    let delta = adjustedActualFrame.maxX - currentImageFrame.maxX
                    imageOffset.x -= delta / imageScale
                    adjusted = true
                }
            } else {
                if adjustedActualFrame.minX > currentImageFrame.minX {
                    let delta = adjustedActualFrame.minX - currentImageFrame.minX
                    imageOffset.x -= delta / imageScale
                    adjusted = true
                } else if adjustedActualFrame.maxX < currentImageFrame.maxX {
                    let delta = currentImageFrame.maxX - adjustedActualFrame.maxX
                    imageOffset.x += delta / imageScale
                    adjusted = true
                }
            }
            
            if adjustedActualFrame.height < currentImageFrame.height {
                if adjustedActualFrame.minY < currentImageFrame.minY {
                    let delta = currentImageFrame.minY - adjustedActualFrame.minY
                    imageOffset.y += delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxY > currentImageFrame.maxY {
                    let delta = adjustedActualFrame.maxY - currentImageFrame.maxY
                    imageOffset.y -= delta / imageScale
                    adjusted = true
                }
            } else {
                if adjustedActualFrame.minY > currentImageFrame.minY {
                    let delta = adjustedActualFrame.minY - currentImageFrame.minY
                    imageOffset.y -= delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxY < currentImageFrame.maxY {
                    let delta = currentImageFrame.maxY - adjustedActualFrame.maxY
                    imageOffset.y += delta / imageScale
                    adjusted = true
                }
            }
        }
        
        if adjusted {
            updateTransformImage()
        }
    }
    
    
    @objc private func imagePanGestureMovement(gesture: UIPanGestureRecognizer) {
//        var translation = gesture.translation(in: self.blockImageView)
        if self.isZooming && gesture.state == .began {
            tempOffset = gesture.view?.center
        }
        else if self.isZooming && gesture.state == .changed {
            let translation = gesture.translation(in: self)
            if let view = gesture.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            
            gesture.setTranslation(CGPoint.zero, in: self.blockImageView.superview)
        }
    }
    
    @objc private func pinchGestureMovement(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            let currentScale = self.blockImageView.frame.size.width / self.blockImageView.bounds.size.width
            let newScale = currentScale*gesture.scale
            
            if newScale > 1 {
                self.isZooming = true
            }
        } else if gesture.state == .changed {
            guard let view = gesture.view else {return}
            
            let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                      y: gesture.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: gesture.scale, y: gesture.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            
            let currentScale = self.blockImageView.frame.size.width / self.blockImageView.bounds.size.width
            var newScale = currentScale*gesture.scale
            
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.blockImageView.transform = transform
                gesture.scale = 1
            }else {
                view.transform = transform
                gesture.scale = 1
            }
        } else if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            guard let center = self.tempOffset else {return}
            
            UIView.animate(withDuration: 0.3, animations: {
                self.blockImageView.transform = CGAffineTransform.identity
                self.blockImageView.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
    }
    
    /*
    @objc fileprivate func pinchGestureMovement(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            
        }
    }
    
    @objc fileprivate func imagePanGestureMovement(gesture: UIPanGestureRecognizer) {
        var translation = gesture.translation(in: self.blockImageView)
    }
    

    @objc fileprivate func scrollPanGestureMovement(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.blockImageView)
        
        if gesture.state == .began {
            imageScale = 1
            imageOffset = .zero
        } else if gesture.state == .ended {
            let velocity = gesture.velocity(in: self.blockImageView)
            
            let delta: Delta?
            if translation.x < -20 && velocity.x < 0 {
                delta = .next
            } else if translation.x > 20 && velocity.x > 0 {
                delta = .prev
            }
        }
    }
    */
    
    @objc fileprivate func sourceButtonTapped() {
        self.viewModel.inputs.sourceButtonTapped()
    }
    
    @objc fileprivate func favoriteButtonTapped() {
        self.viewModel.inputs.favoriteButtonTapped()
    }
    
    @objc fileprivate func shareButtonTapped() {
        self.viewModel.inputs.shareButtonTapped()
    }
}

extension ContentBlockTableViewCell: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if let imageDragView = interaction.view as? FLAnimatedImageView {
            guard let image = imageDragView.image else { return [] }
            let providerImage = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: providerImage)
            item.localObject = image
            return [item]
        }
        return []
    }
}

extension ContentBlockTableViewCell: UITextDragDelegate {
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        guard let textSelected = textDraggableView.text(in: dragRequest.dragRange) else { return [] }
        let providerText = NSItemProvider(object: NSString(string: textSelected))
        let itemText = UIDragItem(itemProvider: providerText)
        itemText.localObject = textSelected
        
        return [itemText]
    }
}
