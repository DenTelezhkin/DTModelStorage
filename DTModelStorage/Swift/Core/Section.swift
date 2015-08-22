//
//  Section.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

/// `Section` protocol defines an interface for sections returned by DTModelStorage object. For `MemoryStorage`, `SectionModel` is the object, conforming to current protocol. For `CoreDataStorage` NSFetchedResultsController returns  `NSFetchedResultsSectionInfo` object, that also conforms to current protocol.
public protocol Section
{
    ///  Array of objects in section.
    var objects : [Any] { get }
    
    ///  Number of objects in current section.
    var numberOfObjects : Int { get }
}