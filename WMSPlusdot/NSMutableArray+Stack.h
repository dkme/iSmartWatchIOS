//
//  WMSMutableArray+Stack.h
//  WMSPlusdot
//
//  Created by John on 14-9-5.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

/**
 压入一个对象到数值中
 */
+ (void)push:(id)anObject toArray:(NSMutableArray *)aArray;
- (void)push:(id)anObject;

/**
 从数值中pop出一个对象
 */
+ (id)popFromArray:(NSMutableArray *)aArray;
- (id)pop;

- (void)clear;

@end
