//
//  RealmSection.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 13.12.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
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

import RealmSwift
import Foundation

/// These following protocol is only needed because we can't cast to RealmSection without knowing what T type is in Swift 2 and Swift 3.
/// For example following cast will fail:
/// (fooSection as? RealmSection)
/// nil
protocol ItemAtIndexPathRetrievable {
    func itemAt(_ indexPath: IndexPath) -> Any?
}

/// Data holder for single section in `RealmStorage`.
open class RealmSection<T: Object> : SupplementaryAccessible, Section, ItemAtIndexPathRetrievable {
    
    /// Results object
    open var results: Results<T>
    
    /// delegate, that knows about current section index in storage.
    open weak var sectionLocationDelegate: SectionLocationIdentifyable?
    
    /// section index of current section in `RealmStorage`.
    open var currentSectionIndex: Int? {
        return sectionLocationDelegate?.sectionIndex(for: self)
    }
    
    /// Supplementaries dictionary
    open var supplementaries = [String: [Int: Any]]()
    
    /// Creates RealmSection with Realm.Results
    /// - Parameter results: results of Realm objects query
    public init(results: Results<T>) {
        self.results = results
    }
    
    // MARK: - Section
    
    /// Items in `RealmSection`
    open var items: [Any] {
        return results.map { $0 }
    }
    
    /// Number of items in `RealmSection`
    open var numberOfItems: Int {
        return results.count
    }
    
    // MARK: - ItemAtIndexPathRetrievable
    
    final func itemAt(_ indexPath: IndexPath) -> Any? {
        return results[indexPath.item]
    }
}
