//
//  WMSMutableArray+Stack.m
//  WMSPlusdot
//
//  Created by John on 14-9-5.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

+ (void)push:(id)anObject toArray:(NSMutableArray *)aArray
{
    [aArray addObject:anObject];
}

+ (id)popFromArray:(NSMutableArray *)aArray
{
    id aObject = nil;
    if ([aArray count] > 0) {
        aObject = [aArray objectAtIndex:0];
        [aArray removeObjectAtIndex:0];
    }
    return aObject;
}

- (void)push:(id)anObject
{
    [[self class] push:anObject toArray:self];
}
- (void)pop
{
    [[self class] popFromArray:self];
}
- (void)clear
{
    [self removeAllObjects];
}

@end
