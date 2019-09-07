import Foundation

public enum Trip2ZeroBundleIdentifier: String {
    case beta = "firasrafislam.Suiteboard.Suiteboard.beta"
    case release = "firasrafislam.Suiteboard"
}

public protocol NSBundleType {
    var bundleIdentifier: String? { get }
    static func create(path: String) -> NSBundleType?
    func path(forResource name: String?, ofType ext: String?) -> String?
    func localizedString(forKey key: String, value: String?, table tableName: String?) -> String
    var infoDictionary: [String: Any]? { get }
}

extension NSBundleType {
    public var identifier: String {
        return self.infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
    }
    
    public var shortVersionString: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    public var version: String {
        return self.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    public var buildNumber: String {
        return self.infoDictionary?[String(kCFBundleVersionKey)] as? String ?? "Unknown"
    }
    
    public var isBeta: Bool {
        return self.identifier == Trip2ZeroBundleIdentifier.beta.rawValue
    }
    
    public var isRelease: Bool {
        return self.identifier == Trip2ZeroBundleIdentifier.release.rawValue
    }
    
    public static func create(path: String) -> Bundle? {
        return Bundle(path: path)
    }
}

extension Bundle: NSBundleType {
    public static func create(path: String) -> NSBundleType? {
        return Bundle(path: path)
    }
}
