//
//  UserFollowingsEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct UserFollowingsEnvelope {
    public let length: Int
    public let totalPages: Int
    public let currentPage: Int
    public let perPage: Int
    public let baseClass: String
    public let typeClass: String
    public let followings: [UserChannel]
}

public enum TableContent {
    case ListUser
    case ListChannel
    case unknown
}

extension TableContent: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<TableContent> {
        if case .init(ListUser.self) = json {
            return .success(.ListUser)
        } else if case .init(ListChannel.self) = json {
            return .success(.ListChannel)
        }
        return .success(.unknown)
    }
}

extension UserFollowingsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserFollowingsEnvelope> {
        let create = curry(UserFollowingsEnvelope.init)
            <^> json <| "length"
            <*> json <| "total_pages"
            <*> json <| "current_page"
            <*> json <| "per"
        return create
            <*> json <| "base_class"
            <*> json <| "class"
            <*> json <|| "following"
    }
}

/*
extension UserFollowingsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserFollowingsEnvelope> {
        
    }
}
 */
