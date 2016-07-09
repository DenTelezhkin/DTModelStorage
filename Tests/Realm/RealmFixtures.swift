//
//  RealmFixtures.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 03.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import Foundation
import RealmSwift

class Dog: Object {
    dynamic var name = ""
    dynamic var age = 0
}

func == (left: Dog, right: Dog) -> Bool
{
    return left.name == right.name
}

class Person: Object {
    dynamic var name = ""
    dynamic var picture: Data? = nil // optionals supported
    let dogs = List<Dog>()
}
