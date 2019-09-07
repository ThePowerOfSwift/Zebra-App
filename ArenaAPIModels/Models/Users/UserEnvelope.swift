//
//  UserEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 06/06/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

/*
 {"id":17,"created_at":"2011-06-21T01:41:32.390Z","slug":"damon-zucconi","username":"Damon Zucconi","first_name":"Damon","last_name":"Zucconi","full_name":"Damon Zucconi","avatar":"https://arena-avatars.s3.amazonaws.com/17/small_35df8fd928b7eefcf7ff673a50598412.png?1545489709","avatar_image":{"thumb":"https://arena-avatars.s3.amazonaws.com/17/small_35df8fd928b7eefcf7ff673a50598412.png?1545489709","display":"https://arena-avatars.s3.amazonaws.com/17/medium_35df8fd928b7eefcf7ff673a50598412.png?1545489709"},"channel_count":605,"following_count":1096,"profile_id":105,"follower_count":748,"initials":"DZ","can_index":true,"metadata":{"description":"[damonzucconi.com](http://www.damonzucconi.com)\n[twitter.com/dzucconi](https://twitter.com/dzucconi)\n[instagram.com/damonzucconi](https://www.instagram.com/damonzucconi/)\n\nPhiladelphia"},"is_premium":true,"is_exceeding_private_connections_limit":false,"is_confirmed":true,"is_pending_reconfirmation":false,"is_pending_confirmation":false,"badge":"premium","base_class":"User","class":"User"}
 */

public struct UserEnvelope {
    public let id: Int
    public let createdAt: String
    public let slug: String
    public let username: String
    
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let channelCount: Int
    
    public let followingCount: Int
    public let profileId: Int
    public let followerCount: Int
    public let metadata: UserMetadata
    public let userStatus: UserStatus
    
    public struct UserMetadata {
        public let description: String?
    }
    
    public struct UserStatus {
        public let isPremium: Bool
        public let isExceedingConnections: Bool
        public let badge: String
        
    }
}

extension UserEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserEnvelope> {
        let create = curry(UserEnvelope.init)
            <^> json <| "id"
            <*> json <| "created_at"
            <*> json <| "slug"
            <*> json <| "username"
        
        let tmp1 = create
            <*> json <| "first_name"
            <*> json <| "last_name"
            <*> json <| "full_name"
            <*> json <| "channel_count"
        
        return tmp1
            <*> json <| "following_count"
            <*> json <| "profile_id"
            <*> json <| "follower_count"
            <*> json <| "metadata"
            <*> UserStatus.decode(json)
    }
}

extension UserEnvelope.UserMetadata: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserEnvelope.UserMetadata> {
        return curry(UserEnvelope.UserMetadata.init)
            <^> (json <|? "description" <|> .success(nil))
    }
}

extension UserEnvelope.UserStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<UserEnvelope.UserStatus> {
        return curry(UserEnvelope.UserStatus.init)
            <^> json <| "is_premium"
            <*> json <| "is_exceeding_private_connection"
            <*> json <| "badge"
    }
}

