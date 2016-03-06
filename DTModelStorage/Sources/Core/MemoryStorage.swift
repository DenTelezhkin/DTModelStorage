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

import Foundation

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
public class MemoryStorage: BaseStorage, StorageProtocol, SupplementaryStorageProtocol
{
    /// sections of MemoryStorage
    public var sections: [Section] = [SectionModel]()
    
    /// Retrieve item at index path from `MemoryStorage`
    /// - Parameter path: NSIndexPath for item
    /// - Returns: model at indexPath or nil, if item not found
    public func itemAtIndexPath(path: NSIndexPath) -> Any? {
        let sectionModel : SectionModel
        if path.section >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[path.section] as! SectionModel
            if path.item >= sectionModel.numberOfItems {
                return nil
            }
        }
        return sectionModel.items[path.item]
    }
    
    /// Set section header model for MemoryStorage
    /// - Note: This does not update UI
    /// - Parameter model: model for section header at index
    /// - Parameter sectionIndex: index of section for setting header
    public func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = getValidSection(sectionIndex)
        section.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
        delegate?.storageNeedsReloading()
    }
    
    /// Set section footer model for MemoryStorage
    /// - Note: This does not update UI
    /// - Parameter model: model for section footer at index
    /// - Parameter sectionIndex: index of section for setting footer
    public func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = getValidSection(sectionIndex)
        section.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
        delegate?.storageNeedsReloading()
    }
    
    /// Set supplementaries for specific kind. Usually it's header or footer kinds.
    /// - Parameter models: supplementary models for sections
    /// - Parameter kind: supplementary kind
    public func setSupplementaries<T>(models : [T], forKind kind: String)
    {
        defer {
            self.delegate?.storageNeedsReloading()
        }
        
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as! SectionModel
                section.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        getValidSection(models.count - 1)
        
        for index in 0..<models.count {
            let section = self.sections[index] as! SectionModel
            section.setSupplementaryModel(models[index], forKind: kind)
        }
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
    public func setItems<T>(items: [T], forSectionIndex index: Int = 0)
    {
        let section = self.getValidSection(index)
        section.items.removeAll(keepCapacity: false)
        for item in items { section.items.append(item) }
        self.delegate?.storageNeedsReloading()
    }
    
    /// Set section for specific index. This will reload UI after updating
    /// - Parameter section: section to set for specific index
    /// - Parameter forSectionIndex: index of section
    public func setSection(section: SectionModel, forSectionIndex index: Int)
    {
        let _ = self.getValidSection(index)
        sections.replaceRange(index...index, with: [section as Section])
        delegate?.storageNeedsReloading()
    }
    
    /// Insert section. This method is assumed to be used, when you need to insert section with items and supplementaries in one batch operation. If you need to simply add items, use `addItems` or `setItems` instead.
    /// - Parameter section: section to insert
    /// - Parameter atIndex: index of section to insert. If `atIndex` is larger than number of sections, method does nothing.
    public func insertSection(section: SectionModel, atIndex sectionIndex: Int) {
        guard sectionIndex <= sections.count else { return }
        startUpdate()
        sections.insert(section, atIndex: sectionIndex)
        currentUpdate?.insertedSectionIndexes.insert(sectionIndex)
        for item in 0..<section.numberOfItems {
            currentUpdate?.insertedRowIndexPaths.insert(NSIndexPath(forItem: item, inSection: sectionIndex))
        }
        finishUpdate()
    }
    
    /// Add items to section with `toSection` number.
    /// - Parameter items: items to add
    /// - Parameter toSection: index of section to add items
    public func addItems<T>(items: [T], toSection index: Int = 0)
    {
        self.startUpdate()
        let section = self.getValidSection(index)
        
        for item in items {
            let numberOfItems = section.numberOfItems
            section.items.append(item)
            self.currentUpdate?.insertedRowIndexPaths.insert(NSIndexPath(forItem: numberOfItems, inSection: index))
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
        let numberOfItems = section.numberOfItems
        section.items.append(item)
        self.currentUpdate?.insertedRowIndexPaths.insert(NSIndexPath(forItem: numberOfItems, inSection: index))
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
        
        guard section.items.count >= indexPath.item else { throw MemoryStorageErrors.Insertion.IndexPathTooBig }
        
        section.items.insert(item, atIndex: indexPath.item)
        self.currentUpdate?.insertedRowIndexPaths.insert(indexPath)
        self.finishUpdate()
    }
    
    /// Reload item
    /// - Parameter item: item to reload.
    public func reloadItem<T:Equatable>(item: T)
    {
        self.startUpdate()
        if let indexPath = self.indexPathForItem(item) {
            self.currentUpdate?.updatedRowIndexPaths.insert(indexPath)
        }
        self.finishUpdate()
    }
    
    /// Replace item `itemToReplace` with `replacingItem`.
    /// - Parameter itemToReplace: item to replace
    /// - Parameter replacingItem: replacing item
    /// - Throws: if `itemToReplace` is not found, will throw MemoryStorageErrors.Replacement.ItemNotFound
    public func replaceItem<T: Equatable>(itemToReplace: T, replacingItem: Any) throws
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let originalIndexPath = self.indexPathForItem(itemToReplace) else {
            throw MemoryStorageErrors.Replacement.ItemNotFound
        }
        
        let section = self.getValidSection(originalIndexPath.section)
        section.items[originalIndexPath.item] = replacingItem
        
        self.currentUpdate?.updatedRowIndexPaths.insert(originalIndexPath)
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
        self.getValidSection(indexPath.section).items.removeAtIndex(indexPath.item)
        
        self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
    }
    
    /// Remove items
    /// - Parameter items: items to remove
    /// - Note: Any items that were not found, will be skipped
    public func removeItems<T:Equatable>(items: [T])
    {
        self.startUpdate()
        
        let indexPaths = indexPathArrayForItems(items)
        for indexPath in self.dynamicType.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        {
            self.getValidSection(indexPath.section).items.removeAtIndex(indexPath.item)
            self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
        }
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
            if let _ = self.itemAtIndexPath(indexPath)
            {
                self.getValidSection(indexPath.section).items.removeAtIndex(indexPath.item)
                self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
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
            self.currentUpdate?.deletedSectionIndexes.insert(i)
        }
        
        self.finishUpdate()
    }
    
    /// Move section from `sourceSectionIndex` to `destinationSectionIndex`.
    /// - Parameter sourceSectionIndex: index of section, from which we'll be moving
    /// - Parameter destinationSectionIndex: index of section, where we'll be moving
    public func moveSection(sourceSectionIndex: Int, toSection destinationSectionIndex: Int) {
        self.startUpdate()
        let validSectionFrom = getValidSection(sourceSectionIndex)
        let _ = getValidSection(destinationSectionIndex)
        sections.removeAtIndex(sourceSectionIndex)
        sections.insert(validSectionFrom, atIndex: destinationSectionIndex)
        currentUpdate?.movedSectionIndexes.append([sourceSectionIndex,destinationSectionIndex])
        self.finishUpdate()
    }
    
    /// Move item from `source` indexPath to `destination` indexPath.
    /// - Parameter source: indexPath from which we need to move
    /// - Parameter toIndexPath: destination index path for item
    public func moveItemAtIndexPath(source: NSIndexPath, toIndexPath destination: NSIndexPath)
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let sourceItem = itemAtIndexPath(source) else {
            print("MemoryStorage: source indexPath should not be nil when moving item")
            return
        }
        let sourceSection = getValidSection(source.section)
        let destinationSection = getValidSection(destination.section)
        
        if destinationSection.items.count < destination.row {
            print("MemoryStorage: failed moving item to indexPath: \(destination), only \(destinationSection.items.count) items in section")
            return
        }
        sourceSection.items.removeAtIndex(source.row)
        destinationSection.items.insert(sourceItem, atIndex: destination.item)
        currentUpdate?.movedRowIndexPaths.append([source,destination])
    }
    
    /// Remove all items.
    /// - Note: method will call .reloadData() when it finishes.
    public func removeAllItems()
    {
        for section in self.sections {
            (section as? SectionModel)?.items.removeAll(keepCapacity: false)
        }
        delegate?.storageNeedsReloading()
    }
    
    // MARK: - Searching in storage
    
    /// Retrieve items in section
    /// - Parameter section: index of section
    /// - Returns array of items in section or nil, if section does not exist
    public func itemsInSection(section: Int) -> [Any]?
    {
        if self.sections.count > section {
            return self.sections[section].items
        }
        return nil
    }
    
    /// Find index path of specific item in MemoryStorage
    /// - Parameter searchableItem: item to find
    /// - Returns: index path for found item, nil if not found
    public func indexPathForItem<T: Equatable>(searchableItem : T) -> NSIndexPath?
    {
        for sectionIndex in 0..<self.sections.count
        {
            let rows = self.sections[sectionIndex].items
            
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
    public func sectionAtIndex(sectionIndex : Int) -> SectionModel?
    {
        if sections.count > sectionIndex {
            return sections[sectionIndex] as? SectionModel
        }
        return nil
    }
    
    /// Find-or-create section
    /// - Parameter sectionIndex: indexOfSection
    /// - Note: This method finds or create a SectionModel. It means that if you create section 2, section 0 and 1 will be automatically created.
    /// - Returns: SectionModel
    func getValidSection(sectionIndex : Int) -> SectionModel
    {
        if sectionIndex < self.sections.count
        {
            return self.sections[sectionIndex] as! SectionModel
        }
        else {
            for i in self.sections.count...sectionIndex {
                self.sections.append(SectionModel())
                self.currentUpdate?.insertedSectionIndexes.insert(i)
            }
        }
        return self.sections.last as! SectionModel
    }
    
    /// Index path array for items
    /// - Parameter items: items to find in storage
    /// - Returns: Array if NSIndexPaths for found items
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
    /// - Parameter indexPaths: Array of index paths to sort
    /// - Parameter ascending: sort in ascending or descending order
    /// - Note: This method is used, when you need to delete multiple index paths. Sorting them in reverse order preserves initial collection from mutation while enumerating
    class func sortedArrayOfIndexPaths(indexPaths: [NSIndexPath], ascending: Bool) -> [NSIndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArrayUsingDescriptors([descriptor]) as! [NSIndexPath]
    }
    
    // MARK: - SupplementaryStorageProtocol
    
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
