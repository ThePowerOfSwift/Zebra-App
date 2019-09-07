//
//  ListChannelsEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 08/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct ListChannelsEnvelope {
    public let term: String?
    public let per: Int
    public let currentPage: Int
    public let totalPages: Int
    public let length: Int
    public let authenticated: Bool
    public let channels: [ListChannel]
}

extension ListChannelsEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ListChannelsEnvelope> {
        let create = curry(ListChannelsEnvelope.init)
            <^> json <|? "term"
            <*> json <| "per"
            <*> json <| "current_page"
        return create
            <*> json <| "total_pages"
            <*> json <| "length"
            <*> json <| "authenticated"
            <*> json <|| "channels"
    }
}

public struct ListChannel {
    public let id: String
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let channelStatus: ChannelStatus
    public let user: ListUser
    
    
}

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

extension ListChannel: Equatable {}
public func == (lhs: ListChannel, rhs: ListChannel) -> Bool {
    return lhs.id == rhs.id
}

extension ListChannel: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ListChannel> {
        let create = curry(ListChannel.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "created_at"
            <*> json <| "updated_at"
        let tmp1 = create
            <*> json <| "added_to_at"
            <*> json <| "published"
            <*> json <| "open"
            <*> ChannelStatus.decode(json)
            <*> json <| "user"
        return tmp1
    }
}

extension ChannelStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ChannelStatus> {
        let create = curry(ChannelStatus.init)
            <^> json <| "collaboration"
            <*> json <|? "collaborator_count"
            <*> json <| "slug"
            <*> json <| "length"
        return create
            <*> json <| "kind"
            <*> json <| "status"
            <*> json <| "user_id"
            <*> (json <|? "metadata" <|> .success(nil))
    }
}

public struct ListUser {
    public let id: Int
    public let createdAt: String?
    public let slug: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let avatar: String
    public let userStatus: UserStatus
    
    public struct UserStatus {
        public let channelCount: Int
        public let followingCount: Int
        public let profileId: Int?
        public let followerCount: Int
        public let initials: String
        public let canIndex: Bool?
    }
    
    public let metadata: Metadata?
}

extension ListUser: Equatable {}
public func == (lhs: ListUser, rhs: ListUser) -> Bool {
    return lhs.id == rhs.id
}

extension ListUser: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ListUser> {
        let create = curry(ListUser.init)
            <^> json <| "id"
            <*> json <|? "created_at"
            <*> json <| "slug"
            <*> json <| "username"
        
        return create
            <*> json <| "first_name"
            <*> json <| "last_name"
            <*> json <| "full_name"
            <*> json <| "avatar"
            <*> UserStatus.decode(json)
            <*> json <|? "metadata"
    }
}

extension ListUser.UserStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ListUser.UserStatus> {
        let create = curry(ListUser.UserStatus.init)
            <^> json <| "channel_count"
            <*> json <| "following_count"
            <*> (json <|? "profile_id" <|> .success(nil))
            <*> json <| "follower_count"
        
        return create
            <*> json <| "initials"
            <*> json <|? "can_index"
    }
}

public struct UserChannel {
    public let id: Int
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let channelStatus: ChannelStatus
    public let user: ListUser
}

extension UserChannel: Equatable {}
public func == (lhs: UserChannel, rhs: UserChannel) -> Bool {
    return lhs.id == rhs.id
}

extension UserChannel: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserChannel> {
        let create = curry(UserChannel.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "created_at"
            <*> json <| "updated_at"
        let tmp1 = create
            <*> json <| "added_to_at"
            <*> json <| "published"
            <*> json <| "open"
            <*> ChannelStatus.decode(json)
            <*> json <| "user"
        return tmp1
    }
}
