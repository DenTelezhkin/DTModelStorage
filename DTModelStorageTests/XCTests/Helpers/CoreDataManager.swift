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
    
    private let managedObjectModel : NSManagedObjectModel = {
        let modelURL = NSBundle(forClass:CoreDataManager.self).URLForResource("DTModelStorageDatabase", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()
    
    private lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        try! coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        return coordinator
    }()
    
    lazy var context : NSManagedObjectContext = {
        let context = NSManagedObjectContext()
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    func deleteAllObjects() {
        for entity in managedObjectModel.entities {
            let request = NSFetchRequest()
            request.entity = entity
            request.includesPropertyValues = false
            request.includesSubentities = false
            
            if let items = try? context.executeFetchRequest(request) {
                for object in items as! [NSManagedObject] {
                    context.deleteObject(object)
                }
            }
            
            let _ = try? context.save()
        }
    }
    
    private init() {}
}