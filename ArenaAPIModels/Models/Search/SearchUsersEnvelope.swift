//
//  SearchUsersEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 12/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct SearchUsersEnvelope {
    public let term: String
    public let per: Int
    public let currentPage: Int
    public let totalPages: Int
    public let length: Int
    public let authenticated: Bool
    public let users: [ListUser]
}

extension SearchUsersEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SearchUsersEnvelope> {
        let create = curry(SearchUsersEnvelope.init)
            <^> json <| "term"
            <*> json <| "per"
            <*> json <| "current_page"
        return create
            <*> json <| "total_pages"
            <*> json <| "length"
            <*> json <| "authenticated"
            <*> json <|| "users"
    }
}
