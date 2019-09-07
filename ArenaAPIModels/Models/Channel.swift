//
//  Channel.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct Channel {
    public let id: Int
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let channelStatus: ChannelStatus
    public let contents: [Block]
    
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

public struct Metadata {
    public let description: String?
}

extension Channel: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Channel> {
        let create = curry(Channel.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "created_at"
            <*> json <| "updated_at"
        let tmp1 = create
            <*> json <| "added_to_at"
            <*> json <| "published"
            <*> json <| "open"
        return tmp1
            <*> ChannelStatus.decode(json)
            <*> json <|| "contents"
    }
}

extension Channel.ChannelStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Channel.ChannelStatus> {
        let create = curry(Channel.ChannelStatus.init)
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

extension Metadata: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Metadata> {
        return curry(Metadata.init)
            <^> (json <|? "description" <|> .success(nil))
    }
}
