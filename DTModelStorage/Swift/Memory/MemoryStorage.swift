//
//  MemoryStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
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

/// This struct contains error types that can be thrown for various MemoryStorage errors
public struct MemoryStorageErrors
{
    /// Errors that can happen when inserting items into memory storage
    public enum Insertion: ErrorType
    {
        case IndexPathTooBig
    }
    
    /// Errors that can happen when replacing item in memory storage
    public enum Replacement: ErrorType
    {
        case ItemNotFound
    }
    
    /// Errors that can happen when removing item from memory storage
    public enum Removal : ErrorType
    {
        case ItemNotFound
    }
}

/// This class represents model storage in memory. 
///
/// `MemoryStorage` stores data models like array of `SectionModel` instances. It has various methods for changing storage contents - add, remove, insert, replace e.t.c. 
/// - Note: It also notifies it's delegate about underlying changes so that delegate can update interface accordingly
/// - SeeAlso: `SectionModel`
public class MemoryStorage: BaseStorage, StorageProtocol
{
    /// sections of MemoryStorage
    public var sections: [Section] = [SectionModel]()
    
    /// Retrieve object at index path from `MemoryStorage`
    /// - Parameter path: NSIndexPath for object
    /// - Returns: model at indexPath or nil, if item not found
    public func objectAtIndexPath(path: NSIndexPath) -> Any? {
        let sectionModel : SectionModel
        if path.section >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[path.section] as! SectionModel
            if path.item >= sectionModel.numberOfObjects {
                return nil
            }
        }
        return sectionModel.objects[path.item]
    }
    
    /// Set section header model for MemoryStorage
    /// - Note: This does not update UI
    /// - Parameter model: model for section header at index
    /// - Parameter sectionIndex: index of section for setting header
    public func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer model for MemoryStorage
    /// - Note: This does not update UI
    /// - Parameter model: model for section footer at index
    /// - Parameter sectionIndex: index of section for setting footer
    public func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
    /// Set supplementaries for specific kind. Usually it's header or footer kinds.
    /// - Parameter models: supplementary models for sections
    /// - Parameter kind: supplementary kind
    public func setSupplementaries<T>(models : [T], forKind kind: String)
    {
        self.startUpdate()
        
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as! SectionModel
                section.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        self.getValidSection(models.count - 1)
        
        for index in 0..<models.count {
            let section = self.sections[index] as! SectionModel
            section.setSupplementaryModel(models[index], forKind: kind)
        }
        
        self.finishUpdate()
    }
    
    /// Set section header models.
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    /// - Parameter models: section header models
    public func setSectionHeaderModels<T>(models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer models.
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    /// - Parameter models: section footer models
    public func setSectionFooterModels<T>(models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryFooterKind!)
    }
    
    /// Set items for specific section. This will reload UI after updating.
    /// - Parameter items: items to set for section
    /// - Parameter forSectionIndex: index of section to update
    public func setItems<T>(items: [T], forSectionIndex index: Int)
    {
        let section = self.sectionAtIndex(index)
        section.objects.removeAll(keepCapacity: false)
        for item in items { section.objects.append(item) }
        self.delegate?.storageNeedsReloading()
    }
    
    /// Add items to section with `toSection` number.
    /// - Parameter items: items to add
    /// - Parameter toSection: index of section to add items
    public func addItems<T>(items: [T], toSection index: Int = 0)
    {
        self.startUpdate()
        let section = self.getValidSection(index)
        
        for item in items {
            let numberOfItems = section.numberOfObjects
            section.objects.append(item)
            self.currentUpdate?.insertedRowIndexPaths.append(NSIndexPath(forItem: numberOfItems, inSection: index))
        }
        self.finishUpdate()
    }
    
    /// Add item to section with `toSection` number.
    /// - Parameter item: item to add
    /// - Parameter toSection: index of section to add item
    public func addItem<T>(item: T, toSection index: Int = 0)
    {
        self.startUpdate()
        let section = self.getValidSection(index)
        let numberOfItems = section.numberOfObjects
        section.objects.append(item)
        self.currentUpdate?.insertedRowIndexPaths.append(NSIndexPath(forItem: numberOfItems, inSection: index))
        self.finishUpdate()
    }
    
    /// Insert item to indexPath
    /// - Parameter item: item to insert
    /// - Parameter toIndexPath: indexPath to insert
    /// - Throws: if indexPath is too big, will throw MemoryStorageErrors.Insertion.IndexPathTooBig
    public func insertItem<T>(item: T, toIndexPath indexPath: NSIndexPath) throws
    {
        self.startUpdate()
        let section = self.getValidSection(indexPath.section)
        
        guard section.objects.count > indexPath.item else { throw MemoryStorageErrors.Insertion.IndexPathTooBig }
        
        section.objects.insert(item, atIndex: indexPath.item)
        self.currentUpdate?.insertedRowIndexPaths.append(indexPath)
        self.finishUpdate()
    }
    
    /// Reload item
    /// - Parameter item: item to reload.
    public func reloadItem<T:Equatable>(item: T)
    {
        self.startUpdate()
        if let indexPath = self.indexPathForItem(item) {
            self.currentUpdate?.updatedRowIndexPaths.append(indexPath)
        }
        self.finishUpdate()
    }
    
    /// Replace item `itemToReplace` with `replacingItem`.
    /// - Parameter itemToReplace: item to replace
    /// - Parameter replacingItem: replacing item
    /// - Throws: if `itemToReplace` is not found, will throw MemoryStorageErrors.Replacement.ItemNotFound
    public func replaceItem<T: Equatable, U:Equatable>(itemToReplace: T, replacingItem: U) throws
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let originalIndexPath = self.indexPathForItem(itemToReplace) else {
            throw MemoryStorageErrors.Replacement.ItemNotFound
        }
        
        let section = self.getValidSection(originalIndexPath.section)
        section.objects[originalIndexPath.item] = replacingItem

        self.currentUpdate?.updatedRowIndexPaths.append(originalIndexPath)
    }
    
    /// Remove item `item`.
    /// - Parameter item: item to remove
    /// - Throws: if item is not found, will throw MemoryStorageErrors.Removal.ItemNotFound
    public func removeItem<T:Equatable>(item: T) throws
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let indexPath = self.indexPathForItem(item) else {
            throw MemoryStorageErrors.Removal.ItemNotFound
        }
        self.getValidSection(indexPath.section).objects.removeAtIndex(indexPath.item)
        
        self.currentUpdate?.deletedRowIndexPaths.append(indexPath)
    }
    
    /// Remove items
    /// - Parameter items: items to remove
    /// - Note: Any items that were not found, will be skipped
    public func removeItems<T:Equatable>(items: [T])
    {
        self.startUpdate()
        let indexPaths = self.indexPathArrayForItems(items)
        for item in items
        {
            if let indexPath = self.indexPathForItem(item) {
                self.getValidSection(indexPath.section).objects.removeAtIndex(indexPath.item)
            }
        }
        self.currentUpdate?.deletedRowIndexPaths.appendContentsOf(indexPaths)
        self.finishUpdate()
    }
    
    /// Remove items at index paths.
    /// - Parameter indexPaths: indexPaths to remove item from. Any indexPaths that will not be found, will be skipped
    public func removeItemsAtIndexPaths(indexPaths : [NSIndexPath])
    {
        self.startUpdate()
        
        let reverseSortedIndexPaths = self.dynamicType.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        for indexPath in reverseSortedIndexPaths
        {
            if let _ = self.objectAtIndexPath(indexPath)
            {
                self.getValidSection(indexPath.section).objects.removeAtIndex(indexPath.item)
                self.currentUpdate?.deletedRowIndexPaths.append(indexPath)
            }
        }
        
        self.finishUpdate()
    }
    
    /// Delete sections in indexSet
    /// - Parameter sections: sections to delete
    public func deleteSections(sections : NSIndexSet)
    {
        self.startUpdate()

        for var i = sections.lastIndex; i != NSNotFound; i = sections.indexLessThanIndex(i) {
            self.sections.removeAtIndex(i)
        }
        self.currentUpdate?.deletedSectionIndexes.addIndexes(sections)
        
        self.finishUpdate()
    }
}

