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

public struct Connection {
    public let id: Int
    public let title: String
    public let createdAt: String
    public let updatedAt: String
    
    public let addedToAt: String
    public let published: Bool
    public let open: Bool
    public let statusConnection: ConnectionBlockStatus
    
    public let shareLink: String?
    public let user: ListUser
    public let group: ConnectionGroup?
    public let baseClass: String
    
    public struct ConnectionBlockStatus {
        public let collaboration: Bool
        public let slug: String
        public let length: Int
        public let kind: String
        public let status: String
        public let userId: Int
        public let metadata: Metadata?
    }
    
    public struct ConnectionGroup {
        public let visibility: Int
        public let id: Int
        public let baseClass: String
        public let updatedAt: String
        
//        public let description: String?
        public let className: String
        public let name: String
    }
}

extension Connection: Equatable {}
public func == (lhs: Connection, rhs: Connection) -> Bool {
    return lhs.id == rhs.id
}

extension Connection: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Connection> {
        let create = curry(Connection.init)
            <^> json <| "id"
            <*> json <| "title"
            <*> json <| "created_at"
            <*> json <| "updated_at"
        let tmp1 = create
            <*> json <| "added_to_at"
            <*> json <| "published"
            <*> json <| "open"
            <*> ConnectionBlockStatus.decode(json)
        
        return tmp1
            <*> json <|? "share_link"
            <*> json <| "user"
            <*> (json <|? "group" <|> .success(nil))
            <*> json <| "base_class"
    }
}

extension Connection.ConnectionBlockStatus: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Connection.ConnectionBlockStatus> {
        let create = curry(Connection.ConnectionBlockStatus.init)
            <^> json <| "collaboration"
            <*> json <| "slug"
            <*> json <| "length"
            <*> json <| "kind"
        
        return create
            <*> json <| "status"
            <*> json <| "user_id"
            <*> json <|? "metadata"
    }
}

extension Connection.ConnectionGroup: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Connection.ConnectionGroup> {
        let create = curry(Connection.ConnectionGroup.init)
            <^> json <| "visibility"
            <*> json <| "id"
            <*> json <| "base_class"
            <*> json <| "updated_at"
        return create
//            <*> (json <|? "description" <|> .success(nil))
            <*> json <| "class"
            <*> json <| "name"
    }
}
