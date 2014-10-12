//
//  DTMemoryStorage.h
//  DTModelStorage
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

#import "DTBaseStorage.h"
#import "DTSectionModel.h"

/**
 This class is used to store data models in memory. Generally, for datasource based UI controls, good pattern is to update datasource first, and then update it's UI representation. Updating datasource in current case means calling one of the add/remove/insert etc. methods. Updating UI is outside the scope of current class and is something storage delegate can do, by responding to `performUpdate:` method.
 
 `DTMemoryStorage` stores data models like array of `DTSectionModel` instances. So it's basically array of sections, where each section has an array of objects, and any supplementary models, that further describe current section, and can be used, for example, like section headers and footers.
 */

@interface DTMemoryStorage : DTBaseStorage <DTStorageProtocol>

/**
 Creates `DTMemoryStorage` with default configuration.
 
 @return DTMemoryStorage instance
 */

+(instancetype)storage;

/**
 Contains array of DTSectionModel's. Every DTSectionModel contains NSMutableArray of objects - all models are stored there. Every DTSectionModel also contains optional supplementary models - for example, it can be headers or footers for UITableView or UICollectionView. Number of supplementary models is not limited to just 2.
 */

@property (nonatomic, strong) NSMutableArray * sections;

/**
 Property to enable/disable logging. Logging is on by default, and will print out any critical messages, that DTMemoryStorage is encountering.
 */
@property (nonatomic, assign) BOOL loggingEnabled;
///---------------------------------------
/// @name Add items
///---------------------------------------

/**
 Add item to section 0.
 
 @param item Model you want to add
 */
-(void)addItem:(id)item;

/**
 Add item to section with `sectionNumber`.
 
 @param item Model to add.
 
 @param sectionNumber Section, where item will be added
 */
-(void)addItem:(id)item toSection:(NSUInteger)sectionNumber;

/**
 Add items to section 0.
 
 @param items models to add.
 */
-(void)addItems:(NSArray *)items;

/**
 Add items to section with `sectionNumber`.
 
 @param items Models to add.
 
 @param sectionNumber Section, where items will be added
 */
-(void)addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber;

/**
 Insert item to indexPath `indexPath`.
 
 @param item model to insert.
 
 @param indexPath Index, where item should be inserted.
 
 @warning Inserting item at index, that is not occupied, will not throw an exception, and won't do anything, except logging into console about failure
 */
-(void)insertItem:(id)item toIndexPath:(NSIndexPath *)indexPath;

///---------------------------------------
/// @name Reloading, remove, replace items
///---------------------------------------

/**
 Calling this method causes storage update, that has indexPath of the item in updatedRowIndexPaths property. If storage delegate responds to update, it may proceed with some actions, for example, reload cell, that displays current model.
 
 @param item model, which needs to be reloaded in the cell
 */
-(void)reloadItem:(id)item;

/**
 Removing item. If item is not found, this method does nothing.
 
 @param item Model object you want to remove.
 */
- (void)removeItem:(id)item;

/**
 Removing item at desired indexPath. If number of objects in section is less that indexPath's item, this method does nothing.
 
 @param indexPath Location of item you wish to remove.
 */
- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths;

/**
 Removing items. If some item is not found, it is skipped.
 
 @param items Models you want to remove.
 */
- (void)removeItems:(NSArray *)items;

/**
 Replace itemToReplace with replacingItem. If itemToReplace is not found, or replacingItem is nil, this method does nothing.
 
 @param itemToReplace Model object you want to replace.
 
 @param replacingItem Model object you are replacing it with.
 */
- (void)replaceItem:(id)itemToReplace
           withItem:(id)replacingItem;

///---------------------------------------
/// @name Managing sections
///-------------------------------------

/**
 Deletes one or more sections.
 
 @param indexSet An index set that specifies the sections to delete.
 */
-(void)deleteSections:(NSIndexSet *)indexSet;

/**
 Method to retrieve section model from memory storage. This method safely creates section, if it doesn't exist already.
 
 If you change contents of section manually, delegate update methods do not get called.
 
 @param sectionNumber Number of section to retrieve
 
 @return DTSectionModel instance for current section
 */
- (DTSectionModel *)sectionAtIndex:(NSUInteger)sectionNumber;

/**
 Set supplementary models of specific kind for sections. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section supplementary models.
 
 @param supplementaryModels Section header models to use.
 
 @param kind Kind of supplementary models
 */
- (void)setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind;

/**
 Set header models for sections. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section header models.
 
 @param headerModels Section header models to use.
 */
- (void)setSectionHeaderModels:(NSArray *)headerModels;

/**
 Set header model for section. `DTSectionModel` object is created automatically, if it doesn't exist already.
 
 @param headerModel Section header model to use.
 
 @param sectionNumber Number of the section
 */
- (void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionNumber;

/**
 Set footer model for section. `DTSectionModel` object is created automatically, if it doesn't exist already.
 
 @param footerModel Section header model to use.
 
 @param sectionNumber Number of the section
 */
- (void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionNumber;

/**
 Set footer models for sections. `headerKind` property is used to define kind of header supplementary. `DTSectionModel` objects are created automatically, if they don't exist already. Pass nil or empty array to this method to clear all section footer models.
 
 @param footerModels Section footer models to use.
 */
- (void)setSectionFooterModels:(NSArray *)footerModels;

/**
 Remove all items in section and replace them with array of items. After replacement is done, storageNeedsReload delegate method is called.
 
 @param items Array of models to replace current section contents
 
 @param sectionNumber number of section
 */
- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex;

///---------------------------------------
/// @name Search
///---------------------------------------

typedef BOOL (^DTModelSearchingBlock)(id model, NSString * searchString, NSInteger searchScope, DTSectionModel * section);

/**
 Use this method to add rules for storage to filter models, when using, for example, UISearchBar. This method works similar to deprecated `DTModelSearching` protocol and is a direct replacement for it.
 
 @param searchingBlock Block, that will be executed for all models of modelClass class to filter models for current criteria.
 
 @param modelClass Class of the model, which will use searchingBlock.
 */
-(void)setSearchingBlock:(DTModelSearchingBlock)searchingBlock
           forModelClass:(Class)modelClass;

/**
 Returns array with items in section.
 
 @param sectionNumber Number of the section.
 
 @return array of items in section. If section does not exist - nil.
 */
-(NSArray *)itemsInSection:(NSUInteger)sectionNumber;

/**
 If item exists at `indexPath`, it will be returned. If section or row does not exist, method will return `nil`.
 
 @param indexPath Index of the item you wish to retrieve.
 
 @return model at indexPath. If section or row does not exist - `nil`.
 */

-(id)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 Searches for item and returns it's indexPath. If there are many equal items, indexPath of the first one will be returned.
 
 @param item Item, position of which you wish to find.
 
 @return indexPath of `item`.
 */
-(NSIndexPath *)indexPathForItem:(id)item;

@end
