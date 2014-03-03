//
//  DTMemoryStorage+UpdateWithoutAnimations.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 03.03.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage.h"

@interface DTMemoryStorage (UpdateWithoutAnimations)

-(void)updateWithoutAnimations:(void(^)(void))block;

@end
