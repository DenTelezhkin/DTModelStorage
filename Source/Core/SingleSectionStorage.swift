//
//  SingleSectionStorage.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 13.09.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
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

open class SingleSectionEquatableStorage<T:Identifiable & Equatable> : SingleSectionStorage<T> {
    public let differ: EquatableDiffingAlgorithm
    
    public init(items: [T], differ: EquatableDiffingAlgorithm) {
        self.differ = differ
        super.init(items: items)
    }
    
    open override func calculateDiffs(to newItems: [T]) -> [SingleSectionOperation] {
        return differ.diff(from: items, to: newItems)
    }
}

open class SingleSectionHashableStorage<T:Identifiable & Hashable> : SingleSectionStorage<T> {
    public let differ: HashableDiffingAlgorithm
    
    public init(items: [T], differ: HashableDiffingAlgorithm) {
        self.differ = differ
        super.init(items: items)
    }
    
    open override func calculateDiffs(to newItems: [T]) -> [SingleSectionOperation] {
        return differ.diff(from: items, to: newItems)
    }
}

open class SingleSectionStorage<T: Identifiable> : BaseStorage, Storage, SupplementaryStorage, HeaderFooterSettable {
    
    open var items : [T] { return section.items(ofType: T.self) }
    
    private var section : SectionModel
    
    init(items: [T]) {
        let sectionModel = SectionModel()
        sectionModel.setItems(items)
        section = sectionModel
    }
    
    // Storage
    
    public func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.section == 0 else { return nil }
        guard let firstSection = sections.first else { return nil }
        guard indexPath.item >= firstSection.items.count else { return nil }
        return firstSection.items[indexPath.item]
    }
    
    public var sections: [Section] {
        get {
            return [section]
        }
        set {
            if newValue.count > 1 {
                print("Attempt to set more than 1 section to SingleSectionStorage. If you need more than 1 section, consider using MemoryStorage.")
            } else if let compatibleSection = newValue.first as? SectionModel {
                section = compatibleSection
            } else {
                print("Attempt to set empty or incompatible section to SingleSectionStorage. Please use SectionModel object for SingleSectionStorage section.")
            }
        }
    }
    
    // SupplementaryStorage
    
    public func supplementaryModel(ofKind kind: String, forSectionAt indexPath: IndexPath) -> Any? {
        guard indexPath.section == 0 else { return nil }
        return section.supplementaryModel(ofKind: kind, atIndex: indexPath.item)
    }
    
    public func setSupplementaries(_ models: [[Int : Any]], forKind kind: String) {
        guard models.count <= 1 else {
            print("Attempt to set more than 1 section of supplementaries to SingleSectionStorage.")
            return
        }
        if models.count == 0 {
            section.supplementaries[kind] = nil
        } else {
            section.supplementaries[kind] = models[0]
        }
    }
    
    // Diffing and updates
    
    open func calculateDiffs(to newItems: [T]) -> [SingleSectionOperation] {
        fatalError("This method needs to be overridden in subclasses")
    }
    
    public func setItems(_ newItems: [T]) {
        let diffs = calculateDiffs(to: newItems)
        animateChanges(diffs, to: newItems)
    }

    public func addItems(_ newItems: [T], _ strategy: AccumulationStrategy = AdditiveAccumulationStrategy()) {
        let accumulatedItems = strategy.accumulate(oldItems: items, newItems: newItems)
        let diffs = calculateDiffs(to: accumulatedItems)
        animateChanges(diffs, to: accumulatedItems)
    }
    
    func animateChanges(_ changes: [SingleSectionOperation], to new: [T]) {
        let update = StorageUpdate()
        update.enqueueDatasourceUpdate { [weak self] _ in
            self?.section.items = new
        }
        for diff in changes {
            switch diff {
            case .delete(let item):
                update.objectChanges.append((.delete, [IndexPath(item: item, section: 0)]))
            case .insert(let item):
                update.objectChanges.append((.insert, [IndexPath(item: item, section: 0)]))
            case .update(let item):
                update.objectChanges.append((.update, [IndexPath(item: item, section: 0)]))
            case .move(let from, let to):
                update.objectChanges.append((.move, [IndexPath(item: from, section: 0), IndexPath(item: to, section: 0)]))
            }
        }
        delegate?.storageDidPerformUpdate(update)
    }
}
