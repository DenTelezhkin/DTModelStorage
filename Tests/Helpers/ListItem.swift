//
//  ListItem.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData


class ListItem: NSManagedObject {
    static func createItemWithValue(_ value: Int) -> ListItem {
        let context = CoreDataManager.sharedInstance.context
        
        let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into:context) as! ListItem
        item.value = value as NSNumber
        let _ = try? context.save()
        return item
    }
}
