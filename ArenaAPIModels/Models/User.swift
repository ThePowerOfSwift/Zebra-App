//
//  User.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct User {
    public let id: Int
    public let createdAt: String
    public let slug: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let avatar: String
    public let avatarImage: AvatarImage
    public let channelCount: Int
    public let followingCount: Int
    public let profileId: Int?
    public let followerCount: Int
    public let initials: String
    public let canIndex: Bool
//    public let metadata: Metadata?
    public let userStatus: UserBlockStatus
    
    public struct UserBlockStatus {
        public let isPremium: Bool
        public let isExceedingPrivateConnection: Bool
        public let isConfirmed: Bool
        public let isPendingReconfirmation: Bool
        public let isPendingConfirmation: Bool
        public let badge: String?
        public let baseClass: String
        public let classUser: String
    }
    
    public struct AvatarImage {
        public let thumbUrl: String
        public let displayUrl: String
    }
    
    public struct Metadata {
        public let description: String
    }
}

extension User: Equatable {}
public func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

extension User: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<User> {
        let create = curry(User.init)
            <^> json <| "id"
            <*> json <| "created_at"
            <*> json <| "slug"
            <*> json <| "username"
        
        let tmp1 = create
            <*> json <| "first_name"
            <*> json <| "last_name"
            <*> json <| "full_name"
            <*> json <| "avatar"
        
        let tmp2 = tmp1
            <*> json <| "avatar_image"
            <*> json <| "channel_count"
            <*> json <| "following_count"
            <*> (json <|? "profile_id" <|> .success(nil))
        
        return tmp2
            <*> json <| "follower_count"
            <*> json <| "initials"
            <*> json <| "can_index"
//            <*> json <|? "metadata"
            <*> UserBlockStatus.decode(json)
    }
}

extension User.UserBlockStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<User.UserBlockStatus> {
        let create = curry(User.UserBlockStatus.init)
            <^> json <| "is_premium"
            <*> json <| "is_exceeding_private_connections_limit"
            <*> json <| "is_confirmed"
            <*> json <| "is_pending_reconfirmation"
            <*> json <| "is_pending_confirmation"
        
        return create
            <*> json <|? "badge"
            <*> json <| "base_class"
            <*> json <| "class"
    }
}

extension User.AvatarImage: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<User.AvatarImage> {
        return curry(User.AvatarImage.init)
            <^> json <| "thumb"
            <*> json <| "display"
    }
}

/*
extension User.Metadata: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<User.Metadata> {
        return curry(User.Metadata.init)
            <^> json <| "description"
    }
}
*/
