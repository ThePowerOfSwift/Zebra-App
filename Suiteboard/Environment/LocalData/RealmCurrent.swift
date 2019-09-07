import Foundation
import RealmSwift

var realmConfiguration: Realm.Configuration?
let realmTestingConfiguration = Realm.Configuration(
    inMemoryIdentifier: "realm-testing-identifier",
    deleteRealmIfMigrationNeeded: true
)

extension Realm {
    
    #if TEST
    static var current: Realm? {
        return try? Realm(configuration: realmTestingConfiguration)
    }
    #endif
    
    #if !TEST
    static var current: Realm? {
            var configuration = Realm.Configuration(
                deleteRealmIfMigrationNeeded: true
            )
            print("CURRENT REALM OFFLINE MODE!")
            configuration.fileURL = configuration.fileURL!.deletingLastPathComponent().appendingPathComponent("suiteboard.realm")
            configuration.objectTypes = [BlockLocal.self, IndividualFavorite.self, ChannelFavorite.self, ChannelGroupFavorite.self]
            
            return try? Realm(configuration: configuration)
    }
    #endif
    
}
