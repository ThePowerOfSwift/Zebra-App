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

/* Embed
 
 {"url":null,"type":"rich","title":null,"author_name":"blabacphoto","author_url":"https://www.instagram.com/blabacphoto","source_url":null,"thumbnail_url":null,"width":658,"height":882,"html":"<iframe class=\"instagram-media instagram-media-rendered\" id=\"instagram-embed-0\" src=\"https://www.instagram.com/p/Bw2-MGGgonL/embed/?cr=1&rd=https%3A%2F%2Fwww.instagram.com\" height=\"882\" width=\"658\" frameborder=\"0\" allowfullscreen=\"true\" allowtransparency=\"true\" data-instgrm-payload-id=\"instagram-media-payload-0\" scrolling=\"no\" style=\"background: white; max-width: 658px; width: calc(100% - 2px); border-radius: 3px; border: 1px solid rgb(219, 219, 219); box-shadow: none; display: block; margin: 0px 0px 12px; min-width: 326px; padding: 0px;\"></iframe>"
*/


public struct BlockEnvelope {
    public let id: Int
    public let title: String?
    public let updatedAt: String
    public let createdAt: String
    public let state: String
    public let commentCount: Int
    public let generatedTitle: String
    public let contentHtml: String?
    public let descriptionHtml: String?
    public let visibility: String
    public let content: String?
//    public let description: String
    public let source: BlockSource?
    public let image: BlockImage?
//    public let embed: String?
    public let attachment: String?
    public let baseClass: String
    public let classBlock: String
    public let user: User
    public let connections: [Connection]
}

extension BlockEnvelope: Equatable {}
public func == (lhs: BlockEnvelope, rhs: BlockEnvelope) -> Bool {
    return lhs.id == rhs.id
}

extension BlockEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockEnvelope> {
        let create = curry(BlockEnvelope.init)
            <^> json <| "id"
            <*> json <|? "title"
            <*> json <| "updated_at"
            <*> json <| "created_at"
            <*> json <| "state"
        
        let tmp1 = create
            <*> json <| "comment_count"
            <*> json <| "generated_title"
            <*> json <|? "content_html"
            <*> json <|? "description_html"
            <*> json <| "visibility"
            <*> json <|? "content"
        
        let tmp2 = tmp1
            <*> json <|? "source"
            <*> json <|? "image"
//            <*> json <|? "embed"
            <*> json <|? "attatchment"
        
        return tmp2
            <*> json <| "base_class"
            <*> json <| "class"
            <*> json <| "user"
            <*> json <|| "connections"
    }
}

public struct BlockImage {
    public let filename: String
    public let contentType: String
    public let updatedAt: String
    public let thumb: TypeUrl
    public let square: TypeUrl
    public let display: TypeUrl
    public let large: TypeUrl
    public let origin: TypeUrl
    
    public struct TypeUrl {
        public let url: String
        public let fileSize: Double?
        public let fileSizeDisplay: String?
    }
}

extension BlockImage: Equatable {}
public func == (lhs: BlockImage, rhs: BlockImage) -> Bool {
    return lhs.filename == rhs.filename
}

extension BlockImage: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockImage> {
        let create = curry(BlockImage.init)
            <^> json <| "filename"
            <*> json <| "content_type"
            <*> json <| "updated_at"
        return create
            <*> json <| "thumb"
            <*> json <| "square"
            <*> json <| "display"
            <*> json <| "large"
            <*> json <| "original"
    }
}


extension BlockImage.TypeUrl: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockImage.TypeUrl> {
        return curry(BlockImage.TypeUrl.init)
            <^> json <| "url"
            <*> json <|? "file_size"
            <*> json <|? "file_size_display"
    }
}

/*
"image": {
    "filename": "4649ae3949ca1d4f74209e39cdc426e5.gif",
    "content_type": "image/gif",
    "updated_at": "2019-03-29T00:55:32.222Z",
    "thumb": {
        "url": "https://d2w9rnfcy7mm78.cloudfront.net/3960443/original_4649ae3949ca1d4f74209e39cdc426e5.gif?1553820932"
    },
    "square": {
        "url": "https://d2w9rnfcy7mm78.cloudfront.net/3960443/original_4649ae3949ca1d4f74209e39cdc426e5.gif?1553820932"
    },
    "display": {
        "url": "https://d2w9rnfcy7mm78.cloudfront.net/3960443/original_4649ae3949ca1d4f74209e39cdc426e5.gif?1553820932"
    },
    "large": {
        "url": "https://d2w9rnfcy7mm78.cloudfront.net/3960443/original_4649ae3949ca1d4f74209e39cdc426e5.gif?1553820932"
    },
    "original": {
        "url": "https://d2w9rnfcy7mm78.cloudfront.net/3960443/original_4649ae3949ca1d4f74209e39cdc426e5.gif?1553820932",
        "file_size": 58484,
        "file_size_display": "57.1 KB"
    }
},
*/

public struct BlockSource {
    public let url: String
    public let title: String?
    public let provider: Provider
    
    public struct Provider {
        public let name: String?
        public let url: String?
    }
}

extension BlockSource: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockSource> {
        return curry(BlockSource.init)
            <^> json <| "url"
            <*> json <|? "title"
            <*> json <| "provider"
    }
}

extension BlockSource.Provider: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockSource.Provider> {
        return curry(BlockSource.Provider.init)
            <^> json <|? "name"
            <*> json <|? "url"
    }
}

public struct BlockEmbed {
    public let url: String
    public let type: String
    public let title: String
    public let sourceUrl: String
    public let thumbnailUrl: String
}

extension BlockEmbed: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockEmbed> {
        return curry(BlockEmbed.init)
            <^> json <| "url"
            <*> json <| "type"
            <*> json <| "title"
            <*> json <| "source_url"
            <*> json <| "thumbnail_url"
    }
}

public struct BlockAttachment {
    public let fileName: String
    public let contentType: String
    public let extensionType: String
    public let url: String
}

extension BlockAttachment: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<BlockAttachment> {
        return curry(BlockAttachment.init)
            <^> json <| "file_name"
            <*> json <| "content_type"
            <*> json <| "extension"
            <*> json <| "url"
    }
}



/*
 "embed":{"url":"http://www.youtube.com/watch?v=14dOICbwSIs","type":"video","title":"Hitchcock's Definition of Happiness","author_name":"bg365247","author_url":"http://www.youtube.com/user/bg365247","source_url":"http://www.youtube.com/watch?v=14dOICbwSIs","thumbnail_url":"http://i2.ytimg.com/vi/14dOICbwSIs/hqdefault.jpg","width":600,"height":338,"html":"<iframe width=\"600\" height=\"338\" src=\"https://www.youtube.com/embed/14dOICbwSIs?wmode=transparent&fs=1&feature=oembed\" frameborder=\"0\" allowfullscreen></iframe>"}
 */

/*
 "attachment":{"file_name":"90433895ccddd2412c9ffa6194d8f60f.pdf","file_size":225044,"file_size_display":"220 KB","content_type":"application/pdf","extension":"pdf","url":"https://arena-attachments.s3.amazonaws.com/2493634/90433895ccddd2412c9ffa6194d8f60f.pdf?1532972317"}
 */
