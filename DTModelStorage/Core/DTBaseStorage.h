//
//  DTBaseStorage.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTStorageProtocol.h"

/**
 DTBaseStorage is a base class for storage classes.
 */

@interface DTBaseStorage : NSObject

/**
 Supplementary header kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindHeader.
 */
@property (nonatomic, strong) NSString * supplementaryHeaderKind;

/**
 Supplementary footer kind, that is used for registration and mapping. For example, for UICollectionView this should be UICollectionElementKindFooter.
 */
@property (nonatomic, strong) NSString * supplementaryFooterKind;

/**
 Delegate property used to transfer current data storage changes.
 */
@property (nonatomic, weak) id <DTStorageUpdating> delegate;

@end
