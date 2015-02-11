//
//  GGTopMenu.m
//  WMSPlusdot
//
//  Created by Sir on 15-1-29.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "GGTopMenu.h"

static const NSInteger START_TAG_BUTTON                 = 1000;
static const NSInteger START_TAG_TINTVIEW               = 2000;

static const CGFloat BUTTON_TO_SEPARATOR_INTERVAL       = 5.0;
static const CGFloat SEPARATOR_WIDTH                    = 2.0;

@interface GGTopMenu ()
{
    NSInteger currentSelectedItem;
}

@end

@implementation GGTopMenu

- (id)initWithItems:(NSArray *)items selectedItem:(NSInteger)index
{
    self = [super initWithFrame:CGRectMake(0, 0, 40, 30)];
    if (self) {
        _items = items;
        _selectedItemIndex = index;
        _numberOfItems = items.count;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.tintSize = CGSizeZero;
    self.tintColor = [UIColor whiteColor];
    self.titleColor = [UIColor whiteColor];
    self.separatorWidth = SEPARATOR_WIDTH;
    self.separatorColor = [UIColor whiteColor];
}

- (void)reloadView
{
    [self setupMenu:self.items selectItem:self.selectedItemIndex];
}

- (void)setItems:(NSArray *)items selectedItem:(NSInteger)index
{
    _items = items;
    _selectedItemIndex = index;
    _numberOfItems = items.count;
    [self setupMenu:items selectItem:index];
}

- (void)setupMenu:(NSArray *)items selectItem:(NSInteger)index
{
    if (items.count <= 0) {
        return ;
    }
    [self clearupView];
    currentSelectedItem = index;
    NSInteger tag = START_TAG_BUTTON;
    CGFloat menuWidth = 0;
    CGFloat buttonWidth = (self.frame.size.width-BUTTON_TO_SEPARATOR_INTERVAL*items.count-1) / items.count;
    NSUInteger i = 0;
    for (NSString *title in items) {
        UIButton *vButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [vButton setTitle:title forState:UIControlStateNormal];
        [vButton setTitleColor:self.titleColor forState:UIControlStateNormal];
        [vButton setTag:tag];
        [vButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [vButton setFrame:CGRectMake(menuWidth, 0, buttonWidth, self.frame.size.height-self.tintSize.height)];
        UIView *tintView = [[UIView alloc] init];
        tintView.tag = tag + START_TAG_TINTVIEW;
        tintView.frame = (CGRect){menuWidth+(buttonWidth-self.tintSize.width)/2.0,vButton.frame.origin.y+vButton.frame.size.height,self.tintSize};
        if (tag-START_TAG_BUTTON == currentSelectedItem) {
            tintView.backgroundColor = self.tintColor;
        } else {
            tintView.backgroundColor = vButton.backgroundColor;
        }
        [self addSubview:vButton];
        [self addSubview:tintView];
        if (i == items.count-1) {
            return ;
        }
        CGSize size = CGSizeMake(self.separatorWidth, self.frame.size.height/2.0);
        CGPoint or = CGPointZero;
        or.x = menuWidth+buttonWidth+((BUTTON_TO_SEPARATOR_INTERVAL-size.width)/2.0);
        or.y = (self.frame.size.height-size.height)/2.0;
        UIView *separator = [[UIView alloc] initWithFrame:(CGRect){or,size}];
        separator.backgroundColor = self.separatorColor;
        [self addSubview:separator];
        
        i ++;
        tag ++;
        menuWidth += buttonWidth+BUTTON_TO_SEPARATOR_INTERVAL;
    }
}

- (void)menuButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger selectedItem = button.tag-START_TAG_BUTTON;
    if (currentSelectedItem == selectedItem) {
        return ;
    }
    UIView *oldTintView = [self viewWithTag:currentSelectedItem+START_TAG_BUTTON+START_TAG_TINTVIEW];
    UIView *newTintView = [self viewWithTag:selectedItem+START_TAG_BUTTON+START_TAG_TINTVIEW];
    oldTintView.backgroundColor = [button backgroundColor];
    newTintView.backgroundColor = self.tintColor;
    currentSelectedItem = selectedItem;
    _selectedItemIndex = currentSelectedItem;
    if (self.delegate && [self.delegate respondsToSelector:@selector(topMenu:didSelectItem:)]) {
        [self.delegate topMenu:self didSelectItem:selectedItem];
    }
    
}

- (void)clearupView
{
    for (UIView *obj in [self subviews]) {
        [obj removeFromSuperview];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
