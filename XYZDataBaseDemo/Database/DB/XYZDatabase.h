//
//  XYZDatabase.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "XYZPropertyModel.h"

#pragma mark -DataBase

@interface XYZDatabase : NSObject
- (instancetype)initWithDatabasePath:(NSString *)path;

- (BOOL)excuteUpdateWithSQL:(NSString *)sqlString;
- (NSInteger)excuteInsertOneUpdateWithSQL:(NSString *)sqlString;
- (NSArray<NSArray<XYZPropertyModel *> *> *)excuteQueryWithSQL:(NSString*)sqlString;
- (BOOL)createOrUpdateTableWithSQL:(NSString *)sqlString;

@end
