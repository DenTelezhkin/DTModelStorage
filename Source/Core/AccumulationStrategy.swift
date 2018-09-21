//
//  AccumulationStrategy.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 21.09.2018.
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

public protocol AccumulationStrategy {
    func accumulate<T:Identifiable>(oldItems: [T], newItems: [T]) -> [T]
}

public struct AdditiveAccumulationStrategy: AccumulationStrategy {
    public init() {}
    
    public func accumulate<T>(oldItems: [T], newItems: [T]) -> [T] where T : Identifiable {
        return oldItems + newItems
    }
}

public struct UpdateOldValuesAccumulationStrategy: AccumulationStrategy {
    public init() {}
    
    public func accumulate<T>(oldItems: [T], newItems: [T]) -> [T] where T : Identifiable {
        var newArray = oldItems
        var existingIdentifiers = [AnyHashable:Int]()
        for (index, oldItem) in oldItems.enumerated() {
            existingIdentifiers[oldItem.identifier] = index
        }
        for (index, newItem) in newItems.enumerated() {
            let newIdentifier = newItem.identifier
            if let oldIndex = existingIdentifiers[newIdentifier] {
                // Detected duplicate
                newArray[oldIndex] = newItem
            } else {
                existingIdentifiers[newIdentifier] = index
                newArray.append(newItem)
            }
        }
        return newArray
    }
}

public struct DeleteOldValuesAccumulationStrategy: AccumulationStrategy {
    public init() {}
    
    public func accumulate<T>(oldItems: [T], newItems: [T]) -> [T] where T : Identifiable {
        var newArray = oldItems
        var existingIdentifiers = [AnyHashable:Int]()
        var indexesToDelete = [Int]()
        for (index, oldItem) in oldItems.enumerated() {
            existingIdentifiers[oldItem.identifier] = index
        }
        for (index, newItem) in newItems.enumerated() {
            let newIdentifier = newItem.identifier
            if let oldIndex = existingIdentifiers[newIdentifier] {
                // Detected duplicate
                newArray.append(newItem)
                
                // Old item will be deleted later
                indexesToDelete.append(oldIndex)
            } else {
                existingIdentifiers[newIdentifier] = index
                newArray.append(newItem)
            }
        }
        
        indexesToDelete.sorted().reversed().forEach { newArray.remove(at: $0) }
        return newArray
    }
}
