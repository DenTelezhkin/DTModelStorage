//
//  UINib+Existance.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

extension UINib {
    class func nibExistsWithNibName(nibName :String) -> Bool
    {
        if let _ = NSBundle(forClass: self).pathForResource(nibName, ofType: "nib")
        {
            return true
        }
        return false
    }
}
