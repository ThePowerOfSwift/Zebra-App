//
//  BlocksEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 29/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct BlockChannelsEnvelope {
    public let length: Int
    public let totalPages: Int
    public let currentPage: Int
    public let per: Int
    public let channelTitle: String?
    public let baseClass: String
    public let classBlock: String
    public let channels: [Channel]
}


extension BlockChannelsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockChannelsEnvelope> {
        let create = curry(BlockChannelsEnvelope.init)
            <^> json <| "length"
            <*> json <| "total_pages"
            <*> json <| "current_page"
            <*> json <| "per"
        return create
            <*> json <|? "channel_title"
            <*> json <| "base_class"
            <*> json <| "class"
            <*> json <|| "channels"
    }
}
