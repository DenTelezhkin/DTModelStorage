//
//  DTCoreDataStorage.m
//  DTModelStorage
//
//  Created by Denys Telezhkin on 07.12.13.
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

#import "DTCoreDataStorage.h"

@interface DTCoreDataStorage ()
@property (nonatomic, strong) DTStorageUpdate * currentUpdate;
@property (nonatomic, strong, readwrite) NSFetchedResultsController * fetchedResultsController;
@end

@implementation DTCoreDataStorage

+ (instancetype)storageWithFetchResultsController:(NSFetchedResultsController *)controller
{
    DTCoreDataStorage * storage = [self new];

    storage.fetchedResultsController = controller;
    storage.fetchedResultsController.delegate = storage;

    return storage;
}

- (NSArray *)sections
{
    return [self.fetchedResultsController sections];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
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

-(id)supplementaryModelOfKind:(NSString *)kind forSectionIndex:(NSUInteger)sectionNumber
{
    if ([kind isEqualToString:self.supplementaryHeaderKind])
    {
        id <NSFetchedResultsSectionInfo> section = [self.fetchedResultsController sections][sectionNumber];
        return section.name;
    }
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self startUpdate];
}

/*
 Thanks to Michael Fey for NSFetchedResultsController updates done right!
 http://www.fruitstandsoftware.com/blog/2013/02/uitableview-and-nsfetchedresultscontroller-updates-done-right/
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert)
    {
        if ([self.currentUpdate.insertedSectionIndexes containsIndex:newIndexPath.section])
        {
            // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
            return;
        }

        [self.currentUpdate.insertedRowIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete)
    {
        if ([self.currentUpdate.deletedSectionIndexes containsIndex:indexPath.section])
        {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }

        [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove)
    {
        if ([self.currentUpdate.insertedSectionIndexes containsIndex:newIndexPath.section] == NO)
        {
            [self.currentUpdate.insertedRowIndexPaths addObject:newIndexPath];
        }

        if ([self.currentUpdate.deletedSectionIndexes containsIndex:indexPath.section] == NO)
        {
            [self.currentUpdate.deletedRowIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeUpdate)
    {
        [self.currentUpdate.updatedRowIndexPaths addObject:indexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.currentUpdate.insertedSectionIndexes addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.currentUpdate.deletedSectionIndexes addIndex:sectionIndex];
            break;
        default:; // Shouldn't have a default
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self finishUpdate];
}

@end
