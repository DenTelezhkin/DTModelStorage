//
//  SectionModel.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
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

/// Class represents data of the section used by `MemoryStorage`.
public class SectionModel : Section
{
    /// Items for current section
    public var objects = [Any]()
    
    /// Number of items in current section
    public var numberOfObjects: Int {
        return self.objects.count
    }
    
    private var supplementaries = [String:Any]()
    
    public init() {}
    
    /// Retrieve supplementaryModel of specific kind
    /// - Parameter: kind - kind of supplementary
    /// - Returns: supplementary model or nil, if there are no model
    public func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    /// Set supplementary model of specific kind
    /// - Parameter model: model to set
    /// - Parameter forKind: kind of supplementary
    public func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}