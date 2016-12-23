//
//  XYZDatabaseSQL.h
//  JDNetSniffer
//
//  Created by Leo on 2016/12/22.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYZDatabase.h"

#define XYZDatabaseSaveSecure 0

@interface XYZDatabaseSQL : NSObject
@property (nonatomic, readonly) NSMutableString *sqlString;

@property (nonatomic, readonly) XYZDatabaseSQL *(^select)(NSString *);
@property (nonatomic, readonly) XYZDatabaseSQL *(^delete)();
@property (nonatomic, readonly) XYZDatabaseSQL *(^update)(NSObject *);
@property (nonatomic, readonly) XYZDatabaseSQL *(^insert)(NSObject *);
@property (nonatomic, readonly) XYZDatabaseSQL *(^from)(Class);
@property (nonatomic, readonly) XYZDatabaseSQL *(^where)(NSString *);
@property (nonatomic, readonly) XYZDatabaseSQL *(^equal)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^notEqual)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^less)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^large)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^lessEqual)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^largeEqual)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^and)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^or)(id);
@property (nonatomic, readonly) XYZDatabaseSQL *(^desc)();
@property (nonatomic, readonly) XYZDatabaseSQL *(^asc)();
@property (nonatomic, readonly) XYZDatabaseSQL *(^limit)(NSInteger, NSInteger);

@property (nonatomic, readonly) BOOL (^excuteUpdate)(XYZDatabase *);
@property (nonatomic, readonly) NSArray<NSArray<XYZPropertyModel *> *> *(^excuteQuery)(XYZDatabase *);

@end
