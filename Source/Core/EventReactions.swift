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

public enum EventType {
    case cell
    case supplementary(kind: String)
}

extension EventType : Equatable {}
public func == (left: EventType, right: EventType) -> Bool {
    switch (left, right) {
    case (.cell, .cell): return true
    case (.supplementary(let leftKind),.supplementary(let rightKind)): return leftKind == rightKind
    default: return false
    }
}

public class EventReaction {
    public var type: EventType = .cell
    public var modelTypeCheckingBlock: (Any) -> Bool = { _ in return false }
    public var reaction : ((Any,Any,Any) -> Any)?
    public let methodSignature: String
    
    public init(signature: String) {
        self.methodSignature = signature
    }
    
    public func makeCellReaction<T,U where T: ModelTransfer>(block: (T?, T.ModelType, IndexPath) -> U) {
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
    
    public func makeCellReaction<T,U>(block: (T, IndexPath) -> U) {
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
    
    public func makeCellReaction<T,U where T: ModelTransfer>(block: (T, T.ModelType, IndexPath) -> U) {
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
    
    public func makeSupplementaryReaction<T,U where T: ModelTransfer>(forKind kind: String, block: (T?, T.ModelType, Int) -> U) {
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        type = .supplementary(kind: kind)
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T.ModelType,
                let index = sectionIndex as? Int else {
                    return ""
            }
            return block(supplementary as? T, model, index)
        }
    }
    
    public func makeSupplementaryReaction<T,U>(for kind: String, block: (T, Int) -> U) {
        type = .supplementary(kind: kind)
        modelTypeCheckingBlock = { return $0 is T }
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T, let index = sectionIndex as? Int else { return 0 }
            return block(model,index)
        }
    }
    
    public func makeSupplementaryReaction<T,U where T: ModelTransfer>(forKind kind: String, block: (T, T.ModelType, Int) -> U) {
        modelTypeCheckingBlock = { return $0 is T.ModelType }
        type = .supplementary(kind: kind)
        reaction = { supplementary, model, sectionIndex in
            guard let model = model as? T.ModelType,
                let index = sectionIndex as? Int,
                let supplementary = supplementary as? T else
            {
                    return ""
            }
            return block(supplementary, model, index)
        }
    }
    
    public func performWithArguments(arguments: (Any,Any,Any)) -> Any {
        return reaction?(arguments.0,arguments.1,arguments.2)
    }
}

public class FourArgumentsEventReaction : EventReaction {
    public var reaction4Arguments : ((Any,Any,Any,Any) -> Any)?
    
    public func performWithArguments(arguments: (Any, Any, Any, Any)) -> Any {
        return reaction4Arguments?(arguments.0, arguments.1, arguments.2, arguments.3)
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element: EventReaction {
    func reactionOfType(_ type: EventType, signature: String, forModel model: Any) -> EventReaction? {
        return filter({ reaction in
            guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return false}
            return reaction.type == type &&
                reaction.modelTypeCheckingBlock(unwrappedModel) &&
                reaction.methodSignature == signature
        }).first
    }
    
    func performReaction(ofType type: EventType, signature: String, view: Any?, model: Any, location: Any) -> Any {
        guard let reaction = reactionOfType(type, signature: signature, forModel: model) else {
            return 0
        }
        return reaction.performWithArguments(arguments: (view,model,location))
    }
}
