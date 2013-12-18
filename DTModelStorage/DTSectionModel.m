//
//  DTCOllectionViewSectionModel.m
//  DTCollectionViewManagerExample
//
//  Created by Denys Telezhkin on 15.12.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTSectionModel.h"

@interface DTSectionModel()
@property (nonatomic, strong) NSMutableDictionary * supplementaries;
@end

@implementation DTSectionModel

-(NSMutableArray *)objects
{
    if (!_objects)
    {
        _objects = [NSMutableArray array];
    }
    return _objects;
}

-(NSMutableDictionary *)supplementaries
{
    if (!_supplementaries)
    {
        _supplementaries = [NSMutableDictionary dictionary];
    }
    return _supplementaries;
}

-(NSUInteger)numberOfObjects
{
    return [self.objects count];
}

-(void)setSupplementaryModel:(id)model forKind:(NSString *)kind
{
    self.supplementaries[kind] = model;
}

-(id)supplementaryModelOfKind:(NSString *)kind
{
    return self.supplementaries[kind];
}

@end
