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
    
    // view -> model mapping of this reaction
    open let viewModelMapping: ViewModelMapping
    
    /// 3 arguments reaction block with all arguments type-erased.
    open var reaction : ((Any, Any, Any) -> Any)?
    
    /// Objective-C method signature
    open let methodSignature: String
    
    /// Creates reaction with `signature`.
    public init<T: ModelTransfer>(signature: String, viewType: ViewType, viewClass: T.Type) {
        self.methodSignature = signature
        viewModelMapping = ViewModelMapping(viewType: viewType, viewClass: T.self)
    }
    
    public init<T>(signature: String, viewType: ViewType, modelType: T.Type) {
        self.methodSignature = signature
        viewModelMapping = ViewModelMapping(viewType: viewType, modelClass: T.self)
    }
    
    /// Creates reaction with type-erased T and T.ModelType into Any types.
    open func makeReaction<T: ModelTransfer, U>(_ block: @escaping (T, T.ModelType, IndexPath) -> U) {
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
    
    /// Creates reaction with type-erased T into Any type.
    open func makeReaction<T, U>(_ block: @escaping (T, IndexPath) -> U) {
        reaction = { cell, model, indexPath in
            guard let model = model as? T,
                let indexPath = indexPath as? IndexPath else {
                    return 0
            }
            return block(model, indexPath)
        }
    }
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any)) -> Any {
        return reaction?(arguments.0, arguments.1, arguments.2) ?? 0
    }
}

/// Subclass of `EventReaction`, tuned to work with 4 arguments.
open class FourArgumentsEventReaction: EventReaction {
    
    /// Type-erased reaction with 4 arguments
    open var reaction4Arguments : ((Any, Any, Any, Any) -> Any)?
    
    public override init<T: ModelTransfer>(signature: String, viewType: ViewType, viewClass: T.Type) {
        super.init(signature: signature, viewType: viewType, viewClass: viewClass)
    }
    
    public override init<T>(signature: String, viewType: ViewType, modelType: T.Type) {
        super.init(signature: signature, viewType: viewType, modelType: modelType)
    }
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any, Any)) -> Any {
        return reaction4Arguments?(arguments.0, arguments.1, arguments.2, arguments.3) ?? 0
    }
}

/// Subclass of `EventReaction`, tuned to work with 5 arguments.
open class FiveArgumentsEventReaction: EventReaction {
    
    /// Type-erased reaction with 5 arguments
    open var reaction5Arguments : ((Any, Any, Any, Any, Any) -> Any)?
    
    public override init<T: ModelTransfer>(signature: String, viewType: ViewType, viewClass: T.Type) {
        super.init(signature: signature, viewType: viewType, viewClass: viewClass)
    }
    
    public override init<T>(signature: String, viewType: ViewType, modelType: T.Type) {
        super.init(signature: signature, viewType: viewType, modelType: modelType)
    }
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any, Any, Any)) -> Any {
        return reaction5Arguments?(arguments.0, arguments.1, arguments.2, arguments.3, arguments.4) ?? 0
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element: EventReaction {
    /// Returns reaction of `type`, with `signature` and `model`. Returns nil, if reaction was not found.
    @available(*, deprecated, message: "Please use reaction(of:signature:forModel:view:) method instead")
    public func reaction(of type: ViewType, signature: String, forModel model: Any) -> EventReaction? {
        return reaction(of: type, signature: signature, forModel: model, view: nil)
    }
    
    public func reaction(of type: ViewType,
                         signature: String,
                         forModel model: Any,
                         view: UIView?) -> EventReaction? {
        return filter({ reaction in
            guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return false}
            return reaction.viewModelMapping.viewType == type &&
                reaction.viewModelMapping.modelTypeCheckingBlock(unwrappedModel) &&
                view?.isKind(of: reaction.viewModelMapping.viewClass) ?? true &&
                reaction.methodSignature == signature
        }).first
    }
    
    /// Performs reaction of `type`, `signature`, with `view`, `model` in `location`.
    public func performReaction(of type: ViewType, signature: String, view: Any?, model: Any, location: Any) -> Any {
        guard let reaction = reaction(of: type, signature: signature, forModel: model, view: view as? UIView) else {
            return 0
        }
        return reaction.performWithArguments((view ?? 0, model, location))
    }
}
