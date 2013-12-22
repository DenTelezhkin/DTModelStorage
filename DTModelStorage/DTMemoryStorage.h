//
//  DTCollectionViewMemoryStorage.h
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

#import "DTStorage.h"
#import "DTSectionModel.h"

@interface DTMemoryStorage : NSObject <DTStorage>

/**
 Creates DTTableViewMemoryStorage with default configuration.
 */

+(instancetype)storage;

/**
 Contains array of DTCollectionViewSectionModel's. Every DTCollectionViewSectionModel contains NSMutableArray of objects - there all table view models are stored. Every DTTableViewSectionModel also contains header and footer models for sections.
 */

@property (nonatomic, strong) NSMutableArray * sections;

/**
 Delegate object, that gets notified about data storage updates. This property is automatically set by `DTTableViewController` instance, when setter for dataStorage property is called.
 */
@property (nonatomic, weak) id <DTStorageUpdating> delegate;

@property (nonatomic, assign) BOOL loggingEnabled;

-(void)addItem:(NSObject *)item;

-(void)addItem:(NSObject *)item toSection:(NSInteger)sectionNumber;

-(void)addItems:(NSArray *)items;

-(void)addItems:(NSArray *)items toSection:(NSInteger)sectionNumber;

-(void)insertItem:(NSObject *)item toIndexPath:(NSIndexPath *)indexPath;

-(void)reloadItem:(NSObject *)item;

- (void)removeItem:(NSObject *)item;

- (void)removeItems:(NSArray *)items;

- (void)replaceItem:(NSObject *)itemToReplace
           withItem:(NSObject *)replacingItem;

-(void)deleteSections:(NSIndexSet *)indexSet;

-(NSArray *)itemsInSection:(NSInteger)sectionNumber;

-(id)itemAtIndexPath:(NSIndexPath *)indexPath;

-(NSIndexPath *)indexPathForItem:(NSObject *)item;

- (DTSectionModel *)sectionAtIndex:(NSInteger)sectionNumber;

@end
