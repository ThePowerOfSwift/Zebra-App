//
//  CompleteChannelEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 01/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct CompleteChannelEnvelope {
    public let id: Int
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let channelStatus: ChannelStatus
    public let contents: [Block]
    public let page: Int
    
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

/*
"page": 1,
"per": 25,
"collaborators": [],
"follower_count": 6,
"share_link": null,
"metadata": null,
"class_name": "Channel",
"can_index": true,
"nsfw?": false,
*/
 
extension CompleteChannelEnvelope: Equatable {}
public func == (lhs: CompleteChannelEnvelope, rhs: CompleteChannelEnvelope) -> Bool {
    return lhs.id == rhs.id
}


extension CompleteChannelEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<CompleteChannelEnvelope> {
        let create = curry(CompleteChannelEnvelope.init)
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
            <*> json <| "page"
    }
}

extension CompleteChannelEnvelope.ChannelStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<CompleteChannelEnvelope.ChannelStatus> {
        let create = curry(CompleteChannelEnvelope.ChannelStatus.init)
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
