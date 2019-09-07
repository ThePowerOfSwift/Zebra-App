import UIKit

public struct Rac<Object: RacObject> {
    public let object: Object
}

public protocol RacObject {}


public extension RacObject {
    typealias Object = Self
    
    var rac: Rac<Object> {
        return Rac(object: self)
    }
}

extension NSObject: RacObject {}
