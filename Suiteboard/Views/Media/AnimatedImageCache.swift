//
//  AnimatedImageCache.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 13/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import UIKit

class AnimatedImageCache {
    
    static let shared: AnimatedImageCache = AnimatedImageCache()
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(AnimatedImageCache.handleMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    fileprivate lazy var session: URLSession = {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }()
    
    fileprivate static var cache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = totalCostLimit()
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let cacheSizeinMB = bcf.string(fromByteCount: Int64(totalCostLimit()))
        
        return cache
    }()
    
    @objc func handleMemoryWarning() {
        clearCache()
    }
    
    func clearCache() {
        AnimatedImageCache.cache.removeAllObjects()
    }
    
    func cachedData(url: URL?) -> Data? {
        guard let key = url else {
            return nil
        }
        
        return AnimatedImageCache.cache.object(forKey: key as AnyObject) as? Data
    }
    
    func cacheStaticImage(url: URL?, image: UIImage?) {
        guard let url = url,
            let image = image else {
                return
        }
        
        let key = url.absoluteString + Constants.keyStaticImageSuffix
        AnimatedImageCache.cache.setObject(image as AnyObject, forKey: key as AnyObject)
    }
    
    func cachedStaticImage(url: URL?) -> UIImage? {
        guard let url = url else {
            return nil
        }
        let key = url.absoluteString + Constants.keyStaticImageSuffix
        return AnimatedImageCache.cache.object(forKey: key as AnyObject) as? UIImage
    }
    
    func animatedImage(_ urlRequest: URLRequest, placeHolderImage: UIImage?, success: ((Data, UIImage?) -> Void)?, failure: ((NSError?) -> Void)? ) -> URLSessionTask? {
        if let cachedImageData = cachedData(url: urlRequest.url) {
            success?(cachedImageData, cachedStaticImage(url: urlRequest.url))
            return nil
        }
        
        let task = session.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
            guard let _ = self else {
                return
            }
            // check if there is an error
            if let error = error {
                let nsError = error as NSError
                if nsError.code != NSURLErrorCancelled {
                    failure?(nil)
                }
                return
            }
            // check if data is here and is animated gif
            guard let data = data else {
                failure?(nil)
                return
            }
            
            let staticImage = UIImage(data: data)
            if let key = urlRequest.url {
                let dataByteCost = AnimatedImageCache.byteCost(for: data)
                AnimatedImageCache.cache.setObject(data as NSData, forKey: key as NSURL, cost: dataByteCost)
                
                let imageByteCost = AnimatedImageCache.byteCost(for: staticImage)
                let imageKey = key.absoluteString + Constants.keyStaticImageSuffix
                AnimatedImageCache.cache.setObject(staticImage as AnyObject, forKey: imageKey as AnyObject, cost: imageByteCost)
            }
            success?(data, staticImage)
        })
        
        task.resume()
        return task
    }
}

private extension AnimatedImageCache {
    static func byteCost(for image: UIImage?) -> Int {
        guard let image = image, let imageRef = image.cgImage else {
            return 0
        }
        return imageRef.bytesPerRow * imageRef.height
    }
    
    static func byteCost(for data: Data?) -> Int {
        guard let data = data else {
            return 0
        }
        return data.count
    }
    
    static func totalCostLimit() -> Int {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let cacheRatio = physicalMemory <= (Constants.memory512MB) ? Constants.smallCacheRatio : Constants.largeCacheRatio
        let cacheLimit = physicalMemory / UInt64(1 / cacheRatio)
        return cacheLimit > UInt64(Int.max) ? Int.max : Int(cacheLimit)
    }
}

private extension AnimatedImageCache {
    struct Constants {
        static let keyStaticImageSuffix = "_static_image"
        static let memory512MB: UInt64 = 1024 * 1024 * 512
        static let smallCacheRatio: CGFloat = 0.1
        static let largeCacheRatio: CGFloat = 0.2
    }
}
