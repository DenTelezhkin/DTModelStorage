//
//  DTRuntimeHelper.h
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

@interface DTRuntimeHelper : NSObject

+ (NSString *)classStringForClass:(Class)class;
+ (NSString *)modelStringForClass:(Class)class;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif

