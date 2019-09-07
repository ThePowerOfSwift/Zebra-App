//
//  ArenaServices.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Foundation
import Prelude
import ReactiveSwift

public extension Bundle {
    var _buildVersion: String {
        return (self.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }
}

public struct ArenaServices: ArenaServiceType {

    public let appId: String
    public let serverConfig: ServerConfigType
    public let clientToken: ClientAuthType
    public let language: String
    public let buildVersion: String
    
    public init(appId: String = Bundle.main.bundleIdentifier ?? "", serverConfig: ServerConfigType = ServerConfig.production, clientToken: ClientAuthType = ClientAuth.production, language: String = "en", buildVersion: String = Bundle.main._buildVersion) {
        self.appId = appId
        self.serverConfig = serverConfig
        self.clientToken = clientToken
        self.language = language
        self.buildVersion = buildVersion
    }
    
    public func getAllChannels(page: Int? = 1) -> SignalProducer<ListChannelsEnvelope, ErrorEnvelope> {
        return request(.channels(page: page))
    }
    
    public func getBlock(id: String) -> SignalProducer<BlockEnvelope, ErrorEnvelope> {
        return request(.block(id: id))
    }
    
    public func getCompleteChannel(slug: String, page: Int? = 1) -> SignalProducer<CompleteChannelEnvelope, ErrorEnvelope> {
        return request(.channelSlug(slug: slug, page: page))
    }
    
    public func getContentsChannel(slug: String, page: Int? = nil) -> SignalProducer<ContentsChannelEnvelope, ErrorEnvelope> {
        return request(.channelContents(id: slug, page: page))
    }
    
    public func getDiscoverChannels() -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope> {
        return request(.initialChannels)
    }
    
    public func getSearchChannels(term: String, page: Int?) -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope> {
        return request(.searchChannels(query: term, page: page))
    }
    
    public func getSearchBlocks(term: String, page: Int?) -> SignalProducer<SearchBlocksEnvelope, ErrorEnvelope> {
        return request(.searchBlocks(query: term, page: page))
    }
    
    public func getSearchUsers(term: String, page: Int?) -> SignalProducer<SearchUsersEnvelope, ErrorEnvelope> {
        return request(.searchUsers(query: term, page: page))
    }
    
    public func getUser(id: String) -> SignalProducer<UserEnvelope, ErrorEnvelope> {
        return request(.user(id: id))
    }
    
    public func getUserChannels(id: String) -> SignalProducer<UserChannelsEnvelope, ErrorEnvelope> {
        return request(.userChannels(id: id))
    }
    
    public func getUserFollowings(id: String) -> SignalProducer<UserFollowingsEnvelope, ErrorEnvelope> {
        return request(.userFollowing(id: id))
    }
    
    private func decodeModel<M: Argo.Decodable>(_ json: Any) -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
        return SignalProducer(value: json)
            .map { json in decode(json) as Decoded<M> }
            .flatMap(.concat) { (decoded: Decoded<M>) -> SignalProducer<M, ErrorEnvelope> in
                switch decoded {
                case let .success(value):
                    return .init(value: value)
                case let .failure(error):
                    print("Argo decoding Model: \(M.self) error: \(error)")
                    return .init(error: .couldNotDecodeJSON(error))
                }
        }
    }
    
    private func decodeModels<M: Argo.Decodable>(_ json: Any) -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {
        
        return SignalProducer(value: json)
            .map { json in decode(json) as Decoded<[M]>  }
            .flatMap(.concat) { (decoded: Decoded<[M]>) -> SignalProducer<[M], ErrorEnvelope> in
                switch decoded {
                case let .success(value):
                    return .init(value: value)
                case let .failure(error):
                    print("Argo decoding model error: \(error)")
                    return .init(error: .couldNotDecodeJSON(error))
                }
        }
    }
    
    private static let session = URLSession(configuration: .default)
    
    // Fetch Function { }
    
    private func requestPagination<M: Argo.Decodable>(_ paginationUrl: String) -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
        guard let paginationUrl = URL(string: paginationUrl) else {
            return .init(error: .invalidPaginationUrl)
        }
        
        return ArenaServices.session.rac_JSONResponse(preparedRequest(forURL: paginationUrl)).flatMap(decodeModel)
    }
    
    private func request<M: Argo.Decodable>(_ route: Route) -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
        let properties = route.requestProperties
        
        guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
            fatalError("URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil")
        }
        
        return ArenaServices.session.rac_JSONResponse(preparedRequest(forURL: URL, method: properties.method, query: properties.query)).flatMap(decodeModel)
    }
    
    private func request<M: Argo.Decodable>(_ route: Route) -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {
        let properties = route.requestProperties
        
        let url = self.serverConfig.apiBaseUrl.appendingPathComponent(properties.path)
        
        return ArenaServices.session.rac_JSONResponse(preparedRequest(forURL: url)).flatMap(decodeModels)
    }

    private func request<M: Argo.Decodable>(_ route: Route) -> SignalProducer<M?, ErrorEnvelope> where M == M.DecodedType {
        let properties = route.requestProperties
        
        guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
            fatalError("\(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil")
        }
        
        
        return ArenaServices.session.rac_JSONResponse(preparedRequest(forURL: URL, method: properties.method, query: properties.query)).flatMap(decodeModel)
//        return ArenaServices.session
    }
    
    private func decodeModel<M: Argo.Decodable>(_ json: Any) -> SignalProducer<M?, ErrorEnvelope> where M == M.DecodedType {
        return SignalProducer(value: json).map { json in decode(json) as M? }
    }
}
