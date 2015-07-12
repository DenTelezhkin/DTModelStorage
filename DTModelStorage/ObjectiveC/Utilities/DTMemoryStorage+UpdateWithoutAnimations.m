//
//  DTMemoryStorage+UpdateWithoutAnimations.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 03.03.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage+UpdateWithoutAnimations.h"

@implementation DTMemoryStorage (UpdateWithoutAnimations)

- (void)updateWithoutAnimations:(void (^)(void))block
{
    id delegate = self.delegate;
    self.delegate = nil;

    if (block)
    {
        block();
    }
    self.delegate = delegate;
}

@end
