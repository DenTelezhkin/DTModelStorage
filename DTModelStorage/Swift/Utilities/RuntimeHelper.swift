//
//  RuntimeHelper.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

final class RuntimeHelper
{
    class func classNameFromReflectionSummary(summary: String) -> String
    {
        if (contains(summary,"."))
        {
            return summary.componentsSeparatedByString(".").last!
        }
        return summary
    }
    
    class func classNameFromReflection(reflection: MirrorType) -> String
    {
        if (contains(reflection.summary,"."))
        {
            return reflection.summary.componentsSeparatedByString(".").last!
        }
        return reflection.summary
    }
}