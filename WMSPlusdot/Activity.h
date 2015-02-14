//
//  Activity.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject /*<NSCopying>*/

@property (nonatomic) int actID;
@property (nonatomic, strong) NSString *actName;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) NSString *logo;

- (id)initWithID:(int)pID actName:(NSString *)pActName beginDate:(NSDate *)pBeginDate endDate:(NSDate *)pEndDate memo:(NSString *)pMemo gameName:(NSString *)pGameName logo:(NSString *)pLogo;

@end
