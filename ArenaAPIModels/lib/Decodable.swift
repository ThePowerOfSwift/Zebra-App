import Argo

public extension Argo.Decodable {
    
    static func decodeJSONDictionary(_ json: [String: Any]) -> Decoded<DecodedType> {
        return Self.decode(JSON(json))
    }
}
