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

public enum UIReactionType: Equatable
{
    case cellSelection
    case cellConfiguration
    case supplementaryConfiguration(kind: String)
    
    public func supplementaryKind() -> String? {
        if case .supplementaryConfiguration(let kind) = self {
            return kind
        }
        return nil
    }
}

public func == (left: UIReactionType, right: UIReactionType) -> Bool {
    switch (left, right) {
    case (.cellSelection, .cellSelection): return true
    case (.cellConfiguration, .cellConfiguration): return true
    case (.supplementaryConfiguration(let leftKind),.supplementaryConfiguration(let rightKind)): return leftKind == rightKind
    default: return false
    }
}

public class UIReaction
{
    public let reactionType : UIReactionType
    public let viewClass : AnyClass
    public var reactionBlock: (() -> Void)?
    public var reactionData : ViewData?
    
    public func perform() {
        reactionBlock?()
    }
    
    public init(_ reactionType: UIReactionType, viewClass: AnyClass) {
        self.reactionType = reactionType
        self.viewClass = viewClass
    }
}

public struct ViewData
{
    public let view: UIView
    public let indexPath: IndexPath
    
    public init(view: UIView, indexPath: IndexPath) {
        self.view = view
        self.indexPath = indexPath
    }
}

public extension RangeReplaceableCollection where Self.Iterator.Element == UIReaction {
    func reactionsOfType(_ type: UIReactionType, forView view: Any) -> [UIReaction] {
        return self.filter({ reaction -> Bool in
            guard let unwrappedView = RuntimeHelper.recursivelyUnwrapAnyValue(view) else { return false }
            return reaction.reactionType == type && String(reaction.viewClass) == String(unwrappedView.dynamicType)
        })
    }
}

