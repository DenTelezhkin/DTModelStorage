//
//  DTMemoryStorage+UpdateWithoutAnimations.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 03.03.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage.h"

@interface DTMemoryStorage (UpdateWithoutAnimations)

/**
 This method allows multiple simultaneous changes to memory storage without any notifications for delegate. You can think of this as a way of "manual" management for memory storage. Typical usage would be multiple insertions/deletions etc., if you don't need any animations. You can batch any changes in block, and call reloadData on your UI component after this method was call.
 
 @warning You must call reloadData after calling this method, or you will get NSInternalInconsistencyException runtime, thrown by either UITableView or UICollectionView.
 */
-(void)updateWithoutAnimations:(void(^)(void))block;

@end
