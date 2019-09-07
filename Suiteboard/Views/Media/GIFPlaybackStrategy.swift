//
//  GIFPlaybackStrategy.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 22/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

@objc
public enum GIFStrategy: Int {
    case smallGIFs
    case mediumGIFs
    case largeGIFs
    
    var playbackStrategy: GIFPlaybackStrategy {
        switch self {
        case .smallGIFs:
            return SmallGIFPlaybackStrategy()
        case .mediumGIFs:
            return MediumGIFPlaybackStrategy()
        case .largeGIFs:
            return LargeGIFPlaybackStrategy()
        }
    }
}

public protocol GIFPlaybackStrategy {
    
    var maxSize: Int { get }
    
    var frameBufferCount: Int { get }
    
    var gifStrategy: GIFStrategy { get }
    
    func verifyDataSize(_ data: Data) -> Bool
}

extension GIFPlaybackStrategy {
    func verifyDataSize(_ data: Data) -> Bool {
        guard data.count <= maxSize else {
            print("⚠️ Maximum GIF data size exceeded \(maxSize) with \(data.count)")
            return false
        }
        return true
    }
}


class SmallGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 8_000_000  // in MB
    var frameBufferCount = 25
    var gifStrategy: GIFStrategy = .smallGIFs
}

class MediumGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 20_000_000  // in MB
    var frameBufferCount = 50
    var gifStrategy: GIFStrategy = .mediumGIFs
}

class LargeGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 50_000_000  // in MB
    var frameBufferCount = 60
    var gifStrategy: GIFStrategy = .largeGIFs
}
