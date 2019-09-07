//
//  ASMediaLibrary.swift
//  Suiteboard
//
//  Created by Firas Rafislam on 25/03/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import CoreData
import Foundation

public class ASMediaLibrary: NSObject {
    
    
    public static func managedObjectContext() -> NSManagedObjectContext {

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managingObjectModel())
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        managedObjectContext.undoManager = nil
        
        return managedObjectContext
    }
    
    private static func managingObjectModel() -> NSManagedObjectModel {
        let path = Bundle(for: ASMediaLibrary.self).path(forResource: "AssetLibrary", ofType: "momd")!
        let momURL = URL(fileURLWithPath: path)
        let managedObjectModel = NSManagedObjectModel(contentsOf: momURL)!
        return managedObjectModel
    }
}