// MARK: - Searching in storage
extension MemoryStorage
{
    /// Retrieve items in section
    /// - Parameter section: index of section
    /// - Returns array of items in section or nil, if section does not exist
    public func itemsInSection(section: Int) -> [Any]?
    {
        if self.sections.count > section {
            return self.sections[section].objects
        }
        return nil
    }
    
    /// Retrieve object at index path from `MemoryStorage`
    /// - Parameter path: NSIndexPath for object
    /// - Returns: model at indexPath or nil, if item not found
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Any?
    {
        return self.objectAtIndexPath(indexPath)
    }
    
    /// Find index path of specific item in MemoryStorage
    /// - Parameter searchableItem: item to find
    /// - Returns: index path for found item, nil if not found
    public func indexPathForItem<T: Equatable>(searchableItem : T) -> NSIndexPath?
    {
        for sectionIndex in 0..<self.sections.count
        {
            let rows = self.sections[sectionIndex].objects
            
            for rowIndex in 0..<rows.count {
                if let item = rows[rowIndex] as? T {
                    if item == searchableItem {
                        return NSIndexPath(forItem: rowIndex, inSection: sectionIndex)
                    }
                }
            }
            
        }
        return nil
    }
    
    /// Retrieve section model for specific section.
    /// - Parameter sectionIndex: index of section
    /// - Note: if section did not exist prior to calling this, it will be created, and UI updated.
    public func sectionAtIndex(sectionIndex : Int) -> SectionModel
    {
        self.startUpdate()
        let section = self.getValidSection(sectionIndex)
        self.finishUpdate()
        return section
    }
    
