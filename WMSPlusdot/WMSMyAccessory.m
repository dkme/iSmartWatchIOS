//
//  WMSMyAccessory.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSMyAccessory.h"
#import "WMSFileMacro.h"

#define KEY_IDENTIFIER          @"identifier"

@implementation WMSMyAccessory

+ (void)bindAccessory:(NSString *)identifier
{
    //NSArray *data = @[@(1)];
    NSDictionary *data = @{KEY_IDENTIFIER:identifier};
    
    [data writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}

+ (void)unBindAccessory
{
    //NSArray *data = @[@(0)];
    NSDictionary *data = @{KEY_IDENTIFIER:@""};
    
    [data writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}

+ (BOOL)isBindAccessory
{
    //NSArray *data = [NSArray arrayWithContentsOfFile:[self filePath:AccessoryFileName]];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    if (data && [[data objectForKey:KEY_IDENTIFIER] isEqualToString:@""] == NO) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)identifierForbindAccessory
{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    NSString *identifier = [data objectForKey:KEY_IDENTIFIER];
    
    return identifier;
}


+ (NSString *)filePath:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:fileName];
}

@end
