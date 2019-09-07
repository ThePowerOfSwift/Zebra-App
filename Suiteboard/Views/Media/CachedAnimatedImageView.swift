//
//  CachedAnimatedImageView.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 13/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import AlamofireImage
import Gifu
import UIKit

public class CachedAnimatedImageView: UIImageView, GIFAnimatable {
    
    @objc public var gifStrategy: GIFStrategy {
        get {
            return gifPlaybackStrategy.gifStrategy
        }
        set(newGifStrategy) {
            gifPlaybackStrategy = newGifStrategy.playbackStrategy
        }
    }
    
    @objc public private(set) var animatedGifData: Data?
    
    public lazy var animator: Gifu.Animator? = {
       return Gifu.Animator(withDelegate: self)
    }()
    
    private var gifPlaybackStrategy: GIFPlaybackStrategy = MediumGIFPlaybackStrategy()
    
    @objc private var currentTask: URLSessionTask?
    
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLowMemoryWarningNotification), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    // MARK: - Public methods
    
    public override func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
    
    public func setAnimatedImage(_ urlRequest: URLRequest, placeholderImage: UIImage?, success: (() -> Void)?, failure: ((NSError?) -> Void)?) {
        
        currentTask?.cancel()
        image = placeholderImage
        
        if checkCache(urlRequest, success) {
            return
        }
        
        let successBlock: (Data, UIImage?) -> Void = { [weak self] animatedImageData, staticImage in
            self?.validateAndSetGifData(animatedImageData, alternateStaticImage: staticImage, success: success)
        }
        
        currentTask = AnimatedImageCache.shared.animatedImage(urlRequest, placeHolderImage: placeholderImage, success: successBlock, failure: failure)
    }
    
    @objc public func clean() {
        currentTask?.cancel()
        image = nil
        animatedGifData = nil
    }
    
    
    // MARK: - Private methods
    @objc private func handleLowMemoryWarningNotification(_ notification: NSNotification) {
        stopAnimatingGIF()
    }
    
    private func validateAndSetGifData(_ animatedImageData: Data, alternateStaticImage: UIImage? = nil, success: (() -> Void)? = nil) {
        let didVerifyDataSize = gifPlaybackStrategy.verifyDataSize(animatedImageData)
        DispatchQueue.main.async() {
            if let staticImage = alternateStaticImage {
                self.image = staticImage
            } else {
                self.image = UIImage(data: animatedImageData)
            }
            
            DispatchQueue.global().async {
                if didVerifyDataSize {
                    self.animate(data: animatedImageData, success: success)
                } else {
                    self.animatedGifData = nil
                    success?()
                }
            }
        }
    }
    
    private func checkCache(_ urlRequest: URLRequest, _ success: (() -> Void)?) -> Bool {
        if let cachedData = AnimatedImageCache.shared.cachedData(url: urlRequest.url) {
            
            if let cachedStaticImage = AnimatedImageCache.shared.cachedStaticImage(url: urlRequest.url) {
                image = cachedStaticImage
            } else {
                animatedGifData = nil
                let staticImage = UIImage(data: cachedData)
                image = staticImage
                AnimatedImageCache.shared.cacheStaticImage(url: urlRequest.url, image: staticImage)
            }
            
            if gifPlaybackStrategy.verifyDataSize(cachedData) {
                animate(data: cachedData, success: success)
            } else {
                success?()
            }
            
            return true
        }
        return false
    }
    
    private func animate(data: Data, success: (() -> Void)?) {
        animatedGifData = data
        DispatchQueue.main.async() {
            self.setFrameBufferCount(self.gifPlaybackStrategy.frameBufferCount)
            self.animate(withGIFData: data) {
                success?()
            }
        }
    }
    
    // Mark: Layout
    
    private func prepareViewForLayout(_ view: UIView) {
        if view.superview == nil {
            addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func layoutViewCentered(_ view: UIView, size: CGSize?) {
        prepareViewForLayout(view)
        var constraints: [NSLayoutConstraint] = [
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        if let size = size {
            constraints.append(view.heightAnchor.constraint(equalToConstant: size.height))
            constraints.append(view.widthAnchor.constraint(equalToConstant: size.width))
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func layoutViewFullView(_ view: UIView) {
        prepareViewForLayout(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
}
