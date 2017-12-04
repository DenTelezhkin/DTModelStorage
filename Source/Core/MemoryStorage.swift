//
//  MemoryStorage.swift
//  DTModelStorage
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
public enum MemoryStorageError: LocalizedError
{
    /// Errors that can happen when inserting items into memory storage - `insertItem(_:to:)` method
    public enum InsertionReason
    {
        case indexPathTooBig(IndexPath)
    }
    
    /// Errors that can be thrown, when calling `insertItems(_:to:)` method
    public enum BatchInsertionReason
    {
        /// Is thrown, if length of batch inserted array is different from length of array of index paths.
        case itemsCountMismatch
    }
    
    /// Errors that can happen when replacing item in memory storage - `replaceItem(_:with:)` method
    public enum SearchReason
    {
        case itemNotFound(item: Any)
        
        var localizedDescription: String {
            guard case let SearchReason.itemNotFound(item: item) = self else {
                return ""
            }
            return "Failed to find \(item) in MemoryStorage"
        }
    }
    
    case insertionFailed(reason: InsertionReason)
    case batchInsertionFailed(reason: BatchInsertionReason)
    case searchFailed(reason: SearchReason)
    
    /// Description of error 
    public var localizedDescription: String {
        switch self {
        case .insertionFailed(reason: _):
            return "IndexPath provided was bigger then existing section or item"
        case .batchInsertionFailed(reason: _):
            return "While inserting batch of items, length of provided array differs from index path array length"
        case .searchFailed(reason: let reason):
            return reason.localizedDescription
        }
    }
}

/// Storage of models in memory.
///
/// `MemoryStorage` stores data models using array of `SectionModel` instances. It has various methods for changing storage contents - add, remove, insert, replace e.t.c.
/// - Note: It also notifies it's delegate about underlying changes so that delegate can update interface accordingly
/// - SeeAlso: `SectionModel`
open class MemoryStorage: BaseStorage, Storage, SupplementaryStorage, SectionLocationIdentifyable, HeaderFooterSettable
{
    /// When enabled, datasource updates are not applied immediately and saved inside `StorageUpdate` `enqueuedDatasourceUpdates` property.
    /// Call `StorageUpdate.applyDeferredDatasourceUpdates` method to apply all deferred changes.
    /// Defaults to `true`.
    /// - SeeAlso: https://github.com/DenHeadless/DTCollectionViewManager/issues/27
    open var defersDatasourceUpdates: Bool = true
    
    /// sections of MemoryStorage
    open var sections: [Section] = [SectionModel]() {
        didSet {
            sections.forEach {
                ($0 as? SectionModel)?.sectionLocationDelegate = self
            }
        }
    }
    
    func performDatasourceUpdate(_ block: @escaping (StorageUpdate) throws -> Void) {
        if defersDatasourceUpdates {
            currentUpdate?.enqueueDatasourceUpdate(block)
        } else {
            if let update = currentUpdate {
                try? block(update)
            }
        }
    }
    
    /// Returns index of `section` or nil, if section is now found
    open func sectionIndex(for section: Section) -> Int? {
        return sections.index(where: {
            return ($0 as? SectionModel) === (section as? SectionModel)
        })
    }
    
    /// Returns total number of items contained in all `MemoryStorage` sections
    ///
    /// - Complexity: O(n) where n - number of sections
    open var totalNumberOfItems: Int {
        return sections.reduce(0) { sum, section in
            return sum + section.numberOfItems
        }
    }
    
    /// Returns item at `indexPath` or nil, if it is not found.
    open func item(at indexPath: IndexPath) -> Any? {
        let sectionModel: SectionModel
        if indexPath.section >= self.sections.count {
            return nil
        } else {
            //swiftlint:disable:next force_cast
            sectionModel = self.sections[indexPath.section] as! SectionModel
            if indexPath.item >= sectionModel.numberOfItems {
                return nil
            }
        }
        return sectionModel.items[indexPath.item]
    }
    
    /// Sets section header `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionHeaderModel<T>(_ model: T?, forSection sectionIndex: Int)
    {
        guard let headerKind = supplementaryHeaderKind else {
            assertionFailure("supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method"); return
        }
        let section = getValidSection(sectionIndex, collectChangesIn: nil)
        section.setSupplementaryModel(model, forKind: headerKind, atIndex: 0)
        delegate?.storageNeedsReloading()
    }
    
