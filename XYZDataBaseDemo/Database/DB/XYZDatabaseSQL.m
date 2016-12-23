//
//  XYZDatabaseSQL.m
//  JDNetSniffer
//
//  Created by Leo on 2016/12/22.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDatabaseSQL.h"
#import "XYZPropertyModel.h"
#import "NSObject+XYZDB.h"
#import "XYZDBBase64.h"
#import "XYZDBModelStructCoding.h"


#define DataBaseInsert                           (@"insert into %@ ")
#define DataBaseUpdate                           (@"update %@ set %@ where %@")
#define DataBaseCreate                           (@"create table if not exists %@")

#define XYZDBSQLAssociatedObject1SBeNil(name) \
- (XYZDatabaseSQL *(^)(NSString *))name \
{ \
return ^(NSString *sql) { \
\
self.sqlString = nil; \
[self.sqlString appendString:[NSString stringWithFormat:@"%@ %@ ", [NSString stringWithUTF8String:#name], sql]]; \
return self; \
}; \
}

#define XYZDBSQLAssociatedObject1S(name) \
- (XYZDatabaseSQL *(^)(NSString *))name \
{ \
return ^(NSString *sql) { \
\
[self.sqlString appendString:[NSString stringWithFormat:@"%@ %@ ", [NSString stringWithUTF8String:#name], sql]]; \
return self; \
}; \
}

#define XYZDBSQLAssociatedObject2S(name, value) \
- (XYZDatabaseSQL *(^)(NSString *))name \
{ \
return ^(NSString *sql) { \
\
[self.sqlString appendString:[NSString stringWithFormat:@"%@ '%@' ", value, sql]]; \
return self; \
}; \
}

#define XYZDBSQLAssociatedObjectBeNil(name) \
- (XYZDatabaseSQL *(^)())name \
{ \
return ^() { \
\
self.sqlString = nil; \
[self.sqlString appendString:[NSString stringWithFormat:@"%@ ", [NSString stringWithUTF8String:#name]]]; \
return self; \
}; \
}

#define XYZDBSQLAssociatedObject(name) \
- (XYZDatabaseSQL *(^)())name \
{ \
return ^() { \
\
[self.sqlString appendString:[NSString stringWithFormat:@"%@ ", [NSString stringWithUTF8String:#name]]]; \
return self; \
}; \
}

@interface XYZDatabaseSQL()
@property (nonatomic, strong) NSMutableString *sqlString;
@property (nonatomic, strong) NSObject *currentObject;
@property (nonatomic, strong) NSArray<XYZPropertyModel *> *currentProperty;
@end

@implementation XYZDatabaseSQL


XYZDBSQLAssociatedObject1SBeNil(select)
XYZDBSQLAssociatedObjectBeNil(delete)
XYZDBSQLAssociatedObject1S(where)
XYZDBSQLAssociatedObject2S(equal, @"=")
XYZDBSQLAssociatedObject2S(notEqual, @"!=")
XYZDBSQLAssociatedObject2S(less, @"<")
XYZDBSQLAssociatedObject2S(large, @">")
XYZDBSQLAssociatedObject2S(lessEqual, @"<=")
XYZDBSQLAssociatedObject2S(largeEqual, @">=")
XYZDBSQLAssociatedObject1S(and)
XYZDBSQLAssociatedObject1S(or)
XYZDBSQLAssociatedObject(desc)
XYZDBSQLAssociatedObject(asc)

- (XYZDatabaseSQL *(^)(NSInteger, NSInteger))limit
{
    return ^(NSInteger fromValue, NSInteger toValue){
        
        [self.sqlString appendFormat:@"limit (%ld, %ld)", fromValue, toValue];
        
        return self;
    };
}

- (XYZDatabaseSQL *(^)(Class))from
{
    return ^(Class aClass){
        [self.sqlString appendFormat:@"from %@ ", NSStringFromClass(aClass)];
        self.currentObject = [[aClass alloc] init];
        return self;
    };
}

- (XYZDatabaseSQL *(^)(NSObject *))update
{
    return ^(NSObject *aObject){
        self.sqlString = nil;
        
        self.sqlString = [self updateDBSql:aObject
                                 variables:aObject.variables];
        
        return self;
    };
}

- (XYZDatabaseSQL *(^)(NSObject *))insert
{
    return ^(NSObject *aObject){
        
        NSArray<XYZPropertyModel *> *propertys = aObject.variables;
        self.currentObject = aObject;
        self.currentProperty = propertys;
        self.sqlString = [self saveDBSql:aObject variables:propertys];
        return self;
    };
}

- (BOOL (^)(XYZDatabase *))excuteUpdate
{
    return ^(XYZDatabase *database) {
        
        if(!database)
        {
            return NO;
        }
        
        BOOL isSuccess;
        if([self.sqlString hasPrefix:@"insert"] &&
           self.currentProperty &&
           self.currentObject)
        {
            NSString *createTableSql = [self createDBSql:[self.currentObject class]
                                               variables:self.currentProperty];
            NSString *updateTableSql = [self updateTableQuery:self.currentProperty
                                                        model:[self.currentObject class]];
            
            if([database createOrUpdateTableWithSQL:createTableSql])
            {
                [database createOrUpdateTableWithSQL:updateTableSql];
                NSInteger primaryId = [database excuteInsertOneUpdateWithSQL:self.sqlString];
                [self.currentObject setPrimaryId:@(primaryId)];
                if(primaryId >= 0)
                {
                    isSuccess = YES;
                }
            }
        }
        else
        {
            isSuccess = [database excuteUpdateWithSQL:self.sqlString];
        }
        
        self.sqlString = nil;
        self.currentProperty = nil;
        self.currentObject = nil;
        return isSuccess;
    };
}

- (NSArray<NSArray<XYZPropertyModel *> *> *(^)(XYZDatabase *))excuteQuery
{
    return ^(XYZDatabase *database) {
        return self.excuteQueryIntoClass(database, [self.currentObject class]);
    };
}

- (NSArray *(^)(XYZDatabase *, Class))excuteQueryIntoClass
{
    return ^(XYZDatabase *database, Class aClass) {
        
        NSArray *data = nil;
        if(!database)
        {
            return data;
        }
        
        data = [database excuteQueryWithSQL:self.sqlString];
        self.sqlString = nil;
        if(aClass)
        {
            return [self rebuildObjectFromDatabase:data
                                             class:aClass
                                        inDatabase:database];
        }
        
        self.currentObject = nil;
        self.currentProperty = nil;
        return data;
    };
}

- (NSMutableString *)sqlString
{
    if(!_sqlString)
    {
        _sqlString = [[NSMutableString alloc] init];
    }
    
    return _sqlString;
}

- (NSString *)saveDBSql:(NSObject *)model variables:(NSArray<XYZPropertyModel *> *)variableArray
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
    for(XYZPropertyModel *dbModel in variableArray)
    {
        if([dbModel.name isEqualToString: model.primaryIdName])
        {
            if([dbModel.value integerValue] == 0) // 不存在id，将自动增长
            {
                continue;
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

- (NSString *)updateDBSql:(NSObject *)model variables:(NSArray<XYZPropertyModel *> *)variableArray
{
    if(!model || !variableArray || ![variableArray isKindOfClass: [NSArray class]] || variableArray.count == 0)
    {
        return nil;
    }
    
    NSString *tableName = NSStringFromClass([model class]);
    NSMutableString *updateSql = [NSMutableString string];
    NSMutableString *variableSql = [NSMutableString string];
    NSMutableString *filterSql = [NSMutableString string];
    for(XYZPropertyModel *dbModel in variableArray)
    {
        if([dbModel.name isEqualToString: model.primaryIdName])
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

- (NSArray *)rebuildObjectFromDatabase:(NSArray<NSArray<XYZPropertyModel *> *> *)sources
                                 class:(Class)modelClass
                            inDatabase:(XYZDatabase *)database

{
    if(!sources || !sources.count)
    {
        return nil;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for(NSArray<XYZPropertyModel *> *source in sources)
    {
        id aModel = [[modelClass alloc] init];
    
        NSObject *aObject = (NSObject *)aModel;
        
        [aObject encodeWithvariables:source];
        
        aObject.database = database;
        [resultArray addObject:aModel];
    }
 
    return resultArray;
}

- (NSString *)updateTableQuery:(NSArray<XYZPropertyModel *> *)variableArray model:(Class)modelClass
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary<NSString *, NSString *> *dic = [NSMutableDictionary dictionaryWithCapacity:variableArray.count];
    for(XYZPropertyModel *dbModel in variableArray)
    {
        [dic setObject:dbModel.type
                forKey:dbModel.name];
    }
    
    NSString *userKey = [NSString stringWithFormat:@"XYZDataBase_%@", NSStringFromClass(modelClass)];
    NSDictionary<NSString *, NSString *> *userDic = [userDefaults objectForKey:userKey];
    if(!userDic)
    {
        [userDefaults setObject:dic forKey:userKey];
        return nil;
    }
    
    NSString *tableAlter = [NSString stringWithFormat:@"alter table %@ ", NSStringFromClass(modelClass)];
    NSMutableString *query = [NSMutableString stringWithString:tableAlter];
    
    if(userDic.count > dic.count)
    {
        for(NSString *key in userDic.allKeys)
        {
            NSString *valueUser = [dic objectForKey:key];
            if(!valueUser)
            {
                [query appendFormat:@"drop column %@, ", key]; // not suppot
                continue;
            }
            
            NSString *value = [dic objectForKey:key];
            if(![valueUser isEqualToString:value])
            {
                [query appendFormat:@"drop column %@, ", key]; // not suppot
                [query appendFormat:@"add column %@ %@, ", key, value];
            }
        }
    }
    
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
- (NSString *)createDBSql:(Class)modelClass variables:(NSArray<XYZPropertyModel *> *)variableArray
{
    if(!modelClass || !variableArray || ![variableArray isKindOfClass: [NSArray class]] || variableArray.count == 0)
    {
        return nil;
    }
    
    BOOL hasKey = NO;
    NSMutableString *createSql = [NSMutableString string];
    NSString *tableName = NSStringFromClass(modelClass);
    [createSql appendFormat:DataBaseCreate, tableName];
    NSMutableString *variableSql = [NSMutableString string];
    for(XYZPropertyModel *dbModel in variableArray)
    {
        if(modelClass.primaryIdName &&
           !hasKey &&
           [dbModel.name isEqualToString: modelClass.primaryIdName])
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

@end
