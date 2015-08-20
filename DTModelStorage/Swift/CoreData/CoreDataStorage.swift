//
//  CoreDataStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData

private struct DTFetchedResultsSectionInfoWrapper : Section
{
    let fetchedObjects : [AnyObject]
    let numberOfObjects: Int
    
    var objects : [Any] {
        return fetchedObjects.map { $0 }
    }
}

public class CoreDataStorage : BaseStorage
{
    public let fetchedResultsController : NSFetchedResultsController
    private var currentUpdate : StorageUpdate?
    
    public init(fetchedResultsController: NSFetchedResultsController)
    {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func startUpdate()
    {
        self.currentUpdate = StorageUpdate()
    }
    
    func finishUpdate()
    {
        if self.currentUpdate != nil { self.delegate?.storageDidPerformUpdate(self.currentUpdate!) }
        self.currentUpdate = nil
    }
    
    public var sections : [Section]
    {
        if let sections = self.fetchedResultsController.sections
        {
            return sections.map { DTFetchedResultsSectionInfoWrapper(fetchedObjects: $0.objects!, numberOfObjects: $0.numberOfObjects) }
        }
        return []
    }
}

extension CoreDataStorage : StorageProtocol
{
    public func objectAtIndexPath(path: NSIndexPath) -> Any? {
        return fetchedResultsController.objectAtIndexPath(path)
    }
}

extension CoreDataStorage : HeaderFooterStorageProtocol
{
    public func headerModelForSectionIndex(index: Int) -> Any?
    {
        assert(self.supplementaryHeaderKind != nil, "Supplementary header kind must be set before retrieving header model for section index")
        
        if self.supplementaryHeaderKind == nil { return nil }
        
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
    
    public func footerModelForSectionIndex(index: Int) -> Any?
    {
        assert(self.supplementaryFooterKind != nil, "Supplementary footer kind must be set before retrieving header model for section index")
        
        if self.supplementaryFooterKind == nil { return nil }
        
        return self.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}

extension CoreDataStorage : SupplementaryStorageProtocol
{
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
}

extension CoreDataStorage : NSFetchedResultsControllerDelegate
{
    @objc public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.startUpdate()
    }
    
    @objc public func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        if self.currentUpdate == nil { return }
        
        switch type
        {
        case .Insert:
            if self.currentUpdate!.insertedSectionIndexes.containsIndex(newIndexPath!.section) {
                // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
                return
            }
            self.currentUpdate!.insertedRowIndexPaths.append(newIndexPath!)
        case .Delete:
            if self.currentUpdate!.deletedSectionIndexes.containsIndex(indexPath!.section) {
                // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
                return
            }
            self.currentUpdate?.deletedRowIndexPaths.append(indexPath!)
        case .Move:
            if !self.currentUpdate!.insertedSectionIndexes.containsIndex(newIndexPath!.section)
            {
                self.currentUpdate!.insertedRowIndexPaths.append(newIndexPath!)
            }
            if !self.currentUpdate!.deletedSectionIndexes.containsIndex(indexPath!.section) {
                self.currentUpdate!.deletedRowIndexPaths.append(indexPath!)
            }
        case .Update:
            self.currentUpdate?.updatedRowIndexPaths.append(indexPath!)
        }
    }
   @objc
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        if self.currentUpdate == nil { return }
        
        switch type
        {
        case .Insert:
            self.currentUpdate!.insertedSectionIndexes.addIndex(sectionIndex)
        case .Delete:
            self.currentUpdate!.deletedSectionIndexes.addIndex(sectionIndex)
        default: ()
        }
    }
   @objc  
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.finishUpdate()
    }
}