    /// Sets section footer `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionFooterModel<T>(_ model: T?, forSection sectionIndex: Int)
    {
        guard let footerKind = supplementaryFooterKind else {
            assertionFailure("supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method"); return
        }
        let section = getValidSection(sectionIndex, collectChangesIn: nil)
        section.setSupplementaryModel(model, forKind: footerKind, atIndex: 0)
        delegate?.storageNeedsReloading()
    }
    
    /// Sets supplementary `models` for supplementary of `kind`.
    ///
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    open func setSupplementaries(_ models: [[Int: Any]], forKind kind: String)
    {
        defer {
            self.delegate?.storageNeedsReloading()
        }
        
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessible
                section?.supplementaries[kind] = nil
            }
            return
        }
        
        _ = getValidSection(models.count - 1, collectChangesIn: nil)
        
        for index in 0 ..< models.count {
            let section = self.sections[index] as? SupplementaryAccessible
            section?.supplementaries[kind] = models[index]
        }
    }
    
    /// Sets `items` for section at `index`.
    /// 
    /// - Note: This will reload UI after updating.
    open func setItems<T>(_ items: [T], forSection index: Int = 0)
    {
        let section = self.getValidSection(index, collectChangesIn: nil)
        section.items.removeAll(keepingCapacity: false)
        section.items = items.map { $0 }
        self.delegate?.storageNeedsReloading()
    }
    
    /// Sets `items` for sections in memory storage. This method creates all required sections, if necessary.
    ///
    /// - Note: This will reload UI after updating.
    open func setItemsForAllSections<T>(_ items: [[T]]) {
        for (index, array) in items.enumerated() {
            let section = getValidSection(index, collectChangesIn: nil)
            section.items.removeAll()
            section.items = array.map { $0 }
        }
        delegate?.storageNeedsReloading()
    }
    
    /// Sets `section` for `index`. This will reload UI after updating
    ///
    /// - Parameter section: SectionModel to set
    /// - Parameter index: index of section
    open func setSection(_ section: SectionModel, forSection index: Int)
    {
        _ = self.getValidSection(index, collectChangesIn: nil)
        sections.replaceSubrange(index...index, with: [section as Section])
        delegate?.storageNeedsReloading()
    }
    
    /// Inserts `section` at `sectionIndex`.
    ///
    /// - Parameter section: section to insert
    /// - Parameter sectionIndex: index of section to insert.
    /// - Discussion: this method is assumed to be used, when you need to insert section with items and supplementaries in one batch operation. If you need to simply add items, use `addItems` or `setItems` instead.
    /// - Note: If `sectionIndex` is larger than number of sections, method does nothing.
    open func insertSection(_ section: SectionModel, atIndex sectionIndex: Int) {
        guard sectionIndex <= sections.count else { return }
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            self?.sections.insert(section, at: sectionIndex)
            update.sectionChanges.append((.insert, [sectionIndex]))
            for item in 0..<section.numberOfItems {
                update.objectChanges.append((.insert, [IndexPath(item: item, section: sectionIndex)]))
            }
        }
        finishUpdate()
    }
    
    /// Adds `items` to section with section `index`.
    ///
    /// This method creates all sections prior to `index`, unless they are already created.
    open func addItems<T>(_ items: [T], toSection index: Int = 0)
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            let section = self?.getValidSection(index, collectChangesIn: update)
            
            for item in items {
                let numberOfItems = section?.numberOfItems ?? 0
                section?.items.append(item)
                update.objectChanges.append((.insert, [IndexPath(item: numberOfItems, section: index)]))
            }
        }
        finishUpdate()
    }
    
    /// Adds `item` to section with section `index`.
    ///
    /// - Parameter item: item to add
    /// - Parameter toSection: index of section to add item
    open func addItem<T>(_ item: T, toSection index: Int = 0)
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            let section = self?.getValidSection(index, collectChangesIn: update)
            let numberOfItems = section?.numberOfItems ?? 0
            section?.items.append(item)
            update.objectChanges.append((.insert, [IndexPath(item: numberOfItems, section: index)]))
        }
        finishUpdate()
    }
    
    /// Inserts `item` to `indexPath`.
    ///
    /// This method creates all sections prior to indexPath.section, unless they are already created.
    /// - Throws: if indexPath is too big, will throw MemoryStorageErrors.Insertion.IndexPathTooBig
    open func insertItem<T>(_ item: T, to indexPath: IndexPath) throws
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            let section = self?.getValidSection(indexPath.section, collectChangesIn: update)
            
            guard (section?.items.count ?? 0) >= indexPath.item else {
                throw MemoryStorageError.insertionFailed(reason: .indexPathTooBig(indexPath))
            }
            
            section?.items.insert(item, at: indexPath.item)
            update.objectChanges.append((.insert, [indexPath]))
        }
        finishUpdate()
    }
    
    /// Inserts `items` to `indexPaths`
    ///
    /// This method creates sections prior to maximum indexPath.section in `indexPaths`, unless they are already created.
    /// - Throws: if items.count is different from indexPaths.count, will throw MemoryStorageErrors.BatchInsertion.ItemsCountMismatch
    open func insertItems<T>(_ items: [T], to indexPaths: [IndexPath]) throws
    {
        if items.count != indexPaths.count {
            throw MemoryStorageError.batchInsertionFailed(reason: .itemsCountMismatch)
        }
        if defersDatasourceUpdates {
            performDatasourceUpdate { [weak self] update in
                indexPaths.enumerated().forEach { (arg) in
                    let (itemIndex, indexPath) = arg
                    let section = self?.getValidSection(indexPath.section, collectChangesIn: update)
                    guard (section?.items.count ?? 0) >= indexPath.item else {
                        return
                    }
                    section?.items.insert(items[itemIndex], at: indexPath.item)
                    update.objectChanges.append((.insert, [indexPath]))
                }
            }
        } else {
            performUpdates {
                indexPaths.enumerated().forEach { (arg) in
                    let (itemIndex, indexPath) = arg
                    let section = getValidSection(indexPath.section, collectChangesIn: currentUpdate)
                    guard section.items.count >= indexPath.item else {
                        return
                    }
                    section.items.insert(items[itemIndex], at: indexPath.item)
                    currentUpdate?.objectChanges.append((.insert, [indexPath]))
                }
            }
        }
    }
    
    /// Reloads `item`.
    open func reloadItem<T: Equatable>(_ item: T)
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            if let indexPath = self?.indexPath(forItem: item) {
                update.objectChanges.append((.update, [indexPath]))
                update.updatedObjects[indexPath] = item
            }
        }
        finishUpdate()
    }
    
    /// Replace item `itemToReplace` with `replacingItem`.
    ///
    /// - Throws: if `itemToReplace` is not found, will throw MemoryStorageErrors.Replacement.ItemNotFound
    open func replaceItem<T: Equatable>(_ itemToReplace: T, with replacingItem: Any) throws
    {
        startUpdate()
        defer { self.finishUpdate() }
        
        performDatasourceUpdate { [weak self] update in
            guard let originalIndexPath = self?.indexPath(forItem: itemToReplace) else {
                throw MemoryStorageError.searchFailed(reason: .itemNotFound(item: itemToReplace))
            }
            
            let section = self?.getValidSection(originalIndexPath.section, collectChangesIn: update)
            section?.items[originalIndexPath.item] = replacingItem
            
            update.objectChanges.append((.update, [originalIndexPath]))
            update.updatedObjects[originalIndexPath] = replacingItem
        }
    }
    
    /// Removes `item`.
    ///
    /// - Throws: if item is not found, will throw MemoryStorageErrors.Removal.ItemNotFound
    open func removeItem<T: Equatable>(_ item: T) throws
    {
        startUpdate()
        defer { self.finishUpdate() }
        
        performDatasourceUpdate { [weak self] update in
            guard let indexPath = self?.indexPath(forItem: item) else {
                throw MemoryStorageError.searchFailed(reason: .itemNotFound(item: item))
            }
            self?.getValidSection(indexPath.section, collectChangesIn: update).items.remove(at: indexPath.item)
            update.objectChanges.append((.delete, [indexPath]))
        }
    }
    
    /// Removes `items` from storage.
    ///
    /// Any items that were not found, will be skipped. Items are deleted in reverse order, starting from largest indexPath to prevent unintended gaps.
    /// - SeeAlso: `removeItems(at:)`
    open func removeItems<T: Equatable>(_ items: [T])
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            let indexPaths = self?.indexPathArray(forItems: items) ?? []
            for indexPath in MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
            {
                self?.getValidSection(indexPath.section, collectChangesIn: update).items.remove(at: indexPath.item)
            }
            indexPaths.forEach {
                update.objectChanges.append((.delete, [$0]))
            }
        }
        finishUpdate()
    }
    
    /// Removes items at `indexPaths`.
    ///
    /// Any indexPaths that will not be found, will be skipped. Items are deleted in reverse order, starting from largest indexPath to prevent unintended gaps.
    /// - SeeAlso: `removeItems(_:)`
    open func removeItems(at indexPaths: [IndexPath])
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            let reverseSortedIndexPaths = MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
            for indexPath in reverseSortedIndexPaths
            {
                if let _ = self?.item(at: indexPath)
                {
                    self?.getValidSection(indexPath.section, collectChangesIn: update).items.remove(at: indexPath.item)
                    update.objectChanges.append((.delete, [indexPath]))
                }
            }
        }
        finishUpdate()
    }
    
    /// Deletes `indexes` from storage.
    ///
    /// Sections will be deleted in backwards order, starting from the last one.
    open func deleteSections(_ indexes: IndexSet)
    {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            var markedForDeletion = [Int]()
            for section in indexes where section < (self?.sections.count ?? 0) {
                markedForDeletion.append(section)
            }
            for section in markedForDeletion.sorted().reversed() {
                self?.sections.remove(at: section)
            }
            markedForDeletion.forEach {
                update.sectionChanges.append((.delete, [$0]))
            }
        }
        finishUpdate()
    }
    
    /// Moves section from `sourceSectionIndex` to `destinationSectionIndex`.
    ///
    /// Sections prior to `sourceSectionIndex` and `destinationSectionIndex` will be automatically created, unless they already exist.
    open func moveSection(_ sourceSectionIndex: Int, toSection destinationSectionIndex: Int) {
        startUpdate()
        performDatasourceUpdate { [weak self] update in
            guard let validSectionFrom = self?.getValidSection(sourceSectionIndex, collectChangesIn: update) else { return }
            _ = self?.getValidSection(destinationSectionIndex, collectChangesIn: update)
            self?.sections.remove(at: sourceSectionIndex)
            self?.sections.insert(validSectionFrom, at: destinationSectionIndex)
            update.sectionChanges.append((.move, [sourceSectionIndex, destinationSectionIndex]))
        }
        finishUpdate()
    }
    
    /// Moves item from `source` indexPath to `destination` indexPath.
    ///
    /// Sections prior to `source`.section and `destination`.section will be automatically created, unless they already exist. If source item or destination index path are unreachable(too large), this method does nothing.
    open func moveItem(at source: IndexPath, to destination: IndexPath)
    {
        startUpdate()
        defer { self.finishUpdate() }
        
        performDatasourceUpdate { [weak self] update in
            guard let sourceItem = self?.item(at: source) else {
                print("MemoryStorage: source indexPath should not be nil when moving item")
                return
            }
            let sourceSection = self?.getValidSection(source.section, collectChangesIn: update)
            let destinationSection = self?.getValidSection(destination.section, collectChangesIn: update)
            
            if (destinationSection?.items.count ?? 0) < destination.row {
                print("MemoryStorage: failed moving item to indexPath: \(destination), only \(destinationSection?.items.count ?? 0) items in section")
                return
            }
            sourceSection?.items.remove(at: source.row)
            destinationSection?.items.insert(sourceItem, at: destination.item)
            update.objectChanges.append((.move, [source, destination]))
        }
    }
    
    /// Moves item from `sourceIndexPath` to `destinationIndexPath` without animations.
    ///
    /// - Note: This method can be used inside `tableView(UITableView, moveRowAt: IndexPath, to: IndexPath)` to update datasource without UI animation since UI animation has already happened. This is also useful for iOS 11 Drop reordering, that behaves the same way.
    /// - Precondition: This method will check for existance of sections and number of items in both source and destination section prior to actually moving item. If sections do not exist, or have insufficient number of items to perform an operation, this method won't do anything.
    /// - Parameters:
    ///   - sourceIndexPath: source indexPath to move item from
    ///   - destinationIndexPath: destination indexPath to move item to.
    open func moveItemWithoutAnimation(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if let from = section(atIndex: sourceIndexPath.section),
            let to = section(atIndex: destinationIndexPath.section)
        {
            if from.items.count > sourceIndexPath.row, to.items.count >= destinationIndexPath.row {
                let item = from.items[sourceIndexPath.row]
                from.items.remove(at: sourceIndexPath.row)
                to.items.insert(item, at: destinationIndexPath.row)
            } else {
                print("MemoryStorage: failed to move item from \(sourceIndexPath) to \(destinationIndexPath), \(from.items.count) items in source section and \(to.items.count) items in destination section")
            }
        }
    }
    
    /// Removes all items from storage.
    ///
    /// - Note: method will call .storageNeedsReloading() when it finishes.
    open func removeAllItems()
    {
        for section in self.sections {
            (section as? SectionModel)?.items.removeAll(keepingCapacity: false)
        }
        delegate?.storageNeedsReloading()
    }
    
    /// Remove items from section with `sectionIndex`.
    ///
    /// If section at `sectionIndex` does not exist, this method does nothing.
    open func removeItems(fromSection sectionIndex: Int) {
        startUpdate()
        defer { finishUpdate() }
        
        performDatasourceUpdate { [weak self] update in
            guard let section = self?.section(atIndex: sectionIndex) else { return }
            
            for index in section.items.indices {
                update.objectChanges.append((.delete, [IndexPath(item: index, section: sectionIndex)]))
            }
            section.items.removeAll()
        }
    }
    
    // MARK: - Searching in storage
    
    /// Returns items in section with section `index`, or nil if section does not exist
    open func items(inSection index: Int) -> [Any]?
    {
        if self.sections.count > index {
            return self.sections[index].items
        }
        return nil
    }
    
    /// Returns indexPath of `searchableItem` in MemoryStorage or nil, if it's not found.
    open func indexPath<T: Equatable>(forItem searchableItem: T) -> IndexPath?
    {
        for sectionIndex in 0..<self.sections.count
        {
            let rows = self.sections[sectionIndex].items
            
            for rowIndex in 0..<rows.count {
                if let item = rows[rowIndex] as? T {
                    if item == searchableItem {
                        return IndexPath(item: rowIndex, section: sectionIndex)
                    }
                }
            }
            
        }
        return nil
    }
    
    /// Returns section at `sectionIndex` or nil, if it does not exist
    open func section(atIndex sectionIndex: Int) -> SectionModel?
    {
        if sections.count > sectionIndex {
            return sections[sectionIndex] as? SectionModel
        }
        return nil
    }
    
    /// Finds-or-creates section at `sectionIndex`
    ///
    /// - Note: This method finds or create a SectionModel. It means that if you create section 2, section 0 and 1 will be automatically created.
    /// - Returns: SectionModel
    final func getValidSection(_ sectionIndex: Int, collectChangesIn update: StorageUpdate?) -> SectionModel
    {
        if sectionIndex < self.sections.count
        {
            //swiftlint:disable:next force_cast
            return sections[sectionIndex] as! SectionModel
        } else {
            for i in sections.count...sectionIndex {
                sections.append(SectionModel())
                update?.sectionChanges.append((.insert, [i]))
            }
        }
        //swiftlint:disable:next force_cast
        return sections.last as! SectionModel
    }
    
    /// Returns index path array for `items`
    ///
    /// - Parameter items: items to find in storage
    /// - Returns: Array of IndexPaths for found items
    /// - Complexity: O(N^2*M) where N - number of items in storage, M - number of items.
    final func indexPathArray<T: Equatable>(forItems items: [T]) -> [IndexPath]
    {
        var indexPaths = [IndexPath]()
        
        for index in 0..<items.count {
            if let indexPath = self.indexPath(forItem: items[index])
            {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    /// Returns sorted array of index paths - useful for deletion.
    /// - Parameter indexPaths: Array of index paths to sort
    /// - Parameter ascending: sort in ascending or descending order
    /// - Note: This method is used, when you need to delete multiple index paths. Sorting them in reverse order preserves initial collection from mutation while enumerating
    static func sortedArrayOfIndexPaths(_ indexPaths: [IndexPath], ascending: Bool) -> [IndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArray(using: [descriptor]) as? [IndexPath] ?? []
    }
    
    // MARK: - SupplementaryStorage
    
    /// Returns supplementary model of supplementary `kind` for section at `sectionIndexPath`. Returns nil if not found.
    ///
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModel(ofKind kind: String, forSectionAt sectionIndexPath: IndexPath) -> Any? {
        guard sectionIndexPath.section < sections.count else {
            return nil
        }
        return (self.sections[sectionIndexPath.section] as? SupplementaryAccessible)?.supplementaryModel(ofKind:kind, atIndex: sectionIndexPath.item)
    }
}
