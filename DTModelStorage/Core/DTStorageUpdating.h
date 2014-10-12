//
//  DTStorageUpdating.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTStorageUpdate.h"

/**
 `DTStorageUpdating` protocol is used to transfer data storage updates.
 */

@protocol DTStorageUpdating <NSObject>

/**
 Transfers data storage updates. Controller, that implements this method, may react to received update by updating it's UI.
 
 @param update `DTStorageUpdate` instance, that incapsulates all changes, happened in data storage.
 */
- (void)storageDidPerformUpdate:(DTStorageUpdate *)update;

/**
 Method is called when UI needs to be fully updated for data storage changes.
 */
- (void)storageNeedsReload;

@end
