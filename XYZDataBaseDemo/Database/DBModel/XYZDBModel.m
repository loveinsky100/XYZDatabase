//
//  XYZDBModel.m
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDBModel.h"
#import "XYZDBOperationQueue.h"
#import "XYZDBOperation.h"
#import <objc/runtime.h>
#import "XYZDBTool.h"
#import "XYZDBModelStructCoding.h"
#import "Base64.h"

@implementation XYZDBModel
XYZDataBaseId_implementation(id)

#pragma mark -同步
/**
 *  同步进行保存，如果数据库不存在创建数据库，之后判断表存不存在，若不存在则创建表，之后存储数据
 *
 *  @return 是否存储成功
 */
- (BOOL)save
{
    return [[XYZDBTool sharedXYZDBTool] saveData: self];
}

/**
 *  根据条件删除该表中的数据，需要注意的是所有的字段是其成员变量，故若是属性则需要添加"_"
 *  单条件删除
 *
 *  @param varName  where条件
 *  @param varValue where条件的value
 *
 *  @return 是否删除成功
 */
+ (BOOL)deleteBy:(NSString *)varName value:(id)varValue
{
    return [[XYZDBTool sharedXYZDBTool] deleteDateByFilter:varName
                                               filterValue:varValue
                                                 className:self];
}

/**
 *  数据更新，必需需要存在该数据的id，否则存储失败
 *
 *  @return 是否更新成功
 */
- (BOOL)update
{
    return [[XYZDBTool sharedXYZDBTool] updateDate: self];
}

/**
 *  根据条件进行查找，单条件查找
 *
 *  @param varName  where条件
 *  @param varValue where条件
 *
 *  @return 查找到的数据，以NSArray存储，内部存储该model的信息
 */
+ (id)findBy:(NSString *)varName value:(id)varValue
{
    return [[XYZDBTool sharedXYZDBTool] findDataByFilter:varName
                                             filterValue:varValue
                                               className:[self class]];
}

/**
 *  根据id查找model
 *
 *  @param idValue id的值
 *
 *  @return 具体的model
 */
+ (id)find:(NSInteger) idValue
{
    NSString *modelId = self.modelId;
    return [self findBy:modelId value:@(idValue)];
}

/**
 *  根据Id进行删除，注意必须包含id字段
 *
 *  @return 是否删除成功
 */
- (BOOL)delete
{
    NSString *modelId = self.modelId;
    return [[self class] deleteBy:modelId
                            value:[self valueForKey: modelId]];
}

/**
 *  对该表进行执行sql语句
 *
 *  @param sqlString sql
 *
 *  @return 是否执成功
 */
+ (BOOL)excuteUpdate:(NSString *)sqlString
{
    return [[XYZDBTool sharedXYZDBTool] excuteUpdate: sqlString];
}

/**
 *  执行返回数据的sql语句，需要注意的是，执行返回数据必须是该model的数据
 *
 *  @param sqlString sql
 *
 *  @return sql执行的具体数据
 */
+ (id)excuteQuery:(NSString *)sqlString transModel:(BOOL)trans
{
    return [[XYZDBTool sharedXYZDBTool] excuteQuery: sqlString
                                         modelClass: trans ? [self class] : nil];
}

#pragma mark -异步
- (void)saveCallBack:(XYZDBOperationCallBack)callback
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
    __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        BOOL value = [belf save];
        return @(value);
    }];
    
    operation.dbModel = self;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

+ (void)deleteBy:(NSString *)varName value:(id)varValue callBack:(XYZDBOperationCallBack)callback
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
    __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        BOOL value = [belf deleteBy:varName
                              value:varValue];
        return @(value);

    }];
    
    operation.dbModel = nil;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

- (void)updateCallBack:(XYZDBOperationCallBack)callback
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
    __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        BOOL value = [belf update];
        return @(value);
    }];
    
    operation.dbModel = self;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

+ (void)find:(NSInteger) idValue callBack:(XYZDBOperationCallBack) callback
{
    NSString *modelId = self.modelId;
    [[self class] findBy:modelId
                   value:@(idValue)
                callBack:callback];
}

+ (void)findBy:(NSString *)varName value:(id)varValue callBack:(XYZDBOperationCallBack)callback
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
    __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        id value = [belf findBy:varName
                          value:varValue];
        return value;
    }];
    
    operation.dbModel = nil;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

- (void)deleteCallBack:(XYZDBOperationCallBack) callback
{
    NSString *modelId = self.modelId;
    [[self class] deleteBy:modelId
                     value:[self valueForKey: modelId]
                  callBack:callback];
}

+ (void)excuteQuery:(NSString *)sqlString callBack:(XYZDBOperationCallBack) callback transModel:(BOOL)trans;
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
     __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        id value = [belf excuteQuery: sqlString transModel: trans];
        return value;
    }];
    
    operation.dbModel = nil;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

+ (void)excuteUpdate:(NSString *)sqlString callBack:(XYZDBOperationCallBack)callback
{
    XYZDBOperation *operation = [[[XYZDBOperation alloc] init] autorelease];
    __block __typeof(self) belf = self;
    [operation setOperation:^id(){
        BOOL value = [belf excuteUpdate: sqlString];
        return @(value);
    }];
    
    operation.dbModel = nil;
    [operation setCallBack: callback];
    [[XYZDBOperationQueue sharedXYZDBOperationQueue] addOperation: operation];
}

#pragma mark -otherMethod

- (NSMutableArray<DBModel *> *)variables
{
    Class cls = [self class];
    return [self classVariables: cls];
}

- (NSMutableArray<DBModel *> *)classVariables:(Class)class
{
    if(class == [NSObject class])
    {
        return nil;
    }
    
    NSMutableArray *arrayFormat = [NSMutableArray array];
    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(class, &ivarsCnt);
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        const char *type = ivar_getTypeEncoding(ivar);
        
        NSString *varType = [[[NSString alloc] initWithUTF8String: type] autorelease];
        DBModel *dbModel = [[DBModel alloc] init];
        dbModel.name = key;
        dbModel.type = sqliteType(varType);
        id value = [self valueForKey:key];
        if(!value)
        {
            value = [NSNull null];
        }
        
        if([dbModel.type isEqualToString:@"BLOB"])
        {
            NSData *data = nil;
            if([varType rangeOfString:@"="].location == NSNotFound)
            {
                if([value conformsToProtocol:@protocol(NSCoding)])
                {
                    data = [NSKeyedArchiver archivedDataWithRootObject:value];
                }
            }
            else
            {
                if([self conformsToProtocol:@protocol(XYZDBModelStructCoding)])
                {
                    id<XYZDBModelStructCoding> coding = (id<XYZDBModelStructCoding>)self;
                    data = [coding encodeStructProperty:[dbModel.name substringWithRange:NSMakeRange(1, dbModel.name.length - 1)]];
                }
                
            }
            
            value = [Base64 stringByEncodingData:data];
        }
        
        dbModel.value = value;
        
        [arrayFormat addObject:dbModel];
        [dbModel release];
    }
    
    free(ivars);
    [arrayFormat addObjectsFromArray: [self classVariables: class_getSuperclass(class)]];
    return arrayFormat;
}

@end
