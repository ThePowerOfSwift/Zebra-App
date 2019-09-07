//
//  PINRemoteImagemanagerResult.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 07/08/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import PINRemoteImage

public extension PINRemoteImageManagerResult {
    
    var isAnimated: Bool {
        return animatedImage != nil
    }
    
    var imageSize: CGSize? {
        return isAnimated ? animatedImage?.size : image?.size
    }
    
    var hasImage: Bool {
        return image != nil || animatedImage != nil
    }
}
