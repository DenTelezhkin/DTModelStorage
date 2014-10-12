//
//  DTMemoryStorage.m
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

#import "DTMemoryStorage.h"
#import "DTSection.h"
#import "DTStorageUpdate.h"
#import "DTSectionModel.h"
#import "DTRuntimeHelper.h"

@interface DTMemoryStorage ()
@property (nonatomic, strong) DTStorageUpdate * currentUpdate;
@property (nonatomic, retain) NSMutableDictionary * searchingBlocks;
@end

@implementation DTMemoryStorage

+ (instancetype)storage
{
    DTMemoryStorage * storage = [self new];

    storage.sections = [NSMutableArray array];

    storage.loggingEnabled = YES;

    return storage;
}

- (NSMutableDictionary *)searchingBlocks
{
    if (!_searchingBlocks)
    {
        _searchingBlocks = [NSMutableDictionary dictionary];
    }
    return _searchingBlocks;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    id <DTSection> sectionModel = nil;
    if (indexPath.section >= self.sections.count)
    {
        return nil;
    }
    else
    {
        sectionModel = [self sections][indexPath.section];
        if (indexPath.item >= [sectionModel numberOfObjects])
        {
            return nil;
        }
    }

    return [sectionModel.objects objectAtIndex:indexPath.row];
}

- (id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    DTSectionModel * sectionModel = nil;
    if (sectionNumber >= self.sections.count)
    {
        return nil;
    }
    else
    {
        sectionModel = [self sections][sectionNumber];
    }
    return [sectionModel supplementaryModelOfKind:kind];
}

-(void)setSectionHeaderModel:(id)headerModel forSectionIndex:(NSUInteger)sectionNumber
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method");
    
    DTSectionModel * section = [self sectionAtIndex:sectionNumber];
    
    [section setSupplementaryModel:headerModel forKind:self.supplementaryHeaderKind];
}

-(void)setSectionFooterModel:(id)footerModel forSectionIndex:(NSUInteger)sectionNumber
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method");
    
    DTSectionModel * section = [self sectionAtIndex:sectionNumber];
    
    [section setSupplementaryModel:footerModel forKind:self.supplementaryFooterKind];
}

-(id)headerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryHeaderKind, @"supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryHeaderKind
                          forSectionIndex:index];
}

-(id)footerModelForSectionIndex:(NSInteger)index
{
    NSAssert(self.supplementaryFooterKind, @"supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method");
    
    return [self supplementaryModelOfKind:self.supplementaryFooterKind
                          forSectionIndex:index];
}

- (void)setSupplementaries:(NSArray *)supplementaryModels forKind:(NSString *)kind
{
    [self startUpdate];
    if (!supplementaryModels || [supplementaryModels count] == 0)
    {
        for (DTSectionModel * section in self.sections)
        {
            [section setSupplementaryModel:nil forKind:kind];
        }
        return;
    }
    [self getValidSection:([supplementaryModels count] - 1)];

    for (NSUInteger sectionNumber = 0; sectionNumber < [supplementaryModels count]; sectionNumber++)
    {
        DTSectionModel * section = self.sections[sectionNumber];
        [section setSupplementaryModel:supplementaryModels[sectionNumber] forKind:kind];
    }
    [self finishUpdate];
}

- (void)setItems:(NSArray *)items forSectionIndex:(NSUInteger)sectionIndex
{
    DTSectionModel * section = [self sectionAtIndex:sectionIndex];
    [section.objects removeAllObjects];
    [section.objects addObjectsFromArray:items];
    [self.delegate storageNeedsReload];
}

-(void)setSectionHeaderModels:(NSArray *)headerModels
{
    NSAssert(self.supplementaryHeaderKind, @"Please set supplementaryHeaderKind property before setting section header models");
    
    [self setSupplementaries:headerModels forKind:self.supplementaryHeaderKind];
}

-(void)setSectionFooterModels:(NSArray *)footerModels
{
    NSAssert(self.supplementaryFooterKind, @"Please set supplementaryFooterKind property before setting section header models");
    
    [self setSupplementaries:footerModels forKind:self.supplementaryFooterKind];
}

#pragma mark - search

- (void)setSearchingBlock:(DTModelSearchingBlock)searchingBlock
            forModelClass:(Class)modelClass
{
    NSParameterAssert(searchingBlock);
    NSParameterAssert(modelClass);

    self.searchingBlocks[[DTRuntimeHelper modelStringForClass:modelClass]] = searchingBlock;
}

