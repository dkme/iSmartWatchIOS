//
//  Activity.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-11.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "Activity.h"

@implementation Activity

//- (id)initWithID:(int)pID actName:(NSString *)pActName beginDate:(NSDate *)pBeginDate endDate:(NSDate *)pEndDate memo:(NSString *)pMemo gameName:(NSString *)pGameName logo:(NSString *)pLogo
//{
//    if (self = [super init]) {
//        _actID = pID;
//        _actName = pActName;
//        _beginDate = pBeginDate;
//        _endDate = pEndDate;
//        _memo = pMemo;
//        _gameName = pGameName;
//        _logo = pLogo;
//    }
//    return self;
//}

- (id)copyWithZone:(NSZone *)zone
{
    Activity *copy = [[Activity allocWithZone:zone] init];
    copy.actID = _actID;
    copy.actName = [_actName copy];
    copy.beginDate = [_beginDate copy];
    copy.endDate = [_endDate copy];
    copy.actMemo = [_actMemo copy];
    copy.gameName = [_gameName copy];
    copy.logo = [_logo copy];
    copy.consumeBeans = _consumeBeans;
    return copy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[actID=%d,actName=%@,beginDate=%@,endDate=%@,memo=%@,gameName=%@,logo=%@,consumeBeans=%d]",_actID,_actName,[_beginDate description],[_endDate description],_actMemo,_gameName,_logo,_consumeBeans];
}

@end
