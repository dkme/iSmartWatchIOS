//
//  WMSSportDatabase.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-16.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSportDatabase.h"
#import "sqlite3.h"
#import "WMSSportModel.h"
#import "NSDate+Formatter.h"

#define DatabaseName    @"sportData.db"
#define TableName       @"SportDataTable"

@implementation WMSSportDatabase
{
    sqlite3 *_database;
}

#pragma mark - Public Methods
+ (WMSSportDatabase *)sportDatabase
{
    static dispatch_once_t onceToken = 0;
    __strong static WMSSportDatabase *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[WMSSportDatabase alloc] init];
    });
    return sharedObject;
}

- (BOOL)insertSportData:(WMSSportModel *)model
{
    //先判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement;
        
        //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
        char *sql = "INSERT INTO SportDataTable(sportDate, targetSteps, sportSteps, sportDurations, sportDistance, sportCalorie, perHourData, dataLength) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        
        int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success2 != SQLITE_OK) {
            NSLog(@"Error: failed to insert:testTable");
            sqlite3_close(_database);
            return NO;
        }
        
        //这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
        //DEBUGLog(@"write date:%@",model.sportDate);
        NSString *strDate = [model.sportDate.description substringToIndex:10];
        //printf("write dateString:%s \n",[strDate UTF8String]);
        sqlite3_bind_text(statement, 1, [strDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, model.targetSteps);
        sqlite3_bind_int(statement, 3, model.sportSteps);
        sqlite3_bind_int(statement, 4, model.sportMinute);
        sqlite3_bind_int(statement, 5, model.sportDistance);
        sqlite3_bind_int(statement, 6, model.sportCalorie);
        int len = 0;
        if (model.dataLength > 0) {
            len = sizeof(model.perHourData[0]) * model.dataLength;
        }
        sqlite3_bind_blob(statement, 7, model.perHourData, len, SQLITE_STATIC);
        sqlite3_bind_int(statement, 8, model.dataLength);
        
        //执行插入语句
        success2 = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果插入失败
        if (success2 == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
            //关闭数据库
            sqlite3_close(_database);
            return NO;
        }
        //关闭数据库
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}

//获取数据
- (NSArray *)queryAllSportData
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    //判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement = nil;
        //sql语句
        char *sql = "SELECT * FROM SportDataTable";//从testTable这个表中获取 testID, testValue ,testName，若获取全部的话可以用*代替testID, testValue ,testName。
        
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            sqlite3_finalize(statement);
            sqlite3_close(_database);
            return nil;
        }
        else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *strDate = (char *)sqlite3_column_text(statement, 1);
                NSString *stringDate = [NSString stringWithUTF8String:strDate];
                //stringDate = [stringDate substringToIndex:10];
                //printf("read DateString:%s \n",strDate);
                //DEBUGLog(@"read stringDate:%@",stringDate);
                
                NSUInteger targetSteps = sqlite3_column_int(statement, 2);
                NSUInteger steps = sqlite3_column_int(statement, 3);
                NSUInteger durations = sqlite3_column_int(statement, 4);
                NSUInteger distance = sqlite3_column_int(statement, 5);
                NSUInteger calorie = sqlite3_column_int(statement, 6);
                
                int size = sqlite3_column_bytes(statement, 7);
                UInt16 *perHourData = malloc(size);
                memcpy(perHourData, sqlite3_column_blob(statement, 7), size);
                
                NSUInteger dataLength = sqlite3_column_int(statement, 8);
                
                //DEBUGLog(@"read string to date:%@",[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]);
                WMSSportModel *model = [[WMSSportModel alloc] initWithSportDate:[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]  sportTargetSteps:(targetSteps) sportSteps:steps sportMinute:durations sportDistance:distance sportCalorie:calorie perHourData:perHourData dataLength:dataLength];
                
                [array addObject:model];
                free(perHourData);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_database);
    }
    
    return array;
}
//查询指定的数据
- (NSArray *)querySportData:(NSDate *)sportDate
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    //判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement = nil;
        //sql语句
        char *sql = "SELECT * FROM SportDataTable WHERE sportDate = ?";
        
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            sqlite3_finalize(statement);
            sqlite3_close(_database);
            return nil;
        }
        else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            
            NSString *strDate = [sportDate.description substringToIndex:10];
            sqlite3_bind_text(statement, 1, [strDate UTF8String], -1, SQLITE_TRANSIENT);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *strDate = (char *)sqlite3_column_text(statement, 1);
                NSString *stringDate = [NSString stringWithUTF8String:strDate];
                
                NSUInteger targetSteps = sqlite3_column_int(statement, 2);
                NSUInteger steps = sqlite3_column_int(statement, 3);
                NSUInteger durations = sqlite3_column_int(statement, 4);
                NSUInteger distance = sqlite3_column_int(statement, 5);
                NSUInteger calorie = sqlite3_column_int(statement, 6);
                
                int size = sqlite3_column_bytes(statement, 7);
                UInt16 *perHourData = malloc(size);
                memcpy(perHourData, sqlite3_column_blob(statement, 7), size);
                
                NSUInteger dataLength = sqlite3_column_int(statement, 8);
                
                //DEBUGLog(@"read string to date:%@",[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]);
                WMSSportModel *model = [[WMSSportModel alloc] initWithSportDate:[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]  sportTargetSteps:(targetSteps) sportSteps:steps sportMinute:durations sportDistance:distance sportCalorie:calorie perHourData:perHourData dataLength:dataLength];
                
                [array addObject:model];
                free(perHourData);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_database);
    }
    return array;
}

//更新数据
- (BOOL)updateSportData:(WMSSportModel *)model
{
    if ([self openDB]) {
        sqlite3_stmt *statement;//这相当一个容器，放转化OK的sql语句
        //组织SQL语句
        char *sql = "update SportDataTable set targetSteps = ?, sportSteps = ?, sportDurations = ?, sportDistance = ?, sportCalorie = ?, perHourData = ?, dataLength = ? WHERE sportDate = ?";
        
        //将SQL语句放入sqlite3_stmt中
        int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to SportDataTable");
            sqlite3_close(_database);
            return NO;
        }
        
        sqlite3_bind_int(statement, 1, model.targetSteps);
        sqlite3_bind_int(statement, 2, model.sportSteps);
        sqlite3_bind_int(statement, 3, model.sportMinute);
        sqlite3_bind_int(statement, 4, model.sportDistance);
        sqlite3_bind_int(statement, 5, model.sportCalorie);
        int len = 0;
        if (model.dataLength > 0) {
            len = sizeof(model.perHourData[0]) * model.dataLength;
        }
        sqlite3_bind_blob(statement, 6, model.perHourData, len, SQLITE_STATIC);
        sqlite3_bind_int(statement, 7, model.dataLength);
        NSString *strDate = [model.sportDate.description substringToIndex:10];
        sqlite3_bind_text(statement, 8, [strDate UTF8String], -1, SQLITE_TRANSIENT);
        
        //执行SQL语句。这里是更新数据库
        success = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果执行失败
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to update the database with message.");
            //关闭数据库
            sqlite3_close(_database);
            return NO;
        }
        //执行成功后依然要关闭数据库
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}

//删除数据
- (BOOL)deleteAllSportData
{
    if ([self openDB] == NO) {
        return NO;
    }
    
    //删除所有数据，条件为1>0永真
    const char *deleteAllSql="delete from SportDataTable where 1>0";
    //执行删除语句
    if(sqlite3_exec(_database, deleteAllSql, NULL, NULL, NULL)==SQLITE_OK){
        NSLog(@"删除所有数据成功");
    } else {
        NSLog(@"删除失败");
        sqlite3_close(_database);
        return NO;
    }
    sqlite3_close(_database);
    return YES;
}
- (BOOL)deleteSportData:(WMSSportModel *)model
{
//    if ([self openDB] == NO) {
//        return NO;
//    }
//    
//    //删除某条数据
//    NSString *deleteString=[NSString stringWithFormat:@"delete from SportDataTable where sportDate = '%@'", model.sportDate];
//    //转成utf-8的c的风格
//    const char *deleteSql=[deleteString UTF8String];
//    //执行删除语句
//    char *errorMsg;
//    if(sqlite3_exec(_database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK){
//        NSLog(@"删除成功, %s",errorMsg);
//    } else {
//        NSLog(@"删除失败 %s",errorMsg);
//        sqlite3_close(_database);
//        return NO;
//    }
//    sqlite3_close(_database);
//    return YES;
    
    return [self delete1:model];
}

- (BOOL)delete1:(WMSSportModel *)model
{
    if ([self openDB]) {
        
        sqlite3_stmt *statement;
        //组织SQL语句
        char *sql = "delete from SportDataTable where sportDate = ?";
        //将SQL语句放入sqlite3_stmt中
        int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to delete:testTable");
            sqlite3_close(_database);
            return NO;
        }

        NSString *strDate = [model.sportDate.description substringToIndex:10];
        sqlite3_bind_text(statement, 1, [strDate UTF8String], -1, SQLITE_TRANSIENT);
        //执行SQL语句。这里是更新数据库
        success = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果执行失败
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to delete the database with message.");
            //关闭数据库
            sqlite3_close(_database);
            return NO;
        }
        //执行成功后依然要关闭数据库
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}



#pragma mark - Private Methods
//获取document目录并返回数据库目录
- (NSString *)databaseFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"=======%@",documentsDirectory);
    return [documentsDirectory stringByAppendingPathComponent:DatabaseName];//这里很神奇，可以定义成任何类型的文件，也可以不定义成.db文件，任何格式都行，定义成.sb文件都行，达到了很好的数据隐秘性
}

//创建，打开数据库
- (BOOL)openDB {
    
    //获取数据库路径
    NSString *path = [self databaseFilePath];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断数据库是否存在
    BOOL find = [fileManager fileExistsAtPath:path];
    
    //如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
    if (find) {
        
        NSLog(@"Database file have already existed.");
        
        //打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
        //Objective-C)编写的，它不知道什么是NSString.
        if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
            
            //如果打开数据库失败则关闭数据库
            sqlite3_close(_database);
            NSLog(@"Error: open database file.");
            return NO;
        }
        
        //创建一个新表
        //[self createTestList:_database];
        
        return YES;
    }
    //如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
    if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
        
        //创建一个新表
        [self createTable:_database];
        return YES;
    } else {
        //如果创建并打开数据库失败则关闭数据库
        sqlite3_close(_database);
        NSLog(@"Error: open database file.");
        return NO;
    }
    return NO;
}

//创建表
- (BOOL)createTable:(sqlite3*)db {
    
    //这句是大家熟悉的SQL语句
    char *sql = "create table if not exists SportDataTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, sportDate text, targetSteps integer, sportSteps integer, sportDurations integer, sportDistance integer, sportCalorie integer, perHourData blob, dataLength integer)";
    
    sqlite3_stmt *statement;
    //sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
    NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
    //第一个参数跟前面一样，是个sqlite3 * 类型变量，
    //第二个参数是一个 sql 语句。
    //第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
    //第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
    //第五个参数是错误信息提示，一般不用,为nil就可以了。
    //如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
    
    
    //如果SQL语句解析出错的话程序返回
    if(sqlReturn != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create test table");
        return NO;
    }
    
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    
    //执行SQL语句失败
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:create table test");
        return NO;
    }
    NSLog(@"Create table successed.");
    return YES;
}

@end
