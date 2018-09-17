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

public protocol Identifiable {
    var identifier: AnyHashable { get }
}

public enum SingleSectionOperation {
    case delete(Int)
    case insert(Int)
    case move(from: Int, to: Int)
    case update(Int)
}

public protocol HashableDiffingAlgorithm {
    func diff<T: Identifiable & Hashable>(from: [T], to: [T]) -> [SingleSectionOperation]
}

public protocol EquatableDiffingAlgorithm {
    func diff<T: Identifiable & Equatable>(from: [T], to: [T]) -> [SingleSectionOperation]
}

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

open class SingleSectionStorage<T: Identifiable> : BaseStorage {
    private(set) open var items : [T]
    
    init(items: [T]) {
        self.items = items
    }
    
    open func calculateDiffs(to newItems: [T]) -> [SingleSectionOperation] {
        fatalError("This method needs to be overridden in subclasses")
    }
    
    public func setItems(_ newItems: [T]) {
        let diffs = calculateDiffs(to: newItems)
        animateChanges(diffs, to: newItems)
    }

    public func addItems(_ newItems: [T]) {
        let newArray = items + newItems
        let diffs = calculateDiffs(to: newArray)
        animateChanges(diffs, to: newArray)
    }
    
    func animateChanges(_ changes: [SingleSectionOperation], to new: [T]) {
        let update = StorageUpdate()
        update.enqueueDatasourceUpdate { [weak self] _ in
            self?.items = new
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
