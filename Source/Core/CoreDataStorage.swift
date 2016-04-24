//
//  CoreDataStorage.swift
//  DTModelStorageTests
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

private struct DTFetchedResultsSectionInfoWrapper : Section
{
    let fetchedObjects : [AnyObject]
    let numberOfItems: Int
    
    var items : [Any] {
        return fetchedObjects.map { $0 }
    }
}

/// This class represents model storage in CoreData
/// It uses NSFetchedResultsController to monitor all changes in CoreData and automatically notify delegate of any changes
public class CoreDataStorage : BaseStorage, StorageProtocol, SupplementaryStorageProtocol, NSFetchedResultsControllerDelegate
{
    /// Fetched results controller of storage
    public let fetchedResultsController : NSFetchedResultsController
    
    /// Initialize CoreDataStorage with NSFetchedResultsController
    /// - Parameter fetchedResultsController: fetch results controller
    public init(fetchedResultsController: NSFetchedResultsController)
    {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    /// Sections of fetched results controller as required by StorageProtocol
    /// - SeeAlso: `StorageProtocol`
    /// - SeeAlso: `MemoryStorage`
    public var sections : [Section]
    {
        if let sections = self.fetchedResultsController.sections
        {
            return sections.map { DTFetchedResultsSectionInfoWrapper(fetchedObjects: $0.objects!, numberOfItems: $0.numberOfObjects) }
        }
        return []
    }
    
    // MARK: - StorageProtocol
    
    /// Retrieve object at index path from `CoreDataStorage`
    /// - Parameter path: NSIndexPath for object
    /// - Returns: model at indexPath or nil, if item not found
    public func itemAtIndexPath(path: NSIndexPath) -> Any? {
        return fetchedResultsController.objectAtIndexPath(path)
    }
    
    // MARK: - SupplementaryStorageProtocol
    
    /// Retrieve supplementary model of specific kind for section.
    /// - Parameter kind: kind of supplementary model
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    public func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any?
    {
        if kind == self.supplementaryHeaderKind
        {
            if let sections = self.fetchedResultsController.sections
            {
                return sections[sectionIndex].name
            }
            return nil
        }
        return nil
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// NSFetchedResultsController is about to start changing content - we'll start monitoring for updates.
    @objc public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.startUpdate()
    }
    
    /// React to specific change in NSFetchedResultsController
    @objc public func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        switch type
        {
        case .Insert:
            if newIndexPath != nil { self.currentUpdate?.insertedRowIndexPaths.insert(newIndexPath!) }
        case .Delete:
            if indexPath != nil { self.currentUpdate?.deletedRowIndexPaths.insert(indexPath!) }
        case .Move:
            if indexPath != nil && newIndexPath != nil {
                if indexPath != newIndexPath {
                    self.currentUpdate?.movedRowIndexPaths.append([indexPath!,newIndexPath!])
                }
                else {
                    self.currentUpdate?.updatedRowIndexPaths.insert(indexPath!)
                }
            }
        case .Update:
            if indexPath != nil { self.currentUpdate?.updatedRowIndexPaths.insert(indexPath!) }
        }
    }
    
    /// React to changed section in NSFetchedResultsController
    @objc
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    { switch type
    {
    case .Insert:
        self.currentUpdate?.insertedSectionIndexes.insert(sectionIndex)
    case .Delete:
        self.currentUpdate?.deletedSectionIndexes.insert(sectionIndex)
    case .Update:
        self.currentUpdate?.updatedSectionIndexes.insert(sectionIndex)
    default: ()
        }
    }
    
    /// Finish update from NSFetchedResultsController
    @objc
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.finishUpdate()
    }
}