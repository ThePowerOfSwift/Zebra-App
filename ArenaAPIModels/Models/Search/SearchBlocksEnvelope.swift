//
//  SearchBlocksEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 12/04/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct ListBlock {
    public let id: String
    public let title: String?
    public let updatedAt: String
    public let createdAt: String
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
    //    public let embed: String?
    //    public let attachment: String?
    
    public let baseClass: String
    public let classBlock: BlockClassType
    public let user: User
}

extension ListBlock: Equatable {}
public func == (lhs: ListBlock, rhs: ListBlock) -> Bool {
    return lhs.id == rhs.id
}

extension ListBlock: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ListBlock> {
        let create = curry(ListBlock.init)
            <^> json <| "id"
            <*> json <|? "title"
            <*> json <| "updated_at"
            <*> json <| "created_at"
            <*> json <|? "state"
        
        let tmp1 = create
            <*> json <|? "comment_count"
            <*> json <|? "generated_title"
            <*> json <|? "content_html"
            <*> json <|? "visibility"
            <*> json <|? "description_html"
            <*> json <|? "content"
        
        let tmp2 = tmp1
            <*> json <|? "description"
            <*> json <|? "source"
            <*> json <|? "image"
        //            <*> json <|? "embed"
        //            <*> json <|? "attatchment"
        
        return tmp2
            <*> json <| "base_class"
            <*> json <| "class"
            <*> json <| "user"
    }
}

public struct SearchBlocksEnvelope {
    public let term: String
    public let per: Int
    public let currentPage: Int
    public let totalPages: Int
    public let length: Int
    public let authenticated: Bool
    public let blocks: [ListBlock]
}

extension SearchBlocksEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<SearchBlocksEnvelope> {
        let create = curry(SearchBlocksEnvelope.init)
            <^> json <| "term"
            <*> json <| "per"
            <*> json <| "current_page"
        return create
            <*> json <| "total_pages"
            <*> json <| "length"
            <*> json <| "authenticated"
            <*> json <|| "blocks"
    }
}
