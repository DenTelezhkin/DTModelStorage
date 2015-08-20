//
//  MemoryStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

public struct MemoryStorageErrors
{
    public enum Insertion: ErrorType
    {
        case IndexPathTooBig
    }
    
    public enum Replacement: ErrorType
    {
        case ItemNotFound
    }
    
    public enum Removal : ErrorType
    {
        case ItemNotFound
    }
}

public class MemoryStorage: BaseStorage, StorageProtocol
{
    public var sections: [Section] = [SectionModel]()
    
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
    
    public func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    public func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
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
    
    public func setSectionHeaderModels<T>(models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryHeaderKind!)
    }
    
    public func setSectionFooterModels<T>(models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryFooterKind!)
    }
    
    public func setItems<T>(items: [T], forSectionIndex index: Int)
    {
        let section = self.sectionAtIndex(index)
        section.objects.removeAll(keepCapacity: false)
        for item in items { section.objects.append(item)}
        self.delegate?.storageNeedsReloading()
    }
    
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
    
    public func addItem<T>(item: T, toSection index: Int = 0)
    {
        self.startUpdate()
        let section = self.getValidSection(index)
        let numberOfItems = section.numberOfObjects
        section.objects.append(item)
        self.currentUpdate?.insertedRowIndexPaths.append(NSIndexPath(forItem: numberOfItems, inSection: index))
        self.finishUpdate()
    }
    
    public func insertItem<T>(item: T, toIndexPath indexPath: NSIndexPath) throws
    {
        self.startUpdate()
        let section = self.getValidSection(indexPath.section)
        
        guard section.objects.count > indexPath.item else { throw MemoryStorageErrors.Insertion.IndexPathTooBig }
        
        section.objects.insert(item, atIndex: indexPath.item)
        self.currentUpdate?.insertedRowIndexPaths.append(indexPath)
        self.finishUpdate()
    }
    
    public func reloadItem<T:Equatable>(item: T)
    {
        self.startUpdate()
        if let indexPath = self.indexPathForItem(item) {
            self.currentUpdate?.updatedRowIndexPaths.append(indexPath)
        }
        self.finishUpdate()
    }
    
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
        self.currentUpdate?.deletedRowIndexPaths.extend(indexPaths)
        self.finishUpdate()
    }
    
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
    public func itemsInSection(section: Int) -> [Any]?
    {
        if self.sections.count > section {
            return self.sections[section].objects
        }
        return nil
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> Any?
    {
        let sectionObjects : [Any]
        if indexPath.section < self.sections.count
        {
            sectionObjects = self.itemsInSection(indexPath.section)!
        }
        else {
            return nil
        }
        if indexPath.row < sectionObjects.count {
            return sectionObjects[indexPath.row]
        }
        return nil
    }
    
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
    
    public func sectionAtIndex(sectionIndex : Int) -> SectionModel
    {
        self.startUpdate()
        let section = self.getValidSection(sectionIndex)
        self.finishUpdate()
        return section
    }
    
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
    
    class func sortedArrayOfIndexPaths(indexPaths: [NSIndexPath], ascending: Bool) -> [NSIndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArrayUsingDescriptors([descriptor]) as! [NSIndexPath]
    }
}

extension MemoryStorage : HeaderFooterStorageProtocol
{
    public func headerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
  
    public func footerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}

extension MemoryStorage : SupplementaryStorageProtocol
{
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