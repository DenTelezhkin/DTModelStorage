//
//  Section.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

protocol Section
{
    func objects() -> [Any]
    
    func numberOfObjects() -> UInt
}