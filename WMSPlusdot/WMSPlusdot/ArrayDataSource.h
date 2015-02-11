//
//  ArrayDataSource.h
//  WMSPlusdot
//
//  Created by Sir on 15-2-2.
//  Copyright (c) 2015年 GUOGEE. All rights reserved.
//

typedef void (^TableViewCellConfigureBlock)(id cell, id item);
typedef id (^TableViewConfigureBlock)(UITableView *, NSIndexPath *, NSArray *);


@interface ArrayDataSource : NSObject <UITableViewDataSource>

- (id)initWithItems:(NSArray *)anItems
     cellIdentifier:(NSString *)aCellIdentifier
 configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;

- (id)initWithItems:(NSArray *)anItems
 configureTableViewBlock:(TableViewConfigureBlock)aConfigureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSArray *items;

@end
