//
//  ErrorEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 31/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Argo
import Curry
import Runes

public struct ErrorEnvelope {
    public let errorMessages: [String]
    public let httpCode: Int
    
    
    public enum SuiteCode: String {
        // Codes defined by the server
        case AccessTokenInvalid = "access_token_invalid"
        
        case UnknownCode = "__internal_unknown_code"
        
        // Codes defined by the client
        case JSONParsingFailed = "json_parsing_failed"
        case ErrorEnvelopeJSONParsingFailed = "error_json_parsing_failed"
        case DecodingJSONFailed = "decoding_json_failed"
        case InvalidPaginationUrl = "invalid_pagination_url"
    }
    
    public struct Exception {
        public let backtrace: [String]?
        public let message: String?
    }
    
    internal static let couldNotParseJSON = ErrorEnvelope(errorMessages: [], httpCode: 400)
    
    internal static let couldNotParseErrorEnvelopeJSON = ErrorEnvelope(errorMessages: [], httpCode: 400)
    
    internal static func couldNotDecodeJSON(_ decodeError: DecodeError) -> ErrorEnvelope {
        return ErrorEnvelope(errorMessages: ["Argo decoding error: \(decodeError.description)"], httpCode: 400)
    }
    
    internal static let invalidPaginationUrl = ErrorEnvelope(errorMessages: [], httpCode: 400)
    
    
}

extension ErrorEnvelope: Error {}

extension ErrorEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<ErrorEnvelope> {
        return curry(ErrorEnvelope.init)
            <^> json <|| "errorMessages"
            <*> json <| "http_code"
    }
}
