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

//swiftlint:disable large_tuple

/// Data holder for reaction
open class EventReaction {
    
    /// 3 arguments reaction block with all arguments type-erased.
    open var reaction : ((Any, Any, Any) -> Any)?
    
    /// Objective-C method signature
    public let methodSignature: String
    
    /// Creates reaction with `signature`.
    public init<View, ModelType, ReturnType>(_ viewType: View.Type,
                                            _ modelType: ModelType.Type,
                                            signature: String,
                                            _ block: @escaping (View, ModelType, IndexPath) -> ReturnType) {
        self.methodSignature = signature
        reaction = { view, model, indexPath in
            guard let model = model as? ModelType,
                let indexPath = indexPath as? IndexPath,
                let view = view as? View
                else {
                    return 0
            }
            return block(view, model, indexPath)
        }
    }
    
    /// Creates reaction with `signature`, `viewType` and `modelType`.
    public init<Argument, ReturnType>(_ modelType: Argument.Type, signature: String, _ block: @escaping (Argument, IndexPath) -> ReturnType) {
        self.methodSignature = signature
        reaction = { cell, model, indexPath in
            guard let model = model as? Argument,
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
   
    @available(*, unavailable)
    public override init<Argument, ReturnType>(_ modelType: Argument.Type, signature: String, _ block: @escaping (Argument, IndexPath) -> ReturnType) {
        super.init(modelType, signature: signature, block)
    }
    
    @available(*, unavailable)
    public override init<View, Argument, ReturnType>(_ viewType: View.Type, _ modelType: Argument.Type, signature: String, _ block: @escaping (View, Argument, IndexPath) -> ReturnType) {
        super.init(viewType, modelType, signature: signature, block)
    }
    
    @available(*, unavailable)
    open override func performWithArguments(_ arguments: (Any, Any, Any)) -> Any {
        fatalError("This method should not be called. Please call 4 argument version of this method")
    }
    
    public init<View, ModelType, Argument, ReturnType>(_ viewType: View.Type,
                                                         modelType: ModelType.Type,
                                                         argument: Argument.Type,
                                                         signature: String,
                                                         _ block: @escaping (Argument, View, ModelType, IndexPath) -> ReturnType) {
        super.init(viewType, modelType, signature: signature) { _, _, _ in
            fatalError("This closure should not be called by FourArgumentsEventReaction")
        }
        reaction4Arguments = { argument, view, model, indexPath in
            guard let model = model as? ModelType,
                let indexPath = indexPath as? IndexPath,
                let argument = argument as? Argument,
                let view = view as? View else { return 0 }
            return block(argument, view, model, indexPath)
        }
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
    
    @available(*, unavailable)
    public override init<Argument, ReturnType>(_ modelType: Argument.Type, signature: String, _ block: @escaping (Argument, IndexPath) -> ReturnType) {
        super.init(modelType, signature: signature, block)
    }
    
    @available(*, unavailable)
    public override init<View, Argument, ReturnType>(_ viewType: View.Type, _ modelType: Argument.Type, signature: String, _ block: @escaping (View, Argument, IndexPath) -> ReturnType) {
        super.init(viewType, modelType, signature: signature, block)
    }
    
    @available(*, unavailable)
    open override func performWithArguments(_ arguments: (Any, Any, Any)) -> Any {
        fatalError("This method should not be called. Please call 4 argument version of this method")
    }
    
    public init<View, ModelType, ArgumentOne, ArgumentTwo, ReturnType>(_ viewType: View.Type,
                                                                       modelType: ModelType.Type,
                                                                       argumentOne: ArgumentOne.Type,
                                                                       argumentTwo: ArgumentTwo.Type,
                                                                       signature: String, _ block: @escaping (ArgumentOne, ArgumentTwo, View, ModelType, IndexPath) -> ReturnType) {
        super.init(viewType, modelType, signature: signature) { _, _, _ in
            fatalError("This closure should not be called by FiveArgumentsEventReaction")
        }
        reaction5Arguments = { argumentOne, argumentTwo, view, model, indexPath in
            guard let model = model as? ModelType,
                let indexPath = indexPath as? IndexPath,
                let argument1 = argumentOne as? ArgumentOne,
                let argument2 = argumentTwo as? ArgumentTwo,
                let view = view as? View else { return 0 }
            return block(argument1, argument2, view, model, indexPath)
        }
    }
    
    /// Performs reaction with `arguments`.
    open func performWithArguments(_ arguments: (Any, Any, Any, Any, Any)) -> Any {
        return reaction5Arguments?(arguments.0, arguments.1, arguments.2, arguments.3, arguments.4) ?? 0
    }
}

extension Sequence where Self.Iterator.Element: ViewModelMappingProtocol {
    /// Searches for reaction using specified parameters.
    public func reaction(of type: ViewType,
                         signature: String,
                         forModel model: Any,
                         at indexPath: IndexPath,
                         view: UIView?) -> EventReaction? {
        guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return nil }
        return filter { mapping in
            // Find all compatible mappings
            mapping.modelTypeCheckingBlock(unwrappedModel) &&
            mapping.viewType == type &&
            (view?.isKind(of: mapping.viewClass) ?? true) &&
            mapping.condition.isCompatible(with: indexPath, model: unwrappedModel) &&
                mapping.reactions.contains { $0.methodSignature == signature }
        }
        .first?.reactions.first(where: { $0.methodSignature == signature })
    }
    
    /// Performs reaction of `type`, `signature`, with `view`, `model` in `location`.
    public func performReaction(of type: ViewType, signature: String, view: Any?, model: Any, location: IndexPath) -> Any {
        guard let reaction = reaction(of: type, signature: signature, forModel: model, at: location, view: view as? UIView) else {
            return 0
        }
        return reaction.performWithArguments((view ?? 0, model, location))
    }
    
    //swiftlint:disable function_parameter_count
    /// Performs reaction of `type`, `signature`, with `argument`, `view`, `model` in `location`.
    public func perform4ArgumentsReaction(of type: ViewType, signature: String, argument: Any, view: Any?, model: Any, location: IndexPath) -> Any {
        guard let reaction = reaction(of: type, signature: signature, forModel: model, at: location, view: view as? UIView) as? FourArgumentsEventReaction else { return 0 }
        return reaction.performWithArguments((argument, view ?? 0, model, location))
    }
    
    /// Performs reaction of `type`, `signature`, with `firstArgument`, `secondArgument`, `view`, `model` in `location`.
    public func perform5ArgumentsReaction(of type: ViewType, signature: String, firstArgument: Any, secondArgument: Any, view: Any?, model: Any, location: IndexPath) -> Any {
        guard let reaction = reaction(of: type, signature: signature, forModel: model, at: location, view: view as? UIView) as? FiveArgumentsEventReaction else { return 0 }
        return reaction.performWithArguments((firstArgument, secondArgument, view ?? 0, model, location))
    }
}
