//
//  DTCollectionViewStorage.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
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

#import "DTStorageUpdate.h"

/**
 `DTTableViewDataStorageUpdating` protocol is used to transfer data storage updates to `DTTableViewController` object.
 */

@protocol DTStorageUpdating <NSObject>

/**
 This method transfers data storage updates to `DTTableViewController` object. Then `DTTableViewController` object is expected to perform all animations required to synchronize datasource and UI.
 
 @param update `DTStorageUpdate` instance, that incapsulates all changes, happened in data storage.
 */
- (void)performUpdate:(DTStorageUpdate *)update;

@end


@protocol DTStorage <NSObject>


/**
 Array of sections, conforming to DTTableViewSection protocol. Depending on data storage used, section objects may be different.
 
 @return NSArray of id <DTTableViewSection> objects.
 */

- (NSArray*)sections;

/**
 Returns collection item at concrete indexPath. This method is used for perfomance reasons. For example, when DTTableViewCoreDataStorage is used, calling objects method will fetch all the objects from fetchRequest, bu we want to fetch only one.
 
 @param indexPath indexPath of desired item
 
 @return item at desired indexPath
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 Delegate property used to transfer current data storage changes to `DTTableViewController` object. It is expected to update UI with appropriate animations.
 */

@property (nonatomic, weak) id <DTStorageUpdating> delegate;

@end
