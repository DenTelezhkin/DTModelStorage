//
//  UIReactions.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.11.15.
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

import Foundation
import UIKit

/// Data holder for reaction
open class EventReaction {
    
    /// Event type
    open var type: ViewType = .cell
    
    /// Block, that performs model type-checking.
    open var modelTypeCheckingBlock: (Any) -> Bool = { _ in return false }
    
    /// 3 arguments reaction block with all arguments type-erased.
    open var reaction : ((Any,Any,Any) -> Any)?
    
    /// Objective-C method signature
    open let methodSignature: String
    
    /// Creates reaction with `signature`.
    public init(signature: String) {
        self.methodSignature = signature
    }
    
    /// Updates reaction with cell type, type-erases T and U into Any types.
    open func makeCellReaction<T,U>(_ block: @escaping (T?, T.ModelType, IndexPath) -> U)
        where T: ModelTransfer
    {
        type = .cell
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        reaction = { cell, model, indexPath in
            guard let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath else {
                  return 0
            }
            return block(cell as? T, model, indexPath)
        }
    }
    
    /// Updates reaction with cell type, type-erases T and U into Any types.
    open func makeCellReaction<T,U>(_ block: @escaping (T, IndexPath) -> U) {
        type = .cell
        modelTypeCheckingBlock = { return $0 is T }
        reaction = { cell, model, indexPath in
            guard let model = model as? T,
                let indexPath = indexPath as? IndexPath else {
                    return 0
            }
            return block(model, indexPath)
        }
    }
    
    /// Updates reaction with cell type, type-erases T and U into Any types.
    open func makeCellReaction<T,U>(_ block: @escaping (T, T.ModelType, IndexPath) -> U)
        where T: ModelTransfer
    {
        type = .cell
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        reaction = { cell, model, indexPath in
            guard let model = model as? T.ModelType,
                let indexPath = indexPath as? IndexPath,
                let cell = cell as? T
            else {
                return 0
            }
            return block(cell, model, indexPath)
        }
    }
    
    /// Updates reaction with supplementary type, type-erases T and U into Any types.
    open func makeSupplementaryReaction<T,U>(forKind kind: String, block: @escaping (T?, T.ModelType, IndexPath) -> U)
        where T: ModelTransfer
    {
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        type = .supplementaryView(kind: kind)
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T.ModelType,
                let index = sectionIndex as? IndexPath else {
                    return ""
            }
            return block(supplementary as? T, model, index)
        }
    }
    
    /// Updates reaction with supplementary type, type-erases T and U into Any types.
    open func makeSupplementaryReaction<T,U>(for kind: String, block: @escaping (T, IndexPath) -> U) {
        type = .supplementaryView(kind: kind)
        modelTypeCheckingBlock = { return $0 is T }
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T, let index = sectionIndex as? IndexPath else { return 0 }
            return block(model,index)
        }
    }
    
    /// Updates reaction with supplementary type, type-erases T and U into Any types.
    open func makeSupplementaryReaction<T,U>(forKind kind: String, block: @escaping (T, T.ModelType, IndexPath) -> U)
        where T: ModelTransfer
    {
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        type = .supplementaryView(kind: kind)
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T.ModelType,
                let index = sectionIndex as? IndexPath,
                let supplementary = supplementary as? T else
            {
                    return ""
            }
            return block(supplementary, model, index)
        }
    }
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any,Any,Any)) -> Any {
        return reaction?(arguments.0,arguments.1,arguments.2) ?? 0
    }
}

/// Subclass of `EventReaction`, tuned to work with 4 arguments.
open class FourArgumentsEventReaction : EventReaction {
    
    /// Type-erased reaction with 4 arguments
    open var reaction4Arguments : ((Any,Any,Any,Any) -> Any)?
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any, Any)) -> Any {
        return reaction4Arguments?(arguments.0, arguments.1, arguments.2, arguments.3) ?? 0
    }
}

/// Subclass of `EventReaction`, tuned to work with 5 arguments.
open class FiveArgumentsEventReaction : EventReaction {
    
    /// Type-erased reaction with 5 arguments
    open var reaction5Arguments : ((Any,Any,Any,Any,Any) -> Any)?
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any, Any, Any)) -> Any {
        return reaction5Arguments?(arguments.0, arguments.1, arguments.2, arguments.3, arguments.4) ?? 0
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element: EventReaction {
    /// Returns reaction of `type`, with `signature` and `model`. Returns nil, if reaction was not found.
    public func reaction(of type: ViewType, signature: String, forModel model: Any) -> EventReaction? {
        return filter({ reaction in
            guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return false}
            return reaction.type == type &&
                reaction.modelTypeCheckingBlock(unwrappedModel) &&
                reaction.methodSignature == signature
        }).first
    }
    
    /// Performs reaction of `type`, `signature`, with `view`, `model` in `location`.
    public func performReaction(of type: ViewType, signature: String, view: Any?, model: Any, location: Any) -> Any {
        guard let reaction = reaction(of: type, signature: signature, forModel: model) else {
            return 0
        }
        return reaction.performWithArguments((view ?? 0,model,location))
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
