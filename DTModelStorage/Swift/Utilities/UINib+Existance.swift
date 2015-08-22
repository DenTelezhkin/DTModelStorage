//
//  UINib+Existance.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

public extension UINib {
    
    /// Check whether nib with name exists in bundle
    /// - Parameter nibName: Name of xib file
    /// - Parameter inBundle: bundle to search in
    /// - Returns: true, if nib exists, false - if not.
    public class func nibExistsWithNibName(nibName :String,
        inBundle bundle: NSBundle = NSBundle.mainBundle()) -> Bool
    {
        if let _ = bundle.pathForResource(nibName, ofType: "nib")
        {
            return true
        }
        return false
    }
}
