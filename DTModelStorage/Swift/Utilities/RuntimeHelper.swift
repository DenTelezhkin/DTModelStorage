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
    public class func mirrorFromModel(model: Any) -> MirrorType
    {
        if let managedModel = model as? NSManagedObject {
            return reflect(managedModel.classForCoder)
        }
        
        return reflect(model.dynamicType)
    }
    
    public class func classNameFromReflectionSummary(summary: String) -> String
    {
        if (contains(summary,"."))
        {
            return summary.componentsSeparatedByString(".").last!
        }
        return summary
    }
    
    public class func classNameFromReflection(reflection: MirrorType) -> String
    {
        if (contains(reflection.summary,"."))
        {
            return reflection.summary.componentsSeparatedByString(".").last!
        }
        return reflection.summary
    }
    
    public class func recursivelyUnwrapAnyValue(any: Any) -> Any?
    {
        let mirror = reflect(any)
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
    
    public class func classClusterReflectionFromMirrorType(mirror: MirrorType) -> MirrorType
    {
        if mirror.disposition != .Aggregate {
            return mirror
        }
        let typeReflection = reflect(mirror.value).summary
        switch typeReflection
        {
        case "__NSCFBoolean": fallthrough
        case "__NSCFNumber":
            return reflect(NSNumber)
            
        case "__NSCFConstantString": fallthrough
        case "__NSCFString":
            return reflect(NSString)
            
        case "NSConcreteAttributedString": fallthrough
        case "NSConcreteMutableAttributedString":
            return reflect(NSAttributedString)
            
        case "__NSDictionaryM": fallthrough
        case "__NSDictionaryI":
            return reflect(NSDictionary)
            
        case "__NSArrayM": fallthrough
        case "__NSArrayI":
            return reflect(NSArray)
            
        case "__NSSetM": fallthrough
        case "__NSSetI":
            return reflect(NSSet)
            
        case "__NSOrderedSetM": fallthrough
        case "__NSOrderedSetI":
            return reflect(NSOrderedSet)
            
        case "__NSTaggedDate": fallthrough
        case "__NSDate":
            return reflect(NSDate)
            
        default:
            return mirror
        }
    }
}