//
//  NSObject+XYZDB.h
//  JDNetSniffer
//
//  Created by Leo on 2016/12/22.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYZPropertyModel.h"
#import "XYZDatabase.h"

static void *kXYZDatabasePrimaryIdKey = "kXYZDatabasePrimaryIdKey";
static void *kXYZDatabaseDatabaseKey = "kXYZDatabaseDatabaseKey";

#define XYZDBTYPESTRING     @"TEXT"
#define XYZDBTYPEINTEGER    @"INTEGER"
#define XYZDBTYPEFLOAT      @"REAL"
#define XYZDBTYPECLASS      @"BLOB"

/**
 *  在@interface中创建，idName必须和@implementation中的保持一致
 *  所有的操作需要注意同步和异步不可以同时进行
 *
 *  @param idName 该model存入数据库中的id名
 *
 */
#define XYZDataBaseId_interface(idName) \
\
@property(nonatomic, assign) NSInteger idName; \
@property (nonatomic, strong) XYZDatabase *database; \
- (instancetype)initWithDatabase:(XYZDatabase *)database; \
\
- (void)setPrimaryId:(id)value; \
\
- (NSString *)primaryIdName; \
\
- (BOOL)save; \
- (BOOL)update; \
- (BOOL)delete; \
\

/**
 *  在@implementation中创建，idName必须和@interface中的保持一致
 *
 *  @param idName 该model存入数据库中的id名
 *
 */
#define XYZDataBaseId_implementation(idName, IDNAME) \
\
- (instancetype)initWithDatabase:(XYZDatabase *)database \
{  \
if(self = [self init])  \
{  \
self.database = database;  \
}  \
\
return self;  \
} \
\
- (void)setPrimaryId:(id)value \
{\
self.idName = [(NSNumber *)value integerValue]; \
}\
\
- (NSString *)primaryIdName \
{ \
return [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String: #idName]]; \
} \
\
+ (NSString *)primaryIdName \
{ \
return [NSString stringWithFormat:@"%@", [NSString stringWithUTF8String: #idName]]; \
} \
\
- (void)set##IDNAME:(NSInteger)value \
{ \
    objc_setAssociatedObject(self, kXYZDatabasePrimaryIdKey, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
} \
\
- (NSInteger)idName \
{ \
    return [objc_getAssociatedObject(self, kXYZDatabasePrimaryIdKey) integerValue]; \
} \
- (void)setDatabase:(XYZDatabase *)database \
{ \
objc_setAssociatedObject(self, kXYZDatabaseDatabaseKey, database, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
} \
\
- (XYZDatabase *)database \
{ \
return objc_getAssociatedObject(self, kXYZDatabaseDatabaseKey); \
}

@interface NSObject(XYZDB)
/// 可以修改主键名
XYZDataBaseId_interface(id)

/// 自定义数据库结构，重载下面两个方法
- (NSMutableArray<XYZPropertyModel *> *)variables;
- (void)encodeWithvariables:(NSArray<XYZPropertyModel *> *)variables;

@end
