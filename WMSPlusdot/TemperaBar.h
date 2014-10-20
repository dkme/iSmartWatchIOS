//
//  TemperaBar.h
//  TemperaBar
//
//  Created by luyf on 13-2-28.
//  Copyright (c) 2013年 luyf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemperaBar : UIControl
{
@private
    NSInteger _minimumTempera;
    NSInteger _maximumTempera;
    
    NSInteger _currentTempera;
    
    BOOL _isInside;
}
@property (nonatomic) NSInteger currentTempera;

- (id)initWithFrame:(CGRect)frame minimumTempera:(NSInteger)minimumTempera maximumTempera:(NSInteger)maximumTempera;

@end
