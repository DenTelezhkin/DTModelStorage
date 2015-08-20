//
//  RuntimeHelper.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import CoreData

public final class RuntimeHelper
{
    public class func mirrorFromModel(model: Any) -> _MirrorType
    {
        if let managedModel = model as? NSManagedObject {
            return _reflect(managedModel.classForCoder)
        }
        
        return _reflect(model.dynamicType)
    }
    
    public class func classNameFromReflectionSummary(summary: String) -> String
    {
        if let _ = summary.rangeOfString(".")
        {
            return summary.componentsSeparatedByString(".").last!
        }
        return summary
    }
    
    public class func classNameFromReflection(reflection: _MirrorType) -> String
    {
        if let _ = reflection.summary.rangeOfString(".")
        {
            return reflection.summary.componentsSeparatedByString(".").last!
        }
        return reflection.summary
    }
    
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
    
    public class func classClusterReflectionFromMirrorType(mirror: _MirrorType) -> _MirrorType
    {
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
        case "__NSDictionaryI":
            return _reflect(NSDictionary)
            
        case "__NSArrayM": fallthrough
        case "__NSArrayI":
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