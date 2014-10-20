//
//  WMSSleepDatabase.m
//  WMSPlusdot
//
//  Created by Sir on 14-9-18.
//  Copyright (c) 2014年 GUOGEE. All rights reserved.
//

#import "WMSSleepDatabase.h"
#import "sqlite3.h"
#import "WMSSleepModel.h"
#import "NSDate+Formatter.h"

#define DatabaseName    @"sleepData.db"
#define TableName       @"SleepDataTable"

@implementation WMSSleepDatabase
{
    sqlite3 *_database;
}

#pragma mark - Public Methods
+ (WMSSleepDatabase *)sleepDatabase
{
    static dispatch_once_t onceToken = 0;
    __strong static WMSSleepDatabase *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[WMSSleepDatabase alloc] init];
    });
    return sharedObject;
}

- (BOOL)insertSleepData:(WMSSleepModel *)model
{
    //先判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement;
        
        //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
        char *sql = "INSERT INTO SleepDataTable(sleepDate, sleepEndHour, sleepEndMinute, sleepMinute, asleepMinute, awakeCount, deepSleepMinute, lightSleepMinute, startedMinutes, startedStatus, statusDurations, dataLength) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success2 != SQLITE_OK) {
            NSLog(@"Error: failed to insert:SleepDataTable");
            sqlite3_close(_database);
            return NO;
        }
        
        //这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
        NSString *strDate = [model.sleepDate.description substringToIndex:10];
        DEBUGLog(@"write date:%@",model.sleepDate);
        printf("write dateString:%s \n",[strDate UTF8String]);
        
        sqlite3_bind_text(statement, 1, [strDate UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, model.sleepEndHour);
        sqlite3_bind_int(statement, 3, model.sleepEndMinute);
        sqlite3_bind_int(statement, 4, model.sleepMinute);
        sqlite3_bind_int(statement, 5, model.asleepMinute);
        sqlite3_bind_int(statement, 6, model.awakeCount);
        sqlite3_bind_int(statement, 7, model.deepSleepMinute);
        sqlite3_bind_int(statement, 8, model.lightSleepMinute);
        int len = 0;
        if (model.dataLength > 0) {
            len = sizeof(model.startedMinutes[0]) * model.dataLength;
        }
        sqlite3_bind_blob(statement, 9, model.startedMinutes, len, SQLITE_STATIC);
        
        len = sizeof(model.startedStatus[0]) * model.dataLength;
        sqlite3_bind_blob(statement, 10, model.startedStatus, len, SQLITE_STATIC);
        
        len = sizeof(model.statusDurations[0]) * model.dataLength;
        sqlite3_bind_blob(statement, 11, model.statusDurations, len, SQLITE_STATIC);
        
        sqlite3_bind_int(statement, 12, model.dataLength);
        
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
- (NSArray *)queryAllSleepData
{
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    //判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement = nil;
        //sql语句
        char *sql = "SELECT * FROM SleepDataTable";//从testTable这个表中获取 testID, testValue ,testName，若获取全部的话可以用*代替testID, testValue ,testName。
        
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get SleepDataTable.");
            return NO;
        }
        else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *strDate = (char *)sqlite3_column_text(statement, 1);
                NSString *stringDate = [NSString stringWithUTF8String:strDate];
                //stringDate = [stringDate substringToIndex:10];
                //printf("read DateString:%s \n",strDate);
                DEBUGLog(@"read stringDate:%@",stringDate);
                
                NSUInteger endHour = sqlite3_column_int(statement, 2);
                NSUInteger endMinute = sqlite3_column_int(statement, 3);
                NSUInteger sleepMinute = sqlite3_column_int(statement, 4);
                NSUInteger asleepMinute = sqlite3_column_int(statement, 5);
                NSUInteger awakeCount = sqlite3_column_int(statement, 6);
                NSUInteger deepSleepMinute = sqlite3_column_int(statement, 7);
                NSUInteger lightSleepMinute = sqlite3_column_int(statement, 8);
                int size = sqlite3_column_bytes(statement, 9);
                UInt16 *startedMinutes = malloc(size);
                memcpy(startedMinutes, sqlite3_column_blob(statement, 9), size);
                
                size = sqlite3_column_bytes(statement, 10);
                UInt8 *startedStatus = malloc(size);
                memcpy(startedStatus, sqlite3_column_blob(statement, 10), size);
                
                size = sqlite3_column_bytes(statement, 11);
                UInt8 *statusDurations = malloc(size);
                memcpy(statusDurations, sqlite3_column_blob(statement, 11), size);
                
                NSUInteger dataLength = size/sizeof(UInt8);
                
                //DEBUGLog(@"read string to date:%@",[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]);
                NSDate *date = [NSDate dateFromString:stringDate format:@"yyyy-MM-dd"];
                WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:endHour sleepEndMinute:endMinute sleepMinute:sleepMinute asleepMinute:asleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
                
                [array addObject:model];
                free(startedMinutes);
                free(startedStatus);
                free(statusDurations);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_database);
    }
    
    return array;
}

- (NSArray *)querySleepData:(NSDate *)sleepDate
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    //判断数据库是否打开
    if ([self openDB]) {
        
        sqlite3_stmt *statement = nil;
        //sql语句
        char *sql = "SELECT * FROM SleepDataTable WHERE sleepDate = ?";
        
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            sqlite3_finalize(statement);
            sqlite3_close(_database);
            return nil;
        }
        else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
            
            NSString *strDate = [sleepDate.description substringToIndex:10];
            sqlite3_bind_text(statement, 1, [strDate UTF8String], -1, SQLITE_TRANSIENT);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *strDate = (char *)sqlite3_column_text(statement, 1);
                NSString *stringDate = [NSString stringWithUTF8String:strDate];
                //stringDate = [stringDate substringToIndex:10];
                //printf("read DateString:%s \n",strDate);
                DEBUGLog(@"read stringDate:%@",stringDate);
                
                NSUInteger endHour = sqlite3_column_int(statement, 2);
                NSUInteger endMinute = sqlite3_column_int(statement, 3);
                NSUInteger sleepMinute = sqlite3_column_int(statement, 4);
                NSUInteger asleepMinute = sqlite3_column_int(statement, 5);
                NSUInteger awakeCount = sqlite3_column_int(statement, 6);
                NSUInteger deepSleepMinute = sqlite3_column_int(statement, 7);
                NSUInteger lightSleepMinute = sqlite3_column_int(statement, 8);
                int size = sqlite3_column_bytes(statement, 9);
                UInt16 *startedMinutes = malloc(size);
                memcpy(startedMinutes, sqlite3_column_blob(statement, 9), size);
                
                size = sqlite3_column_bytes(statement, 10);
                UInt8 *startedStatus = malloc(size);
                memcpy(startedStatus, sqlite3_column_blob(statement, 10), size);
                
                size = sqlite3_column_bytes(statement, 11);
                UInt8 *statusDurations = malloc(size);
                memcpy(statusDurations, sqlite3_column_blob(statement, 11), size);
                
                NSUInteger dataLength = size/sizeof(UInt8);
                
                //DEBUGLog(@"read string to date:%@",[NSDate dateFromString:stringDate format:@"yyyy-MM-dd"]);
                NSDate *date = [NSDate dateFromString:stringDate format:@"yyyy-MM-dd"];
                WMSSleepModel *model = [[WMSSleepModel alloc] initWithSleepDate:date sleepEndHour:endHour sleepEndMinute:endMinute sleepMinute:sleepMinute asleepMinute:asleepMinute awakeCount:awakeCount deepSleepMinute:deepSleepMinute lightSleepMinute:lightSleepMinute startedMinutes:startedMinutes startedStatus:startedStatus statusDurations:statusDurations dataLength:dataLength];
                
                [array addObject:model];
                free(startedMinutes);
                free(startedStatus);
                free(statusDurations);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_database);
    }
    return array;
}

- (BOOL)updateSleepData:(WMSSleepModel *)model;
{
    if ([self openDB]) {
        sqlite3_stmt *statement;//这相当一个容器，放转化OK的sql语句
        //组织SQL语句
        char *sql = "update SleepDataTable set sleepEndHour = ?, sleepEndMinute = ?, sleepMinute = ?, asleepMinute = ?, awakeCount = ?, deepSleepMinute = ?, lightSleepMinute = ?, startedMinutes = ?, startedStatus = ?, statusDurations = ?, dataLength = ? WHERE sleepDate = ?";
        
        //将SQL语句放入sqlite3_stmt中
        int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to SleepDataTable");
            sqlite3_close(_database);
            return NO;
        }
        
        sqlite3_bind_int(statement, 1, model.sleepEndHour);
        sqlite3_bind_int(statement, 2, model.sleepEndMinute);
        sqlite3_bind_int(statement, 3, model.sleepMinute);
        sqlite3_bind_int(statement, 4, model.asleepMinute);
        sqlite3_bind_int(statement, 5, model.awakeCount);
        sqlite3_bind_int(statement, 6, model.deepSleepMinute);
        sqlite3_bind_int(statement, 7, model.lightSleepMinute);
        int len = 0;
        if (model.dataLength > 0) {
            len = sizeof(model.startedMinutes[0]) * model.dataLength;
        }
        sqlite3_bind_blob(statement, 8, model.startedMinutes, len, SQLITE_STATIC);
        
        len = sizeof(model.startedStatus[0]) * model.dataLength;
        sqlite3_bind_blob(statement, 9, model.startedStatus, len, SQLITE_STATIC);
        
        len = sizeof(model.statusDurations[0]) * model.dataLength;
        sqlite3_bind_blob(statement, 10, model.statusDurations, len, SQLITE_STATIC);
        
        sqlite3_bind_int(statement, 11, model.dataLength);
        
        NSString *strDate = [model.sleepDate.description substringToIndex:10];
        sqlite3_bind_text(statement, 12, [strDate UTF8String], -1, SQLITE_TRANSIENT);
        
        
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

- (BOOL)deleteAllSleepData
{
    if ([self openDB] == NO) {
        return NO;
    }
    
    //删除所有数据，条件为1>0永真
    const char *deleteAllSql="delete from SleepDataTable where 1>0";
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

- (BOOL)deleteSleepData:(WMSSleepModel *)model
{
    if ([self openDB] == NO) {
        return NO;
    }
    
    //删除某条数据
    NSString *deleteString=[NSString stringWithFormat:@"delete from SleepDataTable where sleepDate = '%@' ", model.sleepDate];
    //转成utf-8的c的风格
    const char *deleteSql=[deleteString UTF8String];
    //执行删除语句
    char *errorMsg;
    if(sqlite3_exec(_database, deleteSql, NULL, NULL, &errorMsg)==SQLITE_OK){
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败 %s",errorMsg);
        sqlite3_close(_database);
        return NO;
    }
    sqlite3_close(_database);
    return YES;
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
    char *sql = "create table if not exists SleepDataTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, sleepDate text, sleepEndHour integer, sleepEndMinute integer, sleepMinute integer, asleepMinute integer, awakeCount integer, deepSleepMinute integer, lightSleepMinute integer, startedMinutes blob, startedStatus blob, statusDurations blob, dataLength integer)";
    
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
        NSLog(@"Error: failed to prepare statement:create SleepDataTable table");
        return NO;
    }
    
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    
    //执行SQL语句失败
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:create SleepDataTable test");
        return NO;
    }
    NSLog(@"Create table successed.");
    return YES;
}

@end
