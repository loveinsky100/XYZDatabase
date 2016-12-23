//
//  NSObject+XYZDB.m
//  JDNetSniffer
//
//  Created by Leo on 2016/12/22.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "NSObject+XYZDB.h"
#import "XYZDatabase.h"
#import "XYZDBModelStructCoding.h"
#import "XYZDBBase64.h"
#import "XYZDatabaseSQL.h"
#import <objc/runtime.h>

@implementation NSObject(XYZDB)

XYZDataBaseId_implementation(id, Id)

#pragma mark -同步
/**
 *  同步进行保存，如果数据库不存在创建数据库，之后判断表存不存在，若不存在则创建表，之后存储数据
 *
 *  @return 是否存储成功
 */
- (BOOL)save
{
    XYZDatabaseSQL *SQL = [[XYZDatabaseSQL alloc] init];
    return SQL.insert(self).excuteUpdate(self.database);
}

/**
 *  数据更新，必需需要存在该数据的id，否则存储失败
 *
 *  @return 是否更新成功
 */
- (BOOL)update
{
    XYZDatabaseSQL *SQL = [[XYZDatabaseSQL alloc] init];
    return SQL.update(self).excuteUpdate(self.database);
}

/**
 *  根据Id进行删除，注意必须包含id字段
 *
 *  @return 是否删除成功
 */
- (BOOL)delete
{
    NSString *modelId = self.primaryIdName;
    XYZDatabaseSQL *SQL = [[XYZDatabaseSQL alloc] init];
    return SQL.delete().
                from([self class]).
                where(self.primaryIdName).
                equal([NSString stringWithFormat:@"%ld", self.id]).
                excuteUpdate(self.database);
}

- (NSString *)sqliteType:(NSString *)type
{
    
    NSString *sqliteType = nil;
    if([type isEqualToString: @"c"] ||
       [type isEqualToString: @"i"] ||
       [type isEqualToString: @"s"] ||
       [type isEqualToString: @"q"] ||
       [type isEqualToString: @"C"] ||
       [type isEqualToString: @"I"] ||
       [type isEqualToString: @"S"] ||
       [type isEqualToString: @"L"] ||
       [type isEqualToString: @"Q"] ||
       [type isEqualToString: @"B"])
    {
        sqliteType = @"INTEGER";
    }
    else if([type isEqualToString: @"f"] ||
            [type isEqualToString: @"d"])
    {
        sqliteType = @"REAL";
    }
    else if([type isEqualToString: @"@\"NSString\""] ||
            [type isEqualToString: @"@\"NSMutableString\""] ||
            [type isEqualToString: @"*"] ||
            [type isEqualToString: @":"] ||
            [type isEqualToString: @"#"])
    {
        sqliteType = @"TEXT";
    }
    else
    {
        sqliteType = @"BLOB";
    }
    
    return sqliteType;
}

- (NSMutableArray<XYZPropertyModel *> *)variables
{
    Class cls = [self class];
    return [self classVariables: cls];
}

- (void)encodeWithvariables:(NSArray<XYZPropertyModel *> *)variables
{
    for(XYZPropertyModel *property in variables)
    {
        id value = nil;
        NSString *columnType = property.type;
        NSString *propertyName = property.name;
        value = property.value;
        BOOL isStruct = NO;
        
        if([columnType isEqualToString: @"BLOB"])
        {
            NSString *base64String = value;
            NSData *data = [XYZDBBase64 decodeString:base64String];
            
            objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
            if(property != NULL)
            {
                NSString *varType = [NSString stringWithUTF8String:property_getAttributes(property)];
                
                if([varType rangeOfString:@"="].location == NSNotFound)
                {
                    value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
                else
                {
                    if([self conformsToProtocol:@protocol(XYZDBModelStructCoding)])
                    {
                        id<XYZDBModelStructCoding> coding = (id<XYZDBModelStructCoding>)self;
                        [coding decodeStructProperty:data name:propertyName];
                    }
                    
                    isStruct = YES;
                }
            }
        }
        
        objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
        if(property != NULL && !isStruct)
        {
            if([propertyName isEqualToString:self.primaryIdName])
            {
                [self setPrimaryId:value];
            }
            else
            {
                [self setValue:value forKey:propertyName];
            }
        }
    }
}

- (NSMutableArray<XYZPropertyModel *> *)classVariables:(Class)class
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
        
        NSString *varType = [[NSString alloc] initWithUTF8String: type];
        XYZPropertyModel *dbModel = [[XYZPropertyModel alloc] init];
        dbModel.name = key;
        dbModel.type = [self sqliteType:varType];
        id value = [self valueForKey:key];
        if(!value)
        {
            value = [NSNull null];
        }
        
        if([value isKindOfClass:[XYZDatabase class]])
        {
            continue;
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
            
            value = [XYZDBBase64 stringByEncodingData:data];
        }
        
        if([dbModel.name hasPrefix:@"_"])
        {
            dbModel.name = [dbModel.name substringWithRange:NSMakeRange(1, dbModel.name.length - 1)];
        }
        
        dbModel.value = [NSString stringWithFormat:@"%@", value];
        
        [arrayFormat addObject:dbModel];
    }
    
    free(ivars);
    [arrayFormat addObjectsFromArray: [self classVariables: class_getSuperclass(class)]];
    
    XYZPropertyModel *primaryModel = [[XYZPropertyModel alloc] init];
    primaryModel.value = [NSString stringWithFormat:@"%ld", self.id];
    primaryModel.name = self.primaryIdName;
    primaryModel.type = @"INTEGER";
    
    [arrayFormat addObject:primaryModel];
    return arrayFormat;
}


@end
