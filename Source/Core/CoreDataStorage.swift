//
//  CoreDataStorage.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CoreData
import UIKit

/// Private wrapper around `NSFetchedResultsSectionInfo` to conform to `Section` protocol
private struct DTFetchedResultsSectionInfoWrapper: Section
{
    let fetchedObjects: [AnyObject]
    let numberOfItems: Int
    
    var items : [Any] {
        return fetchedObjects.map { $0 }
    }
}

/// This class represents model storage in CoreData
/// It uses NSFetchedResultsController to monitor all changes in CoreData and automatically notify delegate of any changes
open class CoreDataStorage<T: NSFetchRequestResult> : BaseStorage, Storage, SupplementaryStorage, NSFetchedResultsControllerDelegate
{
    /// Fetched results controller of storage
    open let fetchedResultsController: NSFetchedResultsController<T>
    
    /// Property, which defines, for which supplementary kinds NSFetchedResultsController section name should be used.
    /// Defaults to [DTTableViewElementSectionHeader,UICollectionElementKindSectionHeader]
    /// - Discussion: This is useful, for example, if you want section footers intead of headers to have section name in them.
    open var displaySectionNameForSupplementaryKinds = [DTTableViewElementSectionHeader, UICollectionElementKindSectionHeader]
    
    /// Initialize CoreDataStorage with NSFetchedResultsController
    /// - Parameter fetchedResultsController: fetch results controller
    public init(fetchedResultsController: NSFetchedResultsController<T>)
    {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    /// Sections of fetched results controller as required by Storage
    /// - SeeAlso: `Storage`
    /// - SeeAlso: `MemoryStorage`
    open var sections: [Section]
    {
        if let sections = self.fetchedResultsController.sections
        {
            return sections.map { DTFetchedResultsSectionInfoWrapper(fetchedObjects: $0.objects as [AnyObject]? ?? [], numberOfItems: $0.numberOfObjects) }
        }
        return []
    }
    
    // MARK: - Storage
    
    /// Retrieve object at index path from `CoreDataStorage`
    /// - Parameter indexPath: IndexPath for object
    /// - Returns: model at indexPath or nil, if item not found
    open func item(at indexPath: IndexPath) -> Any? {
        return fetchedResultsController.object(at: indexPath)
    }
    
    // MARK: - SupplementaryStorage
    
    /// Retrieve supplementary model of specific kind for section.
    /// - Parameter kind: kind of supplementary model
    /// - Parameter sectionIndexPath: index of section
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModel(ofKind kind: String, forSectionAt sectionIndexPath: IndexPath) -> Any?
    {
        if displaySectionNameForSupplementaryKinds.contains(kind)
        {
            if let sections = self.fetchedResultsController.sections
            {
                return sections[sectionIndexPath.section].name
            }
            return nil
        }
        return nil
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// NSFetchedResultsController is about to start changing content - we'll start monitoring for updates.
    @objc open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.startUpdate()
    }
    
    /// React to specific change in NSFetchedResultsController
    @objc open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            if let new = newIndexPath {
                currentUpdate?.objectChanges.append((.insert, [new]))
            }
        case .delete:
            if let indexPath = indexPath {
                currentUpdate?.objectChanges.append((.delete, [indexPath]))
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                if indexPath != newIndexPath {
                    currentUpdate?.objectChanges.append((.delete, [indexPath]))
                    currentUpdate?.objectChanges.append((.insert, [newIndexPath]))
                } else {
                    currentUpdate?.objectChanges.append((.update, [indexPath]))
                    currentUpdate?.updatedObjects[indexPath] = anObject
                }
            }
        case .update:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath, indexPath != newIndexPath {
                    currentUpdate?.objectChanges.append((.delete,[indexPath]))
                    currentUpdate?.objectChanges.append((.insert,[newIndexPath]))
                }
                else {
                    currentUpdate?.objectChanges.append((.update,[indexPath]))
                    currentUpdate?.updatedObjects[indexPath] = anObject
                }
            }
        }
    }
    
    /// React to changed section in NSFetchedResultsController.    
    @objc
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    { switch type
    {
    case .insert:
        currentUpdate?.sectionChanges.append((.insert, [sectionIndex]))
    case .delete:
        currentUpdate?.sectionChanges.append((.delete, [sectionIndex]))
    case .update:
        currentUpdate?.sectionChanges.append((.update, [sectionIndex]))
    default: ()
        }
    }
    
    /// Finish update from NSFetchedResultsController
    @objc
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.finishUpdate()
    }
}
