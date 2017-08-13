//
//  CoreDataManager.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    fileprivate let managedObjectModel : NSManagedObjectModel = {
        let modelURL = Bundle(for:CoreDataManager.self).url(forResource:"DTModelStorageDatabase", withExtension: "momd")
        #if swift(>=3.2)
            return NSManagedObjectModel(contentsOf: modelURL!)
        #else
            return NSManagedObjectModel(contentsOf: modelURL!)!
        #endif
    }()
    
    fileprivate lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        return coordinator
    }()
    
    lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    func deleteAllObjects() {
        for entity in managedObjectModel.entities {
            let request = NSFetchRequest<NSManagedObject>()
            request.entity = entity
            request.includesPropertyValues = false
            request.includesSubentities = false
            
            if let items = try? context.fetch(request) {
                for object in items {
                    context.delete(object)
                }
            }
            
            let _ = try? context.save()
        }
    }
    
    fileprivate init() {}
}
