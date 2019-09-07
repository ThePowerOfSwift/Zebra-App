//
//  UserChannelsEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct UserChannelsEnvelope {
    public let channels: [ChannelUser]
}

extension UserChannelsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserChannelsEnvelope> {
        return curry(UserChannelsEnvelope.init)
            <^> json <|| "channels"
    }
}


public struct ChannelUser {
    public let id: Int
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let channelStatus: ChannelStatus
//    public let user: ListUser
    
    public struct ChannelStatus {
        public let collaboration: Bool
        public let collaboratorCount: Int?
        public let slug: String
        public let length: Int
        public let kind: String
        public let status: String
        public let userId: Int
        public let metadata: Metadata?
    }
}

extension ChannelUser: Equatable {}
public func == (lhs: ChannelUser, rhs: ChannelUser) -> Bool {
    return lhs.id == rhs.id
}

extension ChannelUser: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ChannelUser> {
        let create = curry(ChannelUser.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "created_at"
            <*> json <| "updated_at"
        let tmp1 = create
            <*> json <| "added_to_at"
            <*> json <| "published"
            <*> json <| "open"
            <*> ChannelStatus.decode(json)
//            <*> json <| "user"
        return tmp1
    }
}

extension ChannelUser.ChannelStatus: Argo.Decodable {
        public static func decode(_ json: JSON) -> Decoded<ChannelUser.ChannelStatus> {
            let create = curry(ChannelUser.ChannelStatus.init)
                <^> json <| "collaboration"
                <*> json <|? "collaborator_count"
                <*> json <| "slug"
                <*> json <| "length"
            return create
                <*> json <| "kind"
                <*> json <| "status"
                <*> json <| "user_id"
                <*> json <|? "metadata"
    }
}
