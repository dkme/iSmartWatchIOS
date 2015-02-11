//
//  GGTopMenu.h
//  WMSPlusdot
//
//  Created by Sir on 15-1-29.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGTopMenuDelegate;

@interface GGTopMenu : UIView

//- (id)initWithItems:(NSArray *)items;
- (id)initWithItems:(NSArray *)items selectedItem:(NSInteger)index;

@property (nonatomic, readonly) NSUInteger numberOfItems;
@property (nonatomic, readonly) NSInteger selectedItemIndex;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, assign) CGSize tintSize;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic) CGFloat separatorWidth;
@property (nonatomic, strong) UIColor *separatorColor;


@property (nonatomic, weak) id<GGTopMenuDelegate> delegate;

- (void)reloadView;
- (void)setItems:(NSArray *)items selectedItem:(NSInteger)index;
@end

@protocol GGTopMenuDelegate <NSObject>

@optional
- (void)topMenu:(GGTopMenu *)topMenu didSelectItem:(NSInteger)item;

@end
