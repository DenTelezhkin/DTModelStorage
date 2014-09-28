//
//  DTRuntimeHelper.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTRuntimeHelper.h"

@implementation DTRuntimeHelper

+(NSString *)classStringForClass:(Class)class
{
    return NSStringFromClass(class);
}

+(NSString *)modelStringForClass:(Class)class
{
    return [self classStringForClass:class];
}

@end
