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
    var objects : [Any] { get }
    var numberOfObjects : Int { get }
}