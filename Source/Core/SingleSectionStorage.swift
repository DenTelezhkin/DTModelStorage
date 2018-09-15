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

public protocol Identifiable: Equatable {
    associatedtype HashType: Hashable
    
    var identifier: HashType { get }
}

extension Identifiable where Self: Hashable {
    var identifier: Self {
        return self
    }
}

public enum SingleSectionOperation {
    case delete(Int)
    case insert(Int)
    case move(from: Int, to: Int)
    case update(Int)
}

public protocol DiffingAlgorithm {
    func diff<T: Identifiable>(from: [T], to: [T]) -> [SingleSectionOperation]
}

open class SingleSectionStorage<T: Identifiable> : BaseStorage {
    private(set) var items : [T]
    let differ: DiffingAlgorithm
    
    public init(items: [T], differ: DiffingAlgorithm) {
        self.items = items
        self.differ = differ
    }
    
    public func setItems(_ newItems: [T]) {
        animateChanges(from: items, to: newItems)
    }
    
    public func addItems(_ newItems: [T]) {
        let newArray = items + newItems
        animateChanges(from: items, to: newArray)
    }
    
    func animateChanges(from old: [T], to new: [T]) {
        let update = StorageUpdate()
        update.enqueueDatasourceUpdate { [weak self] _ in
            self?.items = new
        }
        let diffs = differ.diff(from: old, to: new)
        for diff in diffs {
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
