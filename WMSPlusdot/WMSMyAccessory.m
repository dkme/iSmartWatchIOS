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
#define KEY_GENERATION          @"generation"
#define KEY_MAC                 @"mac"

@implementation WMSMyAccessory

+ (void)bindAccessory:(NSString *)identifier
{
    NSDictionary *data = @{KEY_IDENTIFIER:identifier};
    
    [data writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}

+ (void)bindAccessoryWith:(NSString *)identifier generation:(AccessoryGeneration)generation
{
    NSDictionary *data = @{KEY_IDENTIFIER:identifier,KEY_GENERATION:@(generation)};
    
    [data writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}

+ (void)unBindAccessory
{
    NSDictionary *data = @{KEY_IDENTIFIER:@"",KEY_GENERATION:@(AccessoryGenerationUnknown),KEY_MAC:@""};
    
    [data writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}

+ (BOOL)isBindAccessory
{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    if (data && [[data objectForKey:KEY_IDENTIFIER] isEqualToString:@""] == NO) {
        return YES;
    }
    
    return NO;
}

+ (AccessoryGeneration)generationForBindAccessory
{
    if ([self isBindAccessory]) {
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
        NSNumber *number = [data objectForKey:KEY_GENERATION];
        if (!number) {
            return AccessoryGenerationUnknown;
        }
        NSInteger gene = [number integerValue];
        return gene;
    }
    return AccessoryGenerationUnknown;
}

+ (NSString *)identifierForbindAccessory
{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    NSString *identifier = [data objectForKey:KEY_IDENTIFIER];
    
    return identifier;
}

+ (void)setBindAccessoryMac:(NSString *)mac
{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    NSMutableDictionary *mutiDic = [NSMutableDictionary dictionaryWithDictionary:data];
    [mutiDic setObject:mac forKey:KEY_MAC];
    
    [mutiDic writeToFile:[self filePath:FILE_ACCESSORY] atomically:YES];
}
+ (NSString *)macForBindAccessory
{
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self filePath:FILE_ACCESSORY]];
    NSString *mac = [data objectForKey:KEY_MAC];
    return mac;
}


+ (NSString *)filePath:(NSString *)fileName
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:fileName];
}

@end
