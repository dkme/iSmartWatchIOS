// PNLineChartView.m
//
// Copyright (c) 2014 John Yung pincution@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "PNBarChartView.h"
#import "PNBar.h"
#import <math.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark -
#pragma mark MACRO

#define POINT_CIRCLE  6.0f
#define NUMBER_VERTICAL_ELEMENTS (5)
#define HORIZONTAL_LINE_SPACES (40)
#define HORIZONTAL_LINE_WIDTH (0.2)
#define HORIZONTAL_START_LINE (0.17)
#define POINTER_WIDTH_INTERVAL  (50)
#define AXIS_FONT_SIZE    (15)

#define AXIS_BOTTOM_LINE_HEIGHT (30)
#define AXIS_LEFT_LINE_WIDTH (35)

#define FLOAT_NUMBER_FORMATTER_STRING  @"%.2f"

#define DEVICE_WIDTH   (320)

#define AXIX_LINE_WIDTH (0.5)

#define BUTTON_TAG_INITIAL_VALUE    (100)
#define BAR_SELECTED_COLOR  [UIColor whiteColor]

#pragma mark -

@interface PNBarChartView ()

@property (nonatomic, strong) NSString* fontName;
@property (nonatomic, assign) CGPoint contentScroll;
@property (nonatomic, strong) PNBar *pnBar;
@property (nonatomic, assign) NSInteger selectedBarButtonTag;
@end


@implementation PNBarChartView
{
    CGRect _touchBeganRect;
    CGRect _touchEndRect;
}


#pragma mark -
#pragma mark init

-(void)commonInit{
    
    self.fontName=@"Helvetica";
    self.numberOfVerticalElements=NUMBER_VERTICAL_ELEMENTS;
    self.xAxisFontColor = [UIColor darkGrayColor];
    self.xAxisFontSize = AXIS_FONT_SIZE;
    self.yAxisFontColor = [UIColor darkGrayColor];
    self.yAxisFontSize = AXIS_FONT_SIZE;
    self.horizontalLinesColor = [UIColor lightGrayColor];
    
    self.horizontalLineInterval = HORIZONTAL_LINE_SPACES;
    self.horizontalLineWidth = HORIZONTAL_LINE_WIDTH;
    
    self.pointerInterval = POINTER_WIDTH_INTERVAL;
    
    self.axisBottomLinetHeight = AXIS_BOTTOM_LINE_HEIGHT;
    self.axisLeftLineWidth = AXIS_LEFT_LINE_WIDTH;
    self.axisLineWidth = AXIX_LINE_WIDTH;
    
    self.floatNumberFormatterString = FLOAT_NUMBER_FORMATTER_STRING;
    
    self.xScrollEanble = NO;
    self.adjustsSelectedBarToShow = YES;
}

- (instancetype)init {
  if((self = [super init])) {
      [self commonInit];
  }
  return self;
}

- (void)awakeFromNib
{
      [self commonInit];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self commonInit];
    }
    return self;
}

#pragma mark -
#pragma mark Plots

- (void)addPlot:(PNBar *)newPlot;
{
    if(nil == newPlot ) {
        return;
    }
    
    if (newPlot.plottingValues.count ==0) {
        return;
    }
    
    
    if(self.plots == nil){
        _plots = [NSMutableArray array];
    }
    
    self.pnBar = newPlot;
    self.selectedBarButtonTag = newPlot.barSelectedTag+BUTTON_TAG_INITIAL_VALUE;
    
    if ([self isNeedXscroll]==YES && self.adjustsSelectedBarToShow) {
        CGFloat startWidth = self.axisLeftLineWidth;
        CGFloat coordinateSystemWidth = self.bounds.size.width-startWidth;
        CGFloat chartWidth = self.pointerInterval*(newPlot.barSelectedTag-1)+self.pnBar.barWidth+self.chartIntervalToYAxis;
        CGFloat mod = Rounded(chartWidth) % Rounded(coordinateSystemWidth);
        int multiple = (chartWidth - coordinateSystemWidth) / coordinateSystemWidth;
        CGFloat offset = multiple * coordinateSystemWidth + mod;
        _contentScroll.x = -1*offset;
    }
    
    [self.plots addObject:newPlot];
    
    [self layoutIfNeeded];
}

-(void)clearPlot{
    if (self.plots) {
        [self.plots removeAllObjects];
    }
}
- (void)update
{
    _contentScroll.x = 0;
    [self setNeedsDisplay];
}

- (BOOL)isNeedXscroll
{
    CGFloat chartWidth = self.pointerInterval*(self.xAxisValues.count-1)+self.pnBar.barWidth+self.chartIntervalToYAxis;
    if (chartWidth > self.frame.size.width) {
        return YES;
    }
    return NO;
}



#pragma mark - Private Methods
- (UIColor *)selectedBarColor
{
//    UIColor *selectedColor = BAR_SELECTED_COLOR;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(barChartView:colorOfselectedBarInPNBar:)]) {
//        selectedColor = [self.delegate barChartView:self colorOfselectedBarInPNBar:self.pnBar];
//    }
//    return selectedColor;
    return self.pnBar.selectedBarColor;
}

#pragma mark -
#pragma mark Draw the lineChart
/*
-(void)drawRect:(CGRect)rect{
    for (UIView *obj in [self subviews]) {
        [obj removeFromSuperview];
    }
    
    CGFloat startHeight = self.axisBottomLinetHeight;//x轴距离view底部的height
    CGFloat startWidth = self.axisLeftLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f , self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    // set text size and font
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    //Y轴文字的属性
    CTFontRef Yctfont = CTFontCreateWithName((CFStringRef)self.fontName, self.yAxisFontSize, NULL);
    CGColorRef YcgColor = [self.yAxisFontColor CGColor];
    // Create an attributed string
    CFStringRef Ykeys[] = {kCTFontAttributeName,kCTForegroundColorAttributeName};
    CFTypeRef Yvalues[] = {Yctfont,YcgColor};
    CFDictionaryRef Yattr = CFDictionaryCreate(NULL, (const void **)&Ykeys, (const void **)&Yvalues, sizeof(Ykeys)/sizeof(Ykeys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // draw yAxis 绘制水平线，不包含X轴
    for (int i=1; i<=self.numberOfVerticalElements; i++) {
        int height =self.horizontalLineInterval*i;
        float verticalLine = height + startHeight - self.contentScroll.y;
        
        [self.horizontalLinesColor set];
        CGContextSetLineWidth(context, self.horizontalLineWidth);
        CGContextMoveToPoint(context, startWidth, verticalLine);
        CGContextAddLineToPoint(context, self.bounds.size.width, verticalLine);
        CGContextStrokePath(context);
        
        //绘制Y轴上的文字
        NSNumber* yAxisVlue = [self.yAxisValues objectAtIndex:i];
        NSString* numberString = [NSString stringWithFormat:self.floatNumberFormatterString, yAxisVlue.floatValue];
        
        CFStringRef ctStr = CFStringCreateWithCString(nil, [numberString UTF8String], kCFStringEncodingUTF8);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,ctStr, Yattr);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextPosition(context, 0, verticalLine - self.yAxisFontSize/2);
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(ctStr);
    }
    CFRelease(Yattr);
    CFRelease(Yctfont);
    
    
    // draw Bar
    for (int i=0; i<self.plots.count; i++)
    {
        PNBar* plot = [self.plots objectAtIndex:i];
        self.pnBar = plot;
        NSArray* pointArray = plot.plottingValues;
        NSArray *barColors = plot.barColors;
        NSArray *barTags = plot.barTags;
        // draw Bar
        for (int i=0; i<pointArray.count; i++) {
            NSNumber* value = [pointArray objectAtIndex:i];
            float floatValue = value.floatValue;
            
            float height = (floatValue-self.min)/self.interval*self.horizontalLineInterval-self.contentScroll.y+startHeight;
            //float width =self.pointerInterval*(i+1)+self.contentScroll.x+ startHeight+5;//感觉没必要+startHeight（与drow lines中的width对应）
            float width =self.pointerInterval*(i+1)+self.contentScroll.x;
            
            if (width<startWidth) {
                NSNumber* nextValue = nil;
                if (i != pointArray.count-1) {
                    nextValue = [pointArray objectAtIndex:i+1];
                } else {
                    nextValue = [pointArray objectAtIndex:i+1];
                }
                float nextFloatValue = nextValue.floatValue;
                float nextHeight = (nextFloatValue-self.min)/self.interval*self.horizontalLineInterval+startHeight;
                
                float nextWidth = width+ self.pointerInterval;
                CGContextMoveToPoint(context, nextWidth, nextHeight);
                continue;
            }
            
            CGRect barRect=CGRectMake(width, startHeight, plot.barWidth, height-startHeight);
            [plot.barOuterColor set];
            CGContextStrokeRect(context, barRect);
            UIColor *color = plot.barColor;
            if ([barColors count] > i) {
                color = barColors[i];
            }
            [color set];
            UIRectFill(barRect);
            
            NSInteger buttonTag = BUTTON_TAG_INITIAL_VALUE;
            if (barTags.count >= pointArray.count) {
                buttonTag = [barTags[i] integerValue]+BUTTON_TAG_INITIAL_VALUE;
            }
            UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect buttonFrame = barRect;
            buttonFrame.origin.y = self.frame.size.height - buttonFrame.origin.y-buttonFrame.size.height;
            tapButton.frame = buttonFrame;
            tapButton.tag = buttonTag;
            if (tapButton.tag == self.selectedBarButtonTag) {
                tapButton.backgroundColor = [self selectedBarColor];
            } else {
                tapButton.backgroundColor = [UIColor clearColor];
            }
            [tapButton addTarget:self action:@selector(clickedTapButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:tapButton];
        }
    }
    
    //绘制x，y轴
    [self.yAxisFontColor set];
    CGContextSetLineWidth(context, self.axisLineWidth);
    CGContextMoveToPoint(context, startWidth, startHeight);
    CGContextAddLineToPoint(context, startWidth, self.bounds.size.height);
    CGContextStrokePath(context);//绘制y轴
    
    [self.horizontalLinesColor set];
    CGContextMoveToPoint(context, startWidth, startHeight);
    CGContextAddLineToPoint(context, self.bounds.size.width, startHeight);
    CGContextStrokePath(context);//绘制x轴
    
    //X轴文字的属性
    // Prepare font
    CTFontRef Xctfont = CTFontCreateWithName((CFStringRef)self.fontName, self.xAxisFontSize, NULL);
    CGColorRef XcgColor = [self.xAxisFontColor CGColor];
    // Create an attributed string
    CFStringRef Xkeys[] = {kCTFontAttributeName,kCTForegroundColorAttributeName};
    CFTypeRef Xvalues[] = {Xctfont,XcgColor};
    CFDictionaryRef Xattr = CFDictionaryCreate(NULL, (const void **)&Xkeys, (const void **)&Xvalues, sizeof(Xkeys)/sizeof(Xkeys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    // x axis text 绘制x坐标
    for (int i=0; i<self.xAxisValues.count; i++) {
        //float width =self.pointerInterval*(i+1)+self.contentScroll.x+ startHeight;//感觉没必要+startHeight（与drow lines中的width对应）
        float width =self.pointerInterval*(i+1)+self.contentScroll.x;
        float height = self.xAxisFontSize;
        if (width<startWidth) {
            continue;
        }
        
        CFStringRef ctStr = CFStringCreateWithCString(nil, [[self.xAxisValues objectAtIndex:i] UTF8String], kCFStringEncodingUTF8);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,ctStr, Xattr);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextPosition(context, width, height);
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(ctStr);
    }
    CFRelease(Xattr);
    CFRelease(Xctfont);
}
*/
-(void)drawRect:(CGRect)rect
{
    //准备上下文(这样做，坐标原点在左下角)
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    [self clearupView];
    [self drawXYAxisAndScale:context];
    [self drawChart:context];
}

- (void)clearupView
{
    for (UIView *obj in [self subviews]) {
        [obj removeFromSuperview];
    }
}

- (void)drawXYAxisAndScale:(CGContextRef)context
{
    CGFloat startHeight = self.axisBottomLinetHeight;//x轴距离view底部的height
    CGFloat startWidth = self.axisLeftLineWidth;//y轴距离view左边的距离
    //绘制x，y轴
    [self.yAxisFontColor set];
    CGContextSetLineWidth(context, self.axisLineWidth);
    CGContextMoveToPoint(context, startWidth, startHeight);
    CGContextAddLineToPoint(context, startWidth, self.bounds.size.height);
    CGContextStrokePath(context);//绘制y轴
    
    [self.horizontalLinesColor set];
    CGContextSetLineWidth(context, self.axisLineWidth);
    CGContextMoveToPoint(context, startWidth, startHeight);
    CGContextAddLineToPoint(context, self.bounds.size.width, startHeight);
    CGContextStrokePath(context);//绘制x轴
    
    //Y轴文字的属性
    CTFontRef Yctfont = CTFontCreateWithName((CFStringRef)self.fontName, self.yAxisFontSize, NULL);
    CGColorRef YcgColor = [self.yAxisFontColor CGColor];
    CFStringRef Ykeys[] = {kCTFontAttributeName,kCTForegroundColorAttributeName};
    CFTypeRef Yvalues[] = {Yctfont,YcgColor};
    CFDictionaryRef Yattr = CFDictionaryCreate(NULL, (const void **)&Ykeys, (const void **)&Yvalues, sizeof(Ykeys)/sizeof(Ykeys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    // draw yAxis 绘制水平线，不包含X轴
    for (int i=1; i<=self.numberOfVerticalElements; i++) {
        int height =self.horizontalLineInterval*i;
        float verticalLine = height + startHeight - self.contentScroll.y;
        
        [self.horizontalLinesColor set];
        CGContextSetLineWidth(context, self.horizontalLineWidth);
        CGContextMoveToPoint(context, startWidth, verticalLine);
        CGContextAddLineToPoint(context, self.bounds.size.width, verticalLine);
        CGContextStrokePath(context);
        
        //绘制Y轴上的文字(刻度)
        NSNumber *yAxisVlue = [self.yAxisValues objectAtIndex:i];
        NSString *numberString = [NSString stringWithFormat:self.floatNumberFormatterString, yAxisVlue.floatValue];
        
        CFStringRef ctStr = CFStringCreateWithCString(nil, [numberString UTF8String], kCFStringEncodingUTF8);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,ctStr, Yattr);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextPosition(context, 0, verticalLine - self.yAxisFontSize/2);
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(ctStr);
    }
    CFRelease(Yattr);
    CFRelease(Yctfont);
    
    
    //X轴文字的属性
    CTFontRef Xctfont = CTFontCreateWithName((CFStringRef)self.fontName, self.xAxisFontSize, NULL);
    CGColorRef XcgColor = [self.xAxisFontColor CGColor];
    CFStringRef Xkeys[] = {kCTFontAttributeName,kCTForegroundColorAttributeName};
    CFTypeRef Xvalues[] = {Xctfont,XcgColor};
    CFDictionaryRef Xattr = CFDictionaryCreate(NULL, (const void **)&Xkeys, (const void **)&Xvalues, sizeof(Xkeys)/sizeof(Xkeys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //绘制x坐标
    for (int i=0; i<self.xAxisValues.count; i++) {
        float width = 0;
        if (i == 0) {
            width = self.chartIntervalToYAxis+self.contentScroll.x+startWidth;
        } else {
            width = self.chartIntervalToYAxis+self.pointerInterval*i+self.contentScroll.x+startWidth;
        }
        float height = self.xAxisFontSize;
        
        NSString *strText = [self.xAxisValues objectAtIndex:i];
        UIFont *theFont = [UIFont fontWithName:self.fontName size:self.xAxisFontSize];
        CGFloat textWidth = [self textSizeWithText:strText font:theFont].width;
        CGFloat x = width+(self.pnBar.barWidth-textWidth)/2;//文字居中显示
        CFStringRef ctStr = CFStringCreateWithCString(nil, [strText UTF8String], kCFStringEncodingUTF8);
        CFAttributedStringRef attrString = CFAttributedStringCreate(NULL,ctStr, Xattr);
        CTLineRef line = CTLineCreateWithAttributedString(attrString);
        CGContextSetTextPosition(context, x, height);
        CTLineDraw(line, context);
        
        CFRelease(line);
        CFRelease(attrString);
        CFRelease(ctStr);
    }
    CFRelease(Xattr);
    CFRelease(Xctfont);
}

- (void)drawChart:(CGContextRef)context
{
    CGFloat startHeight = self.axisBottomLinetHeight;
    CGFloat startWidth = self.axisLeftLineWidth;
    // draw Bar
    for (int i=0; i<self.plots.count; i++)
    {
        PNBar *plot = [self.plots objectAtIndex:i];
        self.pnBar = plot;
        NSArray *pointArray = plot.plottingValues;
        //NSArray *barColors  = plot.barColors;
        NSArray *barTags    = plot.barTags;
        // draw Bar
        for (int i=0; i<pointArray.count; i++) {
            NSNumber *value = [pointArray objectAtIndex:i];
            float floatValue = value.floatValue;
            
            float height = (floatValue-self.min)/self.interval*self.horizontalLineInterval-self.contentScroll.y+startHeight + self.pnBar.barDefaultHeight;
            float width = 0;
            if (i == 0) {
                width = self.chartIntervalToYAxis+self.contentScroll.x+startWidth;
            } else {
                width = self.chartIntervalToYAxis+self.pointerInterval*i+self.contentScroll.x+startWidth;
            }
        
            CGFloat x = width;
            CGRect barRect=CGRectMake(x, startHeight, plot.barWidth, height-startHeight);
            [plot.barOuterColor set];
            CGContextStrokeRect(context, barRect);
            [plot.barColor set];
            UIRectFill(barRect);
            
            NSInteger buttonTag = BUTTON_TAG_INITIAL_VALUE;
            if (barTags.count >= pointArray.count) {
                buttonTag = [barTags[i] integerValue]+BUTTON_TAG_INITIAL_VALUE;
            }
            [self addClickedEvent:barRect tag:buttonTag];
        }
    }
}

- (void)valueToCoordinate
{
    
}

- (void)addClickedEvent:(CGRect)frame tag:(NSInteger)tag
{
    UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = frame;
    buttonFrame.origin.y = self.frame.size.height-frame.origin.y-frame.size.height;
    tapButton.frame = buttonFrame;
    tapButton.tag = tag;
    tapButton.userInteractionEnabled = NO;
    if (tapButton.tag == self.selectedBarButtonTag) {
        //tapButton.backgroundColor = [self selectedBarColor];
        [self clickedTapButton:tapButton];
    } else {
        tapButton.backgroundColor = [UIColor clearColor];
    }
    [tapButton addTarget:self action:@selector(clickedTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tapButton];
}

- (CGSize)textSizeWithText:(NSString *)text font:(UIFont *)font
{
    NSDictionary *attribute = @{NSFontAttributeName:font};
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(100, 0) options:options  attributes:attribute context:nil].size;
    return size;
}


#pragma mark -
#pragma mark touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchPoint=[[touches anyObject] locationInView:self];
    for (UIView *viewObj in self.subviews) {
        if ([viewObj class] == [UIButton class]) {
            UIButton *btn = (UIButton *)viewObj;
            BOOL result = CGRectContainsPoint(btn.frame, touchPoint);
            if (result) {
                _touchBeganRect = btn.frame;
                break;
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    CGPoint touchLocation=[[touches anyObject] locationInView:self];
    CGPoint prevouseLocation=[[touches anyObject] previousLocationInView:self];
    float xDiffrance=touchLocation.x-prevouseLocation.x;
    float yDiffrance=touchLocation.y-prevouseLocation.y;
    
    _contentScroll.x+=xDiffrance;
    _contentScroll.y+=yDiffrance;
    
    if (_contentScroll.x >0) {
        _contentScroll.x=0;
    }
    
    if(_contentScroll.y<0){
        _contentScroll.y=0;
    }
    
    if (-_contentScroll.x>(self.pointerInterval*(self.xAxisValues.count +1)-DEVICE_WIDTH)) {
        _contentScroll.x=-(self.pointerInterval*(self.xAxisValues.count +1)-DEVICE_WIDTH);
    }
    
    if (_contentScroll.y>self.frame.size.height/2) {
        _contentScroll.y=self.frame.size.height/2;
    }
    
    
    _contentScroll.y = 0;// close the move up 禁止y轴滑动
    if ([self isNeedXscroll] == NO) {
        _contentScroll.x = 0;//禁止x轴滑动
    }
    
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint=[[touches anyObject] locationInView:self];
    UIButton *clickBtn = nil;
    for (UIView *viewObj in self.subviews) {
        if ([viewObj class] == [UIButton class]) {
            UIButton *btn = (UIButton *)viewObj;
            BOOL result = CGRectContainsPoint(btn.frame, touchPoint);
            if (result) {
                _touchEndRect = btn.frame;
                clickBtn = btn;
                break;
            }
        }
    }
    
    if (CGRectContainsRect(_touchBeganRect, _touchEndRect) && clickBtn) {
        [self clickedTapButton:clickBtn];
    }
    
    _touchBeganRect = CGRectZero;
    _touchEndRect = CGRectZero;
}


#pragma mark - Action
- (void)clickedTapButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.selectedBarButtonTag = button.tag;
    for (UIView *view in self.subviews) {
        UIButton *obj = (UIButton *)view;
        obj.backgroundColor = [UIColor clearColor];
    }
//    UIColor *selectedColor = BAR_SELECTED_COLOR;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(barChartView:colorOfselectedBarInPNBar:)]) {
//        selectedColor = [self.delegate barChartView:self colorOfselectedBarInPNBar:self.pnBar];
//    }
//    button.backgroundColor = selectedColor;
    button.backgroundColor = [self selectedBarColor];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(barChartView:didSelectBarTag:atPNBar:)]) {
        [self.delegate barChartView:self didSelectBarTag:(button.tag-BUTTON_TAG_INITIAL_VALUE) atPNBar:self.pnBar];
    }
}


@end

