//
//  StorageProtocol.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

protocol StorageProtocol
{
    func sections() -> [Section]
    
    func objectAtIndexPath(path : NSIndexPath) -> Any?
}

protocol HeaderFooterStorageProtocol
{
    func headerModelForSectionIndex(index: Int) -> Any?
    func footerModelForSectionIndex(index: Int) -> Any?
}

protocol SupplementaryStorageProtocol
{
    func supplementaryModelOfKind(kind: String, sectionIndex : Int) -> Any?
    func setSupplementaryHeaderKind(kind: String)
    func setSupplementaryFooterKind(kind: String)
}

protocol StorageUpdating : class
{
    func storageDidPerformUpdate(update : StorageUpdate)
    func storageNeedsReloading()
}