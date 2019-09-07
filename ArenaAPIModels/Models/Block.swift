//
//  Block.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public enum BlockClassType: String {
    case Image
    case Link
    case User
    case Channel
    case Text
    case Attachment
    case Unknown = "Placeholder"
}

public struct Block {
    public let id: Int
    public let title: String?
    public let updatedAt: String?
    public let createdAt: String?
    public let state: String?
    
    public let commentCount: Int?
    public let generatedTitle: String?
    public let contentHtml: String?
    public let visibility: String?
    public let descriptionHtml: String?
    public let content: String?
    
    public let description: String?
    public let source: BlockSource?
    public let image: BlockImage?
    public let embed: BlockEmbed?
    public let attachment: BlockAttachment?
    
    public let baseClass: String?
    public let classBlock: BlockClassType
    public let user: User?
    public let blockPosition: BlockPosition
    
    public struct BlockPosition {
        public let position: Int?
        public let selected: Bool?
        public let connectionId: Int?
        public let connectedAt: String?
        public let connectedByUserId: Int?
        public let connectedByUsername: String?
        public let connectedByUserSlug: String?
    }
}

/*
 "source": {
 "url": "https://vimeo.com/149553519",
 "title": "skincare on Vimeo",
 "provider": {
 "name": "Vimeo",
 "url": "https://vimeo.com/"
 }
 },
 */

extension BlockClassType: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockClassType> {
        switch json {
        case let .string(classBlock):
            return .success(BlockClassType(rawValue: classBlock) ?? .Unknown)
        default:
            return .failure(.typeMismatch(expected: "String", actual: json.description))
        }
    }
}

extension Block: Equatable {}
public func == (lhs: Block, rhs: Block) -> Bool {
    return lhs.id == rhs.id
}

extension Block: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Block> {
        let create = curry(Block.init)
            <^> json <| "id"
            <*> json <|? "title"
            <*> json <|? "updated_at"
            <*> json <|? "created_at"
            <*> json <|? "state"
        
        let tmp1 = create
            <*> json <|? "comment_count"
            <*> json <|? "generated_title"
            <*> json <|? "content_html"
            <*> json <|? "visibility"
            <*> json <|? "description_html"
            <*> json <|? "content"
        
        let tmp2 = tmp1
            <*> (json <|? "description" <|> .success(nil))
            <*> json <|? "source"
            <*> json <|? "image"
            <*> (json <|? "embed" <|> .success(nil))
            <*> (json <|? "attatchment" <|> .success(nil))
        
        return tmp2
            <*> json <|? "base_class"
            <*> json <| "class"
            <*> json <|? "user"
            <*> BlockPosition.decode(json)
    }
}

extension Block.BlockPosition: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<Block.BlockPosition> {
        let create = curry(Block.BlockPosition.init)
            <^> json <|? "position"
            <*> json <|? "selected"
            <*> json <|? "connection_id"
            <*> json <|? "connected_at"
        return create
            <*> json <|? "connected_by_user_id"
            <*> json <|? "connected_by_username"
            <*> json <|? "connected_by_user_slug"
    }
}

