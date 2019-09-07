//
//  ArenaServicesType.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import Prelude
import ReactiveSwift

public protocol ArenaServiceType {
    var appId: String { get }
    var serverConfig: ServerConfigType { get }
    var clientToken: ClientAuthType { get }
    var language: String { get }
    var buildVersion: String { get }
    
    init(appId: String, serverConfig: ServerConfigType, clientToken: ClientAuthType, language: String, buildVersion: String)
    
    func getAllChannels(page: Int?) -> SignalProducer<ListChannelsEnvelope, ErrorEnvelope>
    
    func getBlock(id: String) -> SignalProducer<BlockEnvelope, ErrorEnvelope>
    
    func getCompleteChannel(slug: String, page: Int?) -> SignalProducer<CompleteChannelEnvelope, ErrorEnvelope>
    
    func getContentsChannel(slug: String, page: Int?) -> SignalProducer<ContentsChannelEnvelope, ErrorEnvelope>
    
    func getDiscoverChannels() -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope>
    
    func getSearchChannels(term: String, page: Int?) -> SignalProducer<SearchChannelsEnvelope, ErrorEnvelope>
    func getSearchBlocks(term: String, page: Int?) -> SignalProducer<SearchBlocksEnvelope, ErrorEnvelope>
    func getSearchUsers(term: String, page: Int?) -> SignalProducer<SearchUsersEnvelope, ErrorEnvelope>
    
    func getUser(id: String) -> SignalProducer<UserEnvelope, ErrorEnvelope>
    
    func getUserChannels(id: String) -> SignalProducer<UserChannelsEnvelope, ErrorEnvelope>
    
    func getUserFollowings(id: String) -> SignalProducer<UserFollowingsEnvelope, ErrorEnvelope>
    
}




public func == (lhs: ArenaServiceType, rhs: ArenaServiceType) -> Bool {
    return type(of: lhs) == type(of: rhs) &&
        lhs.serverConfig == rhs.serverConfig &&
        lhs.clientToken == rhs.clientToken &&
        lhs.language == rhs.language &&
        lhs.buildVersion == rhs.buildVersion
}

public func != (lhs: ArenaServiceType, rhs: ArenaServiceType) -> Bool {
    return !(lhs == rhs)
}

extension ArenaServiceType {
    
    public func preparedRequest(forRequest originalRequest: URLRequest, query: [String: Any] = [:]) -> URLRequest {
        
        var request = originalRequest
        guard let URL = request.url else {
            return originalRequest
        }
        
        var headers = self.defaultHeaders
        
        let method = request.httpMethod?.uppercased()
        var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        
        if method == .some("POST") || method == .some("PUT") {
            if request.httpBody == nil {
                headers["Content-Type"] = "application/json; charset=utf-8"
                request.httpBody = try? JSONSerialization.data(withJSONObject: query, options: [])
            }
        } else {
            queryItems.append(
                contentsOf: query
                    .flatMap(queryComponents)
                    .map(URLQueryItem.init(name:value:))
            )
        }
        components.queryItems = queryItems.sorted { $0.name < $1.name }
        request.url = components.url
        
        let currentHeaders = request.allHTTPHeaderFields ?? [:]
        request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(headers)
        
        return request
        
    }
    
    public func preparedRequest(forURL url: URL, method: Method = .GET, query: [String: Any] = [:]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return self.preparedRequest(forRequest: request, query: query)
    }
    
    public func preparedRequest(forRequest originalRequest: URLRequest, queryString: String) -> URLRequest {
        
        var request = originalRequest
        guard let URL = request.url else {
            return originalRequest
        }
        
        request.httpBody = "query=\(queryString)".data(using: .utf8)
        
        let components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
        request.url = components.url
        request.allHTTPHeaderFields = self.defaultHeaders
        
        return request
    }
    
    public func preparedRequest(forURL url: URL, querystring: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = Method.POST.rawValue
        return self.preparedRequest(forURL: url, querystring: querystring)
    }
    
    public func isPrepared(request: URLRequest) -> Bool {
        return request.value(forHTTPHeaderField: "Authorization") == authorizationHeader
            && request.value(forHTTPHeaderField: "Suite-iOS-App") != nil
    }
    
    fileprivate var defaultHeaders: [String: String] {
        var headers: [String: String] = [:]
        
        let executable = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
        let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        let app: String = executable ?? bundleIdentifier ?? "Suite"
        let bundleVersion: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let scale = UIScreen.main.scale
        
        headers["User-Agent"] = "\(app)/\(bundleVersion) (\(model); iOS \(systemVersion) Scale/\(scale))"
        
        return headers
    }
    
    fileprivate var authorizationHeader: String? {
        if let token = self.authorizationHeader {
            return "clientId \(token)"
        } else {
            return self.serverConfig.basicHTTPAuth?.authorizationHeader
        }
    }
    
    fileprivate func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((key, String(describing: value)))
        }
        
        return components
    }
}