- (instancetype)searchingStorageForSearchString:(NSString *)searchString
                                  inSearchScope:(NSUInteger)searchScope
{
    DTMemoryStorage * storage = [[self class] storage
    ];

    for (NSUInteger sectionNumber = 0; sectionNumber < [self.sections count]; sectionNumber++)
    {
        DTSectionModel * searchSection = [self filterSection:self.sections[sectionNumber]
                                            withSearchString:searchString
                                                 searchScope:searchScope];
        if (searchSection)
        {
            [storage.sections addObject:searchSection];
        }
    }
    storage.supplementaryHeaderKind = self.supplementaryHeaderKind;
    storage.supplementaryFooterKind = self.supplementaryFooterKind;

    return storage;
}

- (DTSectionModel *)filterSection:(DTSectionModel *)section
                 withSearchString:(NSString *)searchString
                      searchScope:(NSInteger)searchScope
{
    NSMutableArray * searchResults = [NSMutableArray array];
    for (NSUInteger row = 0; row < section.objects.count; row++)
    {
        NSObject * item = section.objects[row];

        if (self.searchingBlocks[[DTRuntimeHelper modelStringForClass:item.class]])
        {
            DTModelSearchingBlock block = self.searchingBlocks[[DTRuntimeHelper modelStringForClass:item.class]];

            if (block && block(item, searchString, searchScope, section))
            {
                [searchResults addObject:item];
            }
        }
    }
    if ([searchResults count])
    {
        DTSectionModel * searchSection = [section copy];
        searchSection.objects = searchResults;
        return searchSection;
    }
    return nil;
}

#pragma mark - Updates

- (void)startUpdate
{
    self.currentUpdate = [DTStorageUpdate new];
}

- (void)finishUpdate
{
    if ([self.delegate respondsToSelector:@selector(storageDidPerformUpdate:)])
    {
        [self.delegate storageDidPerformUpdate:self.currentUpdate];
    }
    self.currentUpdate = nil;
}

#pragma mark - Adding items

- (void)addItem:(id)item
{
    [self addItem:item toSection:0];
}

- (void)addItem:(id)item toSection:(NSUInteger)sectionNumber
{
    [self startUpdate];

    DTSectionModel * section = [self getValidSection:sectionNumber];
    NSUInteger numberOfItems = [section numberOfObjects];
    [section.objects addObject:item];
    [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                           inSection:sectionNumber]];

    [self finishUpdate];
}

- (void)addItems:(NSArray *)items
{
    [self addItems:items toSection:0];
}

- (void)addItems:(NSArray *)items toSection:(NSUInteger)sectionNumber
{
    [self startUpdate];

    DTSectionModel * section = [self getValidSection:sectionNumber];

    for (id item in items)
    {
        NSUInteger numberOfItems = [section numberOfObjects];
        [section.objects addObject:item];
        [self.currentUpdate.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:numberOfItems
                                                                               inSection:sectionNumber]];
    }

    [self finishUpdate];
}

- (void)insertItem:(id)item toIndexPath:(NSIndexPath *)indexPath
{
    [self startUpdate];
    // Update datasource
    DTSectionModel * section = [self getValidSection:indexPath.section];

    if ([section.objects count] < indexPath.row)
    {
        if (self.loggingEnabled)
        {
            NSLog(@"DTMemoryStorage: failed to insert item for section: %ld, row: %ld, only %lu items in section",
                    (long)indexPath.section,
                    (long)indexPath.row,
                    (unsigned long)[section.objects count]);
        }
        return;
    }
    [section.objects insertObject:item atIndex:indexPath.row];

    [self.currentUpdate.insertedRowIndexPaths addObject:indexPath];

    [self finishUpdate];
}

- (void)reloadItem:(id)item
{
    [self startUpdate];

    NSIndexPath * indexPathToReload = [self indexPathForItem:item];

    if (indexPathToReload)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPathToReload];
    }

    [self finishUpdate];
}

- (void)replaceItem:(id)itemToReplace
           withItem:(id)replacingItem
{
    [self startUpdate];

    NSIndexPath * originalIndexPath = [self indexPathForItem:itemToReplace];
    if (originalIndexPath && replacingItem)
    {
        DTSectionModel * section = [self getValidSection:originalIndexPath.section];

        [section.objects replaceObjectAtIndex:originalIndexPath.row
                                   withObject:replacingItem];
    }
    else
    {
        if (self.loggingEnabled)
        {
            NSLog(@"DTMemoryStorage: failed to replace item %@ at indexPath: %@", replacingItem, originalIndexPath);
        }
        return;
    }

    [self.currentUpdate.updatedRowIndexPaths addObject:originalIndexPath];

    [self finishUpdate];
}

