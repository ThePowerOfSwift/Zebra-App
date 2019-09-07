
import Foundation

public protocol ServerConfigType {
    var apiBaseUrl: URL { get }
    var webBaseUrl: URL { get }
    var apiClientAuth: ClientAuthType { get }
    var basicHTTPAuth: BasicHTTPAuthType? { get }
    var graphQLEndpointUrl: URL? { get }
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
    return type(of: lhs) == type(of: rhs) &&
            lhs.apiBaseUrl == rhs.apiBaseUrl &&
            lhs.webBaseUrl == rhs.webBaseUrl &&
            lhs.apiClientAuth == rhs.apiClientAuth &&
            lhs.basicHTTPAuth == rhs.basicHTTPAuth &&
            lhs.graphQLEndpointUrl == rhs.graphQLEndpointUrl
}

private let gqlPath = "graph"

public struct ServerConfig: ServerConfigType {
    
    public fileprivate(set) var apiBaseUrl: URL
    public fileprivate(set) var webBaseUrl: URL
    public fileprivate(set) var apiClientAuth: ClientAuthType
    public fileprivate(set) var basicHTTPAuth: BasicHTTPAuthType?
    public fileprivate(set) var graphQLEndpointUrl: URL?
    
    public static let production: ServerConfigType = ServerConfig(apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.queryEndpoint)")!, webBaseUrl: URL(string: "https://\(Secrets.Api.WebEndpoint.webBase)")!, apiClientAuth: ClientAuth.production, basicHTTPAuth: nil, graphQLEndpointUrl: nil)
    
    public init(apiBaseUrl: URL, webBaseUrl: URL, apiClientAuth: ClientAuthType, basicHTTPAuth: BasicHTTPAuthType?, graphQLEndpointUrl: URL?) {
        self.apiBaseUrl = apiBaseUrl
        self.webBaseUrl = webBaseUrl
        self.apiClientAuth = apiClientAuth
        self.basicHTTPAuth = basicHTTPAuth
        self.graphQLEndpointUrl = graphQLEndpointUrl
    }
}
