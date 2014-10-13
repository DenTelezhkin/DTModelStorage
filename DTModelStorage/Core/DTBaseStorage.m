//
//  DTBaseStorage.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.10.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTBaseStorage.h"

@implementation DTBaseStorage

-(void)setupTableViewSupplementaryKinds
{
    self.supplementaryHeaderKind = DTTableViewElementSectionHeader;
    self.supplementaryFooterKind = DTTableViewElementSectionFooter;
}

-(void)setupCollectionViewSupplementaryKinds
{
    self.supplementaryHeaderKind = UICollectionElementKindSectionHeader;
    self.supplementaryFooterKind = UICollectionElementKindSectionFooter;
}

@end
