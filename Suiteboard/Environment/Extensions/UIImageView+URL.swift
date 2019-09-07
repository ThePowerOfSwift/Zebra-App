//
//  UIImageView+URL.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 02/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//
import AlamofireImage
import UIKit

extension UIImageView {
    public func ss_setImageWithURL(_ url: URL) {
        self.af_setImage(withURL: url, placeholderImage: UIImage(named: "placeholder-image")!, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false           , completion: nil)
    }
}
