//
//  Deprecated.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2016 Denys Telezhkin. All rights reserved.
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
import UIKit

public extension Storage {
    @available(*, unavailable, renamed:"item(at:)")
    func itemAtIndexPath(_ : IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension SupplementaryStorage {
    @available(*, unavailable, renamed:"supplementaryModel(ofKind:forSectionAt:)")
    func supplementaryModelOfKind(_ kind: String, sectionIndexPath: IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension HeaderFooterStorage {
    @available(*, unavailable, renamed: "headerModel(forSection:)")
    func headerModelForSectionIndex(_ index: Int) -> Any? {
        fatalError("UNAVAILABLE")
    }
    @available(*, unavailable, renamed: "footerModel(forSection:)")
    func footerModelForSectionIndex(_ index: Int) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension SupplementaryAccessible {
    @available(*, unavailable, renamed:"supplementaryModel(ofKind:atIndex:)")
    public func supplementaryModelOfKind(_ kind: String, atIndex index: Int) -> Any?
    {
        fatalError("UNAVAILABLE")
    }
}

@available(*, unavailable, renamed:"Storage")
public protocol StorageProtocol {}

@available(*, unavailable, renamed:"SupplementaryStorage")
public protocol SupplementaryStorageProtocol {}

@available(*, unavailable, renamed:"HeaderFooterStorage")
public protocol HeaderFooterStorageProtocol {}

public extension UINib {
    @available(*, unavailable, renamed:"nibExists(withNibName:inBundle:)")
    @nonobjc public class func nibExistsWithNibName(_ nibName: String,
                                                    inBundle bundle: Bundle = Bundle.main) -> Bool
    {
        fatalError("UNAVAILABLE")
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element: EventReaction {
    @available(*, unavailable, renamed: "reaction(of:signature:forModel:)")
    public func reactionOfType(_ type: ViewType, signature: String, forModel model: Any) -> EventReaction? {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed: "performReaction(of:signature:view:model:location:)")
    public func performReaction(ofType type: ViewType, signature: String, view: Any?, model: Any, location: Any) -> Any {
        fatalError("UNAVAILABLE")
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element == ViewModelMapping {
    @available(*, unavailable, renamed:"mappingCandidates(for:withModel:)")
    func mappingCandidatesForViewType(_ viewType: ViewType, model: Any) -> [ViewModelMapping] {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed: "addMapping(for:viewClass:xibName:)")
    mutating func addMappingForViewType<T: ModelTransfer>(_ viewType: ViewType, viewClass: T.Type, xibName: String? = nil) {
        fatalError("UNAVAILABLE")
    }
}
@available(*, unavailable, renamed:"ViewModelMappingCustomizing")
public protocol DTViewModelMappingCustomizable {}

public extension ViewModelMappingCustomizing {
    @available(*, unavailable, renamed:"viewModelMapping(fromCandidates:withModel:)")
    func viewModelMappingFromCandidates(_ candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        fatalError("UNAVAILABLE")
    }
}

extension MemoryStorage {
    @available(*, unavailable, renamed:"item(at:)")
    open func itemAtIndexPath(_ indexPath: IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"removeItems(at:)")
    open func removeItemsAtIndexPaths(_ indexPaths: [IndexPath])
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"moveItem(at:to:)")
    open func moveItemAtIndexPath(_ source: IndexPath, toIndexPath destination: IndexPath)
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"items(inSection:)")
    @nonobjc open func itemsInSection(_ section: Int) -> [Any]?
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"indexPath(forItem:)")
    open func indexPathForItem<T: Equatable>(_ searchableItem: T) -> IndexPath?
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"indexPathArray(forItems:)")
    final func indexPathArrayForItems<T: Equatable>(_ items: [T]) -> [IndexPath]
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"removeItems(fromSection:)")
    @nonobjc open func removeItemsFromSection(_ sectionIndex: Int) {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed:"section(atIndex:)")
    open func sectionAtIndex(_ sectionIndex: Int) -> SectionModel?
    {
        fatalError("UNAVAILABLE")
    }
}
