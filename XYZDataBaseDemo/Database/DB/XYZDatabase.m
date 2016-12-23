//
//  XYZDatabase.m
//  DiarySchedules
//
//  Created by Leo on 16/1/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDatabase.h"
#import <sqlite3.h>
#import "XYZDBModelStructCoding.h"
#import "XYZDBBase64.h"
#import "XYZPropertyModel.h"
#import "NSObject+XYZDB.h"

@interface XYZDatabase()
{
    sqlite3 *database;
    sqlite3_stmt *statement;
}

@property (nonatomic, copy) NSString *databasePath;

@end

@implementation XYZDatabase

- (void)dealloc
{
    [self close];
}

- (instancetype)initWithDatabasePath:(NSString *)path
{
    if(self = [super init])
    {
        _databasePath = path;
    }
    
    return self;
}

- (BOOL)open
{
    if(database)
    {
        return YES;
    }
    
    const char *dbpath = [self.databasePath UTF8String];
    return sqlite3_open(dbpath, &database) == SQLITE_OK;
}

- (void)close
{
    if(database)
    {
        sqlite3_close(database);
    }
}

#pragma mark -dbOperationMethod
- (NSInteger)excuteInsertOneUpdateWithSQL:(NSString *)sqlString
{
    if([self excuteUpdateWithSQL:sqlString])
    {
        return (long)sqlite3_last_insert_rowid(database);
    }
    else
    {
        return -1;
    }
}

- (BOOL)excuteUpdateWithSQL:(NSString *)sqlString
{
    const char *dbpath = [self.databasePath UTF8String];
    if ([self open])
    {
        NSString *insertSQL = sqlString;
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_finalize(statement);
            return YES;
        }
        
        sqlite3_finalize(statement);
    }
    
    return NO;
}

- (NSArray<XYZPropertyModel *> *)excuteQueryWithSQL:(NSString*)sqlString
{
    const char *dbpath = [self.databasePath UTF8String];
    if ([self open])
    {
        NSString *querySQL = sqlString;
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray<NSArray<XYZPropertyModel *> *> *resultArray = [NSMutableArray array];
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableArray<XYZPropertyModel *> *subResultArray = [NSMutableArray array];
                for(NSInteger index = 0; index < sqlite3_column_count(statement); index++)
                {
                    XYZPropertyModel *aProperty = [[XYZPropertyModel alloc] init];
                    id value = nil;
                    NSString *columnType = [NSString stringWithUTF8String: sqlite3_column_decltype(statement, (int)index)];
                    if([columnType isEqualToString: @"TEXT"])
                    {
                        aProperty.type = @"TEXT";
                        value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                    }
                    else if([columnType isEqualToString: @"INTEGER"])
                    {
                        aProperty.type = @"INTEGER";
                        value = [NSNumber numberWithInt: sqlite3_column_int(statement, (int)index)];
                    }
                    else if([columnType isEqualToString: @"REAL"])
                    {
                        aProperty.type = @"REAL";
                        value = [NSNumber numberWithDouble: sqlite3_column_double(statement, (int)index)];
                    }
                    else
                    {
                        aProperty.type = @"BLOB";
                        NSString *base64String = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                        value = base64String;
                    }
                    
                    if(!value)
                    {
                        value = [NSNull null];
                    }
                    
                    aProperty.value = [NSString stringWithFormat:@"%@", value];
                    NSString *columnName = [NSString stringWithUTF8String: sqlite3_column_name(statement, (int)index)];
                    aProperty.name = columnName;
                    [subResultArray addObject:aProperty];
                }
                
                [resultArray addObject: subResultArray];
            }
            
            sqlite3_finalize(statement);
            return resultArray;
        }
    }

    return nil;
}

- (BOOL)createOrUpdateTableWithSQL:(NSString *)sqlString
{
    if(!sqlString || ![sqlString isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    BOOL isSuccess = YES;
    const char *dbpath = [self.databasePath UTF8String];
    if([self open])
    {
        char *errMsg;
        const char *sql_stmt = [sqlString UTF8String];
        if(sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            sqlite3_free(errMsg);
            isSuccess = NO;
        }
    }
    else
    {
        return NO;
    }
    
    return isSuccess;
}

@end
