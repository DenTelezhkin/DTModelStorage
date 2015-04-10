//
//  DTBaseStorage.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTStorageProtocol.h"

#pragma clang assume_nonnull begin

static NSString * const DTTableViewElementSectionHeader = @"DTTableViewElementSectionHeader";
static NSString * const DTTableViewElementSectionFooter = @"DTTableViewElementSectionFooter";

/**
 DTBaseStorage is a base class for storage classes.
 */

@interface DTBaseStorage : NSObject

/**
 Supplementary header kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindSectionHeader.
 */
@property (nonatomic, strong, nullable) NSString * supplementaryHeaderKind;

/**
 Supplementary footer kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindSectionFooter.
 */
@property (nonatomic, strong, nullable) NSString * supplementaryFooterKind;

/**
 Delegate property used to transfer current data storage changes.
 */
@property (nonatomic, weak, nullable) id <DTStorageUpdating> delegate;

@end

#pragma clang assume_nonnull end
