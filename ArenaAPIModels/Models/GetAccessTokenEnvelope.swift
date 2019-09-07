//
//  GetAccessTokenEnvelope.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 30/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

/*
{
    "access_token": "ACCESS_TOKEN",
    "token_type": "bearer",
    "expires_in": null
}
 */

import Argo
import Curry
import Runes

public struct GetAccessTokenEnvelope {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: String?
}


extension GetAccessTokenEnvelope: Argo.Decodable {
    public static func decode(_ json: JSON) -> Decoded<GetAccessTokenEnvelope> {
        return curry(GetAccessTokenEnvelope.init)
            <^> json <| "access_token"
            <*> json <| "token_type"
            <*> json <|? "expires_in"
    }
}


