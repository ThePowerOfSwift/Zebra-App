//
//  RealmExecute.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 28/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation
import RealmSwift

public typealias VoidCompletion = () -> Void

extension Realm {
    static let writeQueue = DispatchQueue(label: "suite.zebra.realm.write", qos: .background)
    
    func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        var backgroundTaskId: UIBackgroundTaskIdentifier?
        
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "suite.zebra.realm.background") {
            backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }
        
        if let backgroundTaskId = backgroundTaskId {
            let config = self.configuration
            
            Realm.writeQueue.async {
                if let realm = try? Realm(configuration: config) {
                    try? realm.write {
                        execution(realm)
                    }
                }
                
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
        }
    }
    
    static func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        Realm.current?.execute(execution, completion: completion)
    }
}
