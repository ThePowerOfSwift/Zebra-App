//
//  Routes.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 28/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Prelude

internal enum Route {
    case requestAuthorization
    case requestAccessToken
    // CHANNELS
    case channels(page: Int?)
    case channelSlug(slug: String, page: Int?)
    case channelConnection(id: String)
    case channelContents(id: String, page: Int?)
    case postChannels(title: String, status: String?)
    case putChannels(slug: String, title: String?, status: String?)
    case putSortChannels(slug: String, ids: [String])
    case deleteChannels(slug: String)
    case postChannelsBlocks(slug: String, source: String, content: String)
    case putSelectionChannels(channelId: String, id: String)
    case collaboratorsChannels(id: String)
    case postCollaboratorsChannels(id: String)
    case deleteCollaboratorsChannels(id: String)
    // BLOCKS
    case block(id: String)
    case channelsBlocks(id: String)
    case postChannelsSlugBlocks(id: String, source: String, content: String)
    case putBlocks(id: String, title: String?, description: String?, content: String?)
    case putChannelsBlocksSelection(channelId: String, id: String)
    case deleteChannelBlocks(channelId: String, id: String)
    // SEARCH
    case search(query: String)
    case searchUsers(query: String, page: Int?)
    case initialChannels
    case searchChannels(query: String, page: Int?)
    case searchBlocks(query: String, page: Int?)
    // User
    case user(id: String)
    case userChannels(id: String)
    case userFollowing(id: String)
    case userFollowers(id: String)
    
    enum UploadParam: String {
        case image
        case video
    }
    
    internal var requestProperties: (method: Method, path: String, query: [String: Any], file: (name: UploadParam, url: URL)?) {
        
        switch self {
        case .requestAuthorization:
            return (.GET, "/oauth/authorize", [:], nil)
        case .requestAccessToken:
            return (.GET, "/oauth/token", [:], nil)
        case let .channels(page):
            var params: [String: Any] = ["sort": "position", "direction": "desc"]
            params["page"] = page
            return (.GET, "/v2/channels", params, nil)
        case let .channelSlug(slug, page):
            var params: [String: Any] = ["sort": "position", "direction": "desc"]
            params["page"] = page
            return (.GET, "/v2/channels/\(slug)", params, nil)
        case let .channelConnection(id):
            return (.GET, "/v2/channels/\(id)/connections", [:], nil)
        case let .channelContents(id, page):
            var params: [String: Any] = ["sort": "position", "direction": "desc"]
            params["page"] = page
            return (.GET, "/v2/channels/\(id)/contents", params, nil)
        case let .postChannels(title, status):
            return (.POST, "/v2/channels", ["title": title, "status": status ?? ""], nil)
        case let .putChannels(slug, title, status):
            return (.PUT, "/v2/channels/\(slug)/", ["title": title ?? "", "status": status ?? ""], nil)
        case let .putSortChannels(slug, ids):
            return (.PUT, "/v2/channels/\(slug)/sort", ["ids": ids], nil)
        case let .deleteChannels(slug):
            return (.DELETE, "/v2/channels/\(slug)", [:], nil)
        case let .postChannelsBlocks(slug, source, content):
            return (.POST, "/v2/channels/\(slug)/blocks", ["source": source, "content": content], nil)
        case let .putSelectionChannels(channelId, id):
            return (.PUT, "/v2/channels/\(channelId)/blocks/\(id)/selection", [:], nil)
        case let .collaboratorsChannels(id):
            return (.GET, "/v2/channels/\(id)/collaborators", [:], nil)
        case let .postCollaboratorsChannels(id):
            return (.POST, "/v2/channels/\(id)/collaboratros", [:], nil)
        case let .deleteCollaboratorsChannels(id):
            return (.DELETE, "/v2/channels/\(id)/collaborators", [:], nil)
        // Blocks
        case let .block(id):
            return (.GET, "/v2/blocks/\(id)", [:], nil)
        case let .channelsBlocks(id):
            return (.GET, "/v2/blocks/\(id)/channels", [:], nil)
        case let .postChannelsSlugBlocks(slug, source, content):
            return (.POST, "/v2/channels/\(slug)/blocks", ["source": source, "content": content], nil)
        case let .putBlocks(id, title, description, content):
            return (.PUT, "/v2/blocks/\(id)", ["title": title ?? "", "description": description ?? "", "content": content ?? ""], nil)
        case let .putChannelsBlocksSelection(channelId, id):
            return (.PUT, "/v2/channels/\(channelId)/blocks/\(id)/selection", [:], nil)
        case let .deleteChannelBlocks(channelId, id):
            return (.DELETE, "/v2/channel/\(channelId)/blocks/\(id)", [:], nil)
        // Search
        case let .search(query):
            return (.GET, "/v2/search", ["q": query], nil)
        case let .searchUsers(query, page):
            return (.GET, "/v2/search/users", ["q": query, "page": page ?? 1], nil)
        case .initialChannels:
            return (.GET, "/v2/search/channels?page=1&q=", [:], nil)
        case let .searchChannels(query, page):
            return (.GET, "/v2/search/channels", ["q": query, "page": page ?? 1], nil)
        case let .searchBlocks(query, page):
            return (.GET, "/v2/search/blocks", ["q": query, "page": page ?? 1], nil)
        // User
        case let .user(id):
            return (.GET, "/v2/users/\(id)", [:], nil)
        case let .userChannels(id):
            return (.GET, "/v2/users/\(id)/channels", ["access_token":Secrets.Api.Client.accessToken], nil)
        case let .userFollowing(id):
            return (.GET, "/v2/users/\(id)/following", ["access_token":Secrets.Api.Client.accessToken], nil)
        case let .userFollowers(id):
            return (.GET, "/v2/users/\(id)/followers", [:], nil)
        }
    }
}
