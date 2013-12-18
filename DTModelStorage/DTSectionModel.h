//
//  DTCOllectionViewSectionModel.h
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTSection.h"

@interface DTSectionModel : NSObject <DTSection>

/**
 Items for current section
 */
@property (nonatomic, strong) NSMutableArray * objects;

-(id)supplementaryModelOfKind:(NSString *)kind;

-(void)setSupplementaryModel:(id)model forKind:(NSString *)kind;

@end
