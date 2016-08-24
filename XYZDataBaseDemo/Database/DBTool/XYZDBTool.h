//
//  XYZDBTool.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "DBModel.h"
#import <objc/runtime.h>
#import "XYZDBModel.h"

#pragma mark -DataBase
#define DataBaseName                             (@"XYZDataBase11.sqlite")

@interface XYZDBTool : NSObject
@property (nonatomic, copy) NSString *databasePath;

+ (id)sharedXYZDBTool;

- (BOOL)excuteUpdate:(NSString *)sqlString;
- (id)excuteQuery:(NSString*)sqlString modelClass:(Class) modelClass;

- (BOOL)saveData:(XYZDBModel *)model;
- (NSArray<XYZDBModel *> *)findDataByFilter:(NSString *)filter filterValue:(id)value className:(Class)modelClass;
- (BOOL)updateDate:(XYZDBModel *)model;
- (BOOL)deleteDateByFilter:(NSString *)filter filterValue:(id)value className:(Class)modelClass;
@end

inline static NSString *sqliteType(NSString *type)
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