#pragma mark - Removing items

- (void)removeItem:(id)item
{
    [self startUpdate];

    NSIndexPath * indexPath = [self indexPathForItem:item];

    if (indexPath)
    {
        DTSectionModel * section = [self getValidSection:indexPath.section];
        [section.objects removeObjectAtIndex:indexPath.row];
    }
    else
    {
        if (self.loggingEnabled)
        {
            NSLog(@"DTMemoryStorage: item to delete: %@ was not found", item);
        }
        return;
    }
    [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    [self finishUpdate];
}

- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self startUpdate];
    for (NSIndexPath * indexPath in indexPaths)
    {
        id object = [self objectAtIndexPath:indexPath];

        if (object)
        {
            DTSectionModel * section = [self getValidSection:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
            [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
        }
        else
        {
            if (self.loggingEnabled)
            {
                NSLog(@"DTMemoryStorage: item to delete was not found at indexPath : %@ ", indexPath);
            }
        }
    }
    [self finishUpdate];
}

- (void)removeItems:(NSArray *)items
{
    [self startUpdate];

    NSArray * indexPaths = [self indexPathArrayForItems:items];

    for (NSObject * item in items)
    {
        NSIndexPath * indexPath = [self indexPathForItem:item];

        if (indexPath)
        {
            DTSectionModel * section = [self getValidSection:indexPath.section];
            [section.objects removeObjectAtIndex:indexPath.row];
        }
    }
    [self.currentUpdate.deletedRowIndexPaths addObjectsFromArray:indexPaths];
    [self finishUpdate];
}

#pragma  mark - Sections

- (void)deleteSections:(NSIndexSet *)indexSet
{
    [self startUpdate];
    // Update datasource
    [self.sections removeObjectsAtIndexes:indexSet];

    // Update interface
    [self.currentUpdate.deletedSectionIndexes addIndexes:indexSet];

    [self finishUpdate];
}

#pragma mark - Search

- (NSArray *)itemsInSection:(NSUInteger)sectionNumber
{
    if ([self.sections count] > sectionNumber)
    {
        DTSectionModel * section = self.sections[sectionNumber];
        return [section objects];
    }
    else
    {
        return nil;
    }
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * section = nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self itemsInSection:indexPath.section];
    }
    else
    {
        if (self.loggingEnabled)
        {
            NSLog(@"DTMemoryStorage: Section not found while searching for item");
        }
        return nil;
    }

    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else
    {
        if (self.loggingEnabled)
        {
            NSLog(@"DTMemoryStorage: Row not found while searching for item");
        }
        return nil;
    }
}

- (NSIndexPath *)indexPathForItem:(id)item
{
    for (NSUInteger sectionNumber = 0; sectionNumber < self.sections.count; sectionNumber++)
    {
        NSArray * rows = [self.sections[sectionNumber] objects];
        NSUInteger index = [rows indexOfObject:item];

        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:sectionNumber];
        }
    }
    return nil;
}

- (DTSectionModel *)sectionAtIndex:(NSUInteger)sectionNumber
{
    [self startUpdate];
    DTSectionModel * section = [self getValidSection:sectionNumber];
    [self finishUpdate];

    return section;
}

#pragma mark - private

- (DTSectionModel *)getValidSection:(NSUInteger)sectionNumber
{
    if (sectionNumber < self.sections.count)
    {
        return self.sections[sectionNumber];
    }
    else
    {
        for (NSInteger i = self.sections.count; i <= sectionNumber; i++)
        {
            DTSectionModel * section = [DTSectionModel new];
            [self.sections addObject:section];

            [self.currentUpdate.insertedSectionIndexes addIndex:i];
        }
        return [self.sections lastObject];
    }
}

//This implementation is not optimized, and may behave poorly with lot of sections
- (NSArray *)indexPathArrayForItems:(NSArray *)items
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[items count]];

    for (NSInteger i = 0; i < [items count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathForItem:[items objectAtIndex:i]];
        if (!foundIndexPath)
        {
            if (self.loggingEnabled)
            {
                NSLog(@"DTMemoryStorage: object %@ not found",
                        [items objectAtIndex:i]);
            }
        }
        else
        {
            [indexPaths addObject:foundIndexPath];
        }
    }
    return indexPaths;
}

@end
