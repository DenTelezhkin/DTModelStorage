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
