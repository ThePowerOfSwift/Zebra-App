//
//  SearchChannelsEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 12/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct SearchChannelsEnvelope {
    public let term: String
    public let per: Int
    public let currentPage: Int
    public let totalPages: Int
    public let length: Int
    public let authenticated: Bool
    public let channels: [ListChannel]
}

extension SearchChannelsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SearchChannelsEnvelope> {
        let create = curry(SearchChannelsEnvelope.init)
            <^> json <| "term"
            <*> json <| "per"
            <*> json <| "current_page"
        return create
            <*> json <| "total_pages"
            <*> json <| "length"
            <*> json <| "authenticated"
            <*> json <|| "channels"
    }
}
