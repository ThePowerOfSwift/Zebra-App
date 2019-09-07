//
//  RealmSuiteLocal.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 24/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import RealmSwift

public class ChannelGroupFavorite: Object {
    let items = List<ChannelFavorite>()
}

public class ChannelFavorite: Object {
    dynamic var blocks: [BlockLocal] = []
}

final class IndividualFavorite: BaseModel {
    var items = List<BlockLocal>()
    
    static func find(rid: String, realm: Realm? = Realm.current) -> IndividualFavorite? {
        return realm?.objects(IndividualFavorite.self).filter("rid == '\(rid)'").first
    }
}

public final class BlockLocal: Object {
    @objc dynamic var rid: String?
    @objc dynamic var status = ""
    @objc dynamic var source: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var textData: String?
}

extension IndividualFavorite {
    private func fetchItemsBlock() {
        guard let identifier = self.identifier else { return }
        Realm.execute({ realm in
            if let obj = IndividualFavorite.find(withIdentifier: identifier) {
                realm.add(obj, update: true)
            }
        })
    }
}

class BaseModel: Object {
    @objc dynamic var identifier: String?
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    static func find(withIdentifier identifier: String) -> Self? {
        return Realm.current?.objects(self).filter("identifier = '\(identifier)'").first
    }
    
    @discardableResult
    static func delete(withIdentifier identifier: String) -> Bool {
        guard
            let realm = Realm.current,
            let object = realm.objects(self).filter("identifier = '\(identifier)'").first
            else {
                return false
        }
        
        realm.delete(object)
        
        return true
    }
}
