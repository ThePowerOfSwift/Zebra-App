//
//  ContentsChannelEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct ContentsChannelEnvelope {
    public let contents: [Block]
}

extension ContentsChannelEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ContentsChannelEnvelope> {
        return curry(ContentsChannelEnvelope.init)
            <^> json <|| "contents"
    }
}

