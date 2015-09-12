//
//  RuntimeHelper.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
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
import CoreData
import UIKit

/// This class is used to introspect Swift and Objective-C types, providing necessary mapping information.
public final class RuntimeHelper
{
    /// Retrieve reflected mirror from model.
    /// - Parameter model: model to reflect
    /// - Returns: mirror of model type
    /// - Bug: When trying to retrieve dynamicType of NSManagedObject subclass, happens EXC_BAD_ACCESS ( in Swift 2.0 XCode 7 Beta 5). Whether this is a bug or not, is unknown, therefore we need to work around this by casting model conditionally to NSManagedObject.
    public class func mirrorFromModel(model: Any) -> _MirrorType
    {
        if let managedModel = model as? NSManagedObject {
            return _reflect(managedModel.classForCoder)
        }
        
        return _reflect(model.dynamicType)
    }
    
    /// This helper method strips module name from class name, for example MyModule.Foo -> "Foo"
    /// - Parameter summary - type summary
    /// - Returns: stripped type name
    public class func classNameFromReflectionSummary(summary: String) -> String
    {
        if let _ = summary.rangeOfString(".")
        {
            return summary.componentsSeparatedByString(".").last!
        }
        return summary
    }
    
    /// This helper method strips module name from class reflection, for example MyModule.Foo -> "Foo"
    /// - Parameter reflection - type reflection
    /// - Returns: stripped type name
    public class func classNameFromReflection(reflection: _MirrorType) -> String
    {
        return self.classNameFromReflectionSummary(reflection.summary)
    }
    
    /// Recursively unwrap optionals to a single level. This is helpful when dealing with double optionals.
    /// - Parameter any: optional to unwrap
    /// - Returns: unwrapped optional
    public class func recursivelyUnwrapAnyValue(any: Any) -> Any?
    {
        let mirror = _reflect(any)
        if mirror.disposition != .Optional
        {
            return any
        }
        if mirror.count == 0
        {
            return nil
        }
        let (_,some) = mirror[0]
        return recursivelyUnwrapAnyValue(some.value)
    }
    
    /// Retrieve specific mirror from class cluster in Objective-C
    /// - Parameter mirror - type mirror
    /// - Returns: mirror of class cluster ancestor.
    public class func classClusterReflectionFromMirrorType(mirror: _MirrorType) -> _MirrorType
    {
//        print(_reflect(mirror.value).summary)
        switch _reflect(mirror.value).summary
        {
        case "UIPlaceholderColor": fallthrough
        case "UIDeviceRGBColor": fallthrough
        case "UICachedDeviceRGBColor": return _reflect(UIColor)
            
        case "Swift.Array<Swift.AnyObject>": return _reflect(NSArray)
            
        case "Swift.Dictionary<NSObject, Swift.AnyObject>": return _reflect(NSDictionary)
        default: ()
        }
        
        if mirror.disposition != .Aggregate {
            return mirror
        }
        let typeReflection = _reflect(mirror.value).summary
        switch typeReflection
        {
        case "__NSCFBoolean": fallthrough
        case "__NSCFNumber":
            return _reflect(NSNumber)
            
        case "__NSCFConstantString": fallthrough
        case "__NSCFString":
            return _reflect(NSString)
            
        case "NSConcreteAttributedString": fallthrough
        case "NSConcreteMutableAttributedString":
            return _reflect(NSAttributedString)
            
        case "__NSDictionaryM": fallthrough
        case "__NSDictionaryI": fallthrough
        case "__NSDictionary0":
            return _reflect(NSDictionary)
            
        case "__NSArrayM": fallthrough
        case "__NSArrayI": fallthrough
        case "__NSArray0":
            return _reflect(NSArray)
            
        case "__NSSetM": fallthrough
        case "__NSSetI":
            return _reflect(NSSet)
            
        case "__NSOrderedSetM": fallthrough
        case "__NSOrderedSetI":
            return _reflect(NSOrderedSet)
            
        case "__NSTaggedDate": fallthrough
        case "__NSDate":
            return _reflect(NSDate)
            
        default:
            return mirror
        }
    }
}