    /// Find-or-create section
    func getValidSection(sectionIndex : Int) -> SectionModel
    {
        if sectionIndex < self.sections.count
        {
            return self.sections[sectionIndex] as! SectionModel
        }
        else {
            for i in self.sections.count...sectionIndex {
                self.sections.append(SectionModel())
                self.currentUpdate?.insertedSectionIndexes.addIndex(i)
            }
        }
        return self.sections.last as! SectionModel
    }
    
    /// Index path array for items
    func indexPathArrayForItems<T:Equatable>(items:[T]) -> [NSIndexPath]
    {
        var indexPaths = [NSIndexPath]()
        
        for index in 0..<items.count {
            if let indexPath = self.indexPathForItem(items[index])
            {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    /// Sorted array of index paths - useful for deletion.
    class func sortedArrayOfIndexPaths(indexPaths: [NSIndexPath], ascending: Bool) -> [NSIndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArrayUsingDescriptors([descriptor]) as! [NSIndexPath]
    }
}

// MARK: - HeaderFooterStorageProtocol
extension MemoryStorage :HeaderFooterStorageProtocol
{
    /// Header model for section.
    /// - Requires: supplementaryHeaderKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: header model for section, or nil if there are no model
    public func headerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
  
    /// Footer model for section.
    /// - Requires: supplementaryFooterKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: footer model for section, or nil if there are no model
    public func footerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}

// MARK: - SupplementaryStorageProtocol
extension MemoryStorage : SupplementaryStorageProtocol
{
    /// Retrieve supplementary model of specific kind for section. 
    /// - Parameter kind: kind of supplementary model
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    public func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any? {
        let sectionModel : SectionModel
        if sectionIndex >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[sectionIndex] as! SectionModel
        }
        return sectionModel.supplementaryModelOfKind(kind)
    }
}