//
//  ArrayDataSource.m
//  WMSPlusdot
//
//  Created by Sir on 15-2-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()
//@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) TableViewConfigureBlock configureTableViewBlock;
@end


@implementation ArrayDataSource

- (id)init
{
    return nil;
}

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = [anItems copy];
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)initWithItems:(NSArray *)anItems
configureTableViewBlock:(TableViewConfigureBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = [anItems copy];
        //self.cellIdentifier = aCellIdentifier;
        self.configureTableViewBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[(NSUInteger) indexPath.row];
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.configureCellBlock) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                                forIndexPath:indexPath];
        id item = [self itemAtIndexPath:indexPath];
        self.configureCellBlock(cell, item);
        return cell;
    }
    
    if (self.configureTableViewBlock) {
        UITableViewCell *cell = self.configureTableViewBlock(tableView,indexPath,self.items);
        return cell;
    }
    
    return nil;
}

- (void)dealloc
{
    DEBUGLog(@"%s",__FUNCTION__);
}

@end
