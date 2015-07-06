//
//  CoreDataStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

class CoreDataStorage : BaseStorage
{
    let fetchedResultsController : NSFetchedResultsController
    private var currentUpdate : StorageUpdate?
    
    init(fetchedResultsController: NSFetchedResultsController)
    {
        self.fetchedResultsController = fetchedResultsController
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
}

extension CoreDataStorage : StorageProtocol
{
    func sections() -> [Section] {
        if let sections = self.fetchedResultsController.sections as? [NSFetchedResultsSectionInfo]
        {
            return sections.map { $0 as! Section }
        }
        return []
    }
    
    func objectAtIndexPath(path: NSIndexPath) -> Any? {
        return fetchedResultsController.objectAtIndexPath(path)
    }
}

extension CoreDataStorage : HeaderFooterStorageProtocol
{
    func headerModelForSectionIndex(index: Int) -> Any?
    {
        assert(self.supplementaryHeaderKind != nil, "Supplementary header kind must be set before retrieving header model for section index")
        
        if self.supplementaryHeaderKind == nil { return nil }
        
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
    
    func footerModelForSectionIndex(index: Int) -> Any?
    {
        assert(self.supplementaryFooterKind != nil, "Supplementary footer kind must be set before retrieving header model for section index")
        
        if self.supplementaryFooterKind == nil { return nil }
        
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
}

extension CoreDataStorage : SupplementaryStorageProtocol
{
    func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any?
    {
        if kind == self.supplementaryHeaderKind
        {
            if let sections = self.fetchedResultsController.sections as? [NSFetchedResultsSectionInfo]
            {
                return sections[sectionIndex].name
            }
            return nil
        }
        return nil
    }
    
    func setSupplementaryHeaderKind(kind: String) {
        
    }
    
    func setSupplementaryFooterKind(kind: String) {
        
    }
}

extension CoreDataStorage : NSFetchedResultsControllerDelegate
{
    
}