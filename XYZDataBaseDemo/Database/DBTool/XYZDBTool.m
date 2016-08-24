//
//  XYZDBTool.c
//  DiarySchedules
//
//  Created by Leo on 16/1/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDBTool.h"
#import <sqlite3.h>
#import "SynthesizeSingleton.h"
#import "XYZDBModelStructCoding.h"
#import "Base64.h"

#define DataBaseCreate                           (@"create table if not exists %@")
#define DataBaseInsert                           (@"insert into %@ ")
#define DataBaseFind                             (@"select * from %@ where %@=\"%@\"")
#define DataBaseUpdate                           (@"update %@ set %@ where %@")
#define DataBaseDelete                           (@"delete from %@ where %@")

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@interface XYZDBTool()
- (NSString *)createDBSql:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray;
- (NSString *)findDBSql:(Class)modelClass filter:(NSString *)filterName value:(id)filterValue;
- (NSString *)updateDBSql:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray;
- (NSString *)deleteDBSql:(Class)modelClass filter:(NSString *)filterName value:(id)filterValue;
- (BOOL)openDB:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray;
@end

@implementation XYZDBTool
SYNTHESIZE_SINGLETON_FOR_CLASS(XYZDBTool)
- (instancetype)init
{
    if(self = [super init])
    {
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: DataBaseName]];
    }
    
    return self;
}

#pragma mark -publicMethod
- (BOOL)saveData:(XYZDBModel *)model;
{
    NSArray<DBModel *> *variableArray = model.variables;
    if(![self openDB:model variables:variableArray])
    {
        return NO;
    }
    
    NSString *saveSql = [self saveDBSql:model variables: variableArray];
    if(!saveSql || ![saveSql isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    if([self excuteUpdate: saveSql])
    {
        if([model respondsToSelector: @selector(setModelId:)])
        {
            [model setModelId:@((long)sqlite3_last_insert_rowid(database))];
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSArray<XYZDBModel *> *)findDataByFilter:(NSString *)filter filterValue:(id)value className:(Class)modelClass
{
    NSString *findSql = [self findDBSql:modelClass filter:filter value:value];
    if(!findSql || ![findSql isKindOfClass: [NSString class]])
    {
        return nil;
    }
    
    return [self excuteQuery: findSql modelClass: modelClass];
}

- (BOOL)updateDate:(XYZDBModel *)model
{
    NSArray<DBModel *> *variableArray = model.variables;
    NSString *updateSql = [self updateDBSql:model variables: variableArray];
    if(!updateSql || ![updateSql isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    return [self excuteUpdate: updateSql];
}

- (BOOL)deleteDateByFilter:(NSString *)filter filterValue:(id)value className:(Class)modelClass
{
    NSString *deleteSql = [self deleteDBSql:modelClass filter:filter value:value];
    if(!deleteSql || ![deleteSql isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    return [self excuteUpdate: deleteSql];
}

#pragma mark -dbOperationMethod
- (BOOL)excuteUpdate:(NSString *)sqlString
{
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = sqlString;
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_finalize(statement);
            return YES;
        }
    }
    
    sqlite3_finalize(statement);
    return NO;
}

- (id)excuteQuery:(NSString*)sqlString modelClass:(Class)modelClass
{
    if(modelClass)
    {
        if(![modelClass isSubclassOfClass: [XYZDBModel class]])
        {
            return nil;
        }
    }
    
    const char *dbpath = [self.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = sqlString;
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [NSMutableArray array];
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if(!modelClass)
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSMutableArray *aArray = [[NSMutableArray alloc] init];
                    for(NSInteger index = 0; index < sqlite3_column_count(statement); index++)
                    {
                        id value = nil;
                        NSString *columnType = [NSString stringWithUTF8String: sqlite3_column_decltype(statement, (int)index)];
                        if([columnType isEqualToString: @"TEXT"])
                        {
                            value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                        }
                        else if([columnType isEqualToString: @"INTEGER"])
                        {
                            value = [NSNumber numberWithInt: sqlite3_column_int(statement, (int)index)];
                        }
                        else if([columnType isEqualToString: @"REAL"])
                        {
                            value = [NSNumber numberWithDouble: sqlite3_column_double(statement, (int)index)];
                        }
                        else
                        {
                            NSString *base64String = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                            value = [Base64 decodeString:base64String];
                        }
                        
                        if(!value)
                        {
                            value = [NSNull null];
                        }
                        
                        [aArray addObject: value];
                    }
                    
                    [resultArray addObject: aArray];
                    [aArray release];
                }
            }
            else
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    id aModel = [[modelClass alloc] init];
                    for(NSInteger index = 0; index < sqlite3_column_count(statement); index++)
                    {
                        id value = nil;
                        NSString *columnType = [NSString stringWithUTF8String: sqlite3_column_decltype(statement, (int)index)];
                        NSString *columnName = [NSString stringWithUTF8String: sqlite3_column_name(statement, (int)index)];
                        NSString *propertyName = [columnName substringWithRange:NSMakeRange(1, columnName.length - 1)];
                        BOOL isStruct = NO;
                        if([columnType isEqualToString: @"TEXT"])
                        {
                            value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                        }
                        else if([columnType isEqualToString: @"INTEGER"])
                        {
                            value = [NSNumber numberWithInt: sqlite3_column_int(statement, (int)index)];
                        }
                        else if([columnType isEqualToString: @"REAL"])
                        {
                            value = [NSNumber numberWithDouble: sqlite3_column_double(statement, (int)index)];
                        }
                        else
                        {
                            NSString *base64String = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, (int)index)];
                            NSData *data = [Base64 decodeString:base64String];
                            
                            objc_property_t property = class_getProperty([aModel class], [[columnName substringWithRange:NSMakeRange(1, columnName.length - 1)] UTF8String]);
                            if(property != NULL)
                            {
                                NSString *varType = [NSString stringWithUTF8String:property_getAttributes(property)];
                                
                                if([varType rangeOfString:@"="].location == NSNotFound)
                                {
                                    value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                                }
                                else
                                {
                                    if([aModel conformsToProtocol:@protocol(XYZDBModelStructCoding)])
                                    {
                                        id<XYZDBModelStructCoding> coding = (id<XYZDBModelStructCoding>)aModel;
                                        [coding decodeStructProperty:data name:propertyName];
                                    }
                                    
                                    isStruct = YES;
                                }
                            }
                        }
                        
                        objc_property_t property = class_getProperty([aModel class], [propertyName UTF8String]);
                        if(property != NULL && !isStruct)
                        {
                            [aModel setValue:value forKey:propertyName];
                        }
                    }
                    
                    [resultArray addObject: aModel];
                    [aModel release];
                }
            }
            
            sqlite3_finalize(statement);
            return resultArray;
        }
    }
    
    sqlite3_finalize(statement);
    return nil;
}

#pragma mark -privateMethod
-(BOOL)openDB:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray{
    NSString *createDBSQL = [self createDBSql: model variables: variableArray];
    if(!createDBSQL || ![createDBSQL isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    BOOL isSuccess = YES;
    const char *dbpath = [self.databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = [createDBSQL UTF8String];
        if(sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            isSuccess = NO;
        }
        
        NSString *updateTableSql = [self updateTableQuery:variableArray model:model];
        if(updateTableSql)
        {
            if(sqlite3_exec(database, [updateTableSql UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
            }
        }
        
        sqlite3_close(database);
        return isSuccess;
    }
    else
    {
        isSuccess = NO;
    }
    
    return isSuccess;
}

- (NSString *)updateTableQuery:(NSArray<DBModel *> *)variableArray model:(XYZDBModel *)model
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary<NSString *, NSString *> *dic = [NSMutableDictionary dictionaryWithCapacity:variableArray.count];
    for(DBModel *dbModel in variableArray)
    {
        [dic setObject:dbModel.type
                forKey:dbModel.name];
    }
    
    NSString *userKey = [NSString stringWithFormat:@"XYZDataBase_%@", NSStringFromClass([model class])];
    NSDictionary<NSString *, NSString *> *userDic = [userDefaults objectForKey:userKey];
    if(!userDic)
    {
        [userDefaults setObject:dic forKey:userKey];
        return nil;
    }
    
    NSString *tableAlter = [NSString stringWithFormat:@"alter table %@ ", NSStringFromClass([model class])];
    NSMutableString *query = [NSMutableString stringWithString:tableAlter];
    
    if(userDic.count > dic.count)
    {
        for(NSString *key in userDic.allKeys)
        {
            NSString *valueUser = [dic objectForKey:key];
            if(!valueUser)
            {
//                [query appendFormat:@"drop column %@, ", key]; // not suppot
                continue;
            }
            
            NSString *value = [dic objectForKey:key];
            if(![valueUser isEqualToString:value])
            {
//                [query appendFormat:@"drop column %@, ", key]; // not suppot
                [query appendFormat:@"add column %@ %@, ", key, value];
            }
        }
    }
    else
    {
        for(NSString *key in dic.allKeys)
        {
            NSString *valueUser = [userDic objectForKey:key];
            if(!valueUser)
            {
                [query appendFormat:@"add column %@ %@, ", key, dic[key]];
                continue;
            }
            
            NSString *value = [dic objectForKey:key];
            if(![valueUser isEqualToString:value])
            {
                [query appendFormat:@"drop column %@, ", key];
                [query appendFormat:@"add column %@ %@, ", key, value];
            }
        }
    }
    
    if([tableAlter isEqualToString:query])
    {
        return nil;
    }
    
    [userDefaults setObject:dic forKey:userKey];
    
    [query deleteCharactersInRange:NSMakeRange(query.length - 2, 2)];
    [query appendString:@";"];
    return query;
}

#pragma mark -otherMethod
- (NSString *)createDBSql:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray
{
    if(!model || !variableArray || ![variableArray isKindOfClass: [NSArray class]] || variableArray.count == 0)
    {
        return nil;
    }
    
    BOOL hasKey = NO;
    NSMutableString *createSql = [NSMutableString string];
    NSString *tableName = NSStringFromClass([model class]);
    [createSql appendFormat:DataBaseCreate, tableName];
    NSMutableString *variableSql = [NSMutableString string];
    for(DBModel *dbModel in variableArray)
    {
        if(model.modelId &&
           !hasKey &&
           [dbModel.name isEqualToString: model.modelId])
        {
            hasKey = YES;
            [variableSql appendFormat: @"%@ %@ primary key, ", dbModel.name, dbModel.type];
        }
        else
        {
            [variableSql appendFormat: @"%@ %@, ", dbModel.name, dbModel.type];
        }
    }
    
    [variableSql deleteCharactersInRange: NSMakeRange(variableSql.length - 2, 2)];
    [createSql appendFormat: @"(%@)", variableSql];
    return createSql;
}

- (NSString *)saveDBSql:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray
{
    if(!model || !variableArray || ![variableArray isKindOfClass: [NSArray class]] || variableArray.count == 0)
    {
        return nil;
    }
    
    NSMutableString *saveSql = [NSMutableString string];
    NSString *tableName = NSStringFromClass([model class]);
    [saveSql appendFormat:DataBaseInsert, tableName];
    NSMutableString *variableSql = [NSMutableString string];
    NSMutableString *valueSql = [NSMutableString string];
    for(DBModel *dbModel in variableArray)
    {
        if([model respondsToSelector:@selector(modelId)])
        {
            if([dbModel.name isEqualToString: model.modelId])
            {
                if([dbModel.value integerValue] == 0) // 不存在id，将自动增长
                {
                    continue;
                }
            }
        }
        
        [variableSql appendFormat: @"%@, ", dbModel.name];
        [valueSql appendFormat: @"\"%@\", ", dbModel.value];
    }
    
    [variableSql deleteCharactersInRange: NSMakeRange(variableSql.length - 2, 2)];
    [valueSql deleteCharactersInRange: NSMakeRange(valueSql.length - 2, 2)];
    [saveSql appendFormat: @"(%@) values (%@)", variableSql, valueSql];
    return saveSql;
}

- (NSString *)findDBSql:(Class)modelClass filter:(NSString *)filterName value:(id)filterValue
{
    if(!filterName || ![filterName isKindOfClass: [NSString class]])
    {
        return nil;
    }
    
    NSString *tableName = NSStringFromClass(modelClass);
    NSMutableString *saveSql = [NSMutableString stringWithFormat: DataBaseFind, tableName, filterName, filterValue];
    return saveSql;
}

- (NSString *)updateDBSql:(XYZDBModel *)model variables:(NSArray<DBModel *> *)variableArray
{
    if(!model || !variableArray || ![variableArray isKindOfClass: [NSArray class]] || variableArray.count == 0)
    {
        return nil;
    }
    
    NSString *tableName = NSStringFromClass([model class]);
    NSMutableString *updateSql = [NSMutableString string];
    NSMutableString *variableSql = [NSMutableString string];
    NSMutableString *filterSql = [NSMutableString string];
    for(DBModel *dbModel in variableArray)
    {
        if([dbModel.name isEqualToString: model.modelId])
        {
            if([dbModel.value integerValue] == 0) // 不存在id，将自动增长
            {
                return nil;
            }
            else
            {
                [filterSql appendFormat:@"%@ = \"%@\"", dbModel.name, dbModel.value];
                continue;
            }
        }
        
        [variableSql appendFormat: @"%@ = \"%@\", ", dbModel.name, dbModel.value];
    }
    
    [variableSql deleteCharactersInRange: NSMakeRange(variableSql.length - 2, 2)];
    [updateSql appendFormat: DataBaseUpdate, tableName, variableSql, filterSql];
    return updateSql;
}

- (NSString *)deleteDBSql:(Class)modelClass filter:(NSString *)filterName value:(id)filterValue
{
    if(!filterName || ![filterName isKindOfClass: [NSString class]] || filterName.length == 0)
    {
        return nil;
    }
    
    NSString *tableName = NSStringFromClass(modelClass);
    NSMutableString *deleteSql = [NSMutableString string];
    NSMutableString *filterSql = [NSMutableString string];

    [filterSql appendFormat:@"%@ = \"%@\"", filterName, filterValue];
    [deleteSql appendFormat: DataBaseDelete, tableName, filterSql];
    return deleteSql;
}

@end