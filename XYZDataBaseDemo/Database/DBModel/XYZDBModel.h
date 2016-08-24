//
//  XYZDBModel.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModel.h"
#import "XYZDBOperation.h"

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
\
- (void)setModelId:(id)value; \
\
- (NSString *)modelId; \
\
+ (id)find:(NSInteger) idValue; \
+ (id)findBy:(NSString *)varName  \
       value:(id)varValue; \
+ (BOOL)deleteBy:(NSString *)varName  \
           value:(id)varValue; \
- (BOOL)save; \
- (BOOL)update; \
- (BOOL)delete; \
+ (BOOL)excuteUpdate:(NSString *)sqlString; \
+ (id)excuteQuery:(NSString *)sqlString transModel:(BOOL)trans; \
\
\
+ (void)find:(NSInteger) idValue \
    callBack:(XYZDBOperationCallBack) callback; \
\
+ (void)findBy:(NSString *)varName \
         value:(id)varValue \
      callBack:(XYZDBOperationCallBack) callback; \
\
+ (void)deleteBy:(NSString *)varName \
           value:(id)varValue \
        callBack:(XYZDBOperationCallBack) callback; \
\
- (void)saveCallBack:(XYZDBOperationCallBack) callback; \
\
- (void)updateCallBack:(XYZDBOperationCallBack) callback; \
\
- (void)deleteCallBack:(XYZDBOperationCallBack) callback; \
\
+ (void)excuteUpdate:(NSString *)sqlString callBack:(XYZDBOperationCallBack) callback; \
+ (void)excuteQuery:(NSString *)sqlString callBack:(XYZDBOperationCallBack) callback transModel:(BOOL)trans;; \
\
- (NSMutableArray<DBModel *> *)variables; \

/**
 *  在@implementation中创建，idName必须和@interface中的保持一致
 *
 *  @param idName 该model存入数据库中的id名
 *
 */
#define XYZDataBaseId_implementation(idName) \
\
- (void)setModelId:(id)value \
{\
    self.idName = [(NSNumber *)value integerValue]; \
}\
\
- (NSString *)modelId \
{ \
    return [NSString stringWithFormat:@"_%@", [NSString stringWithUTF8String: #idName]]; \
} \
\
+ (NSString *)modelId \
{ \
    return [NSString stringWithFormat:@"_%@", [NSString stringWithUTF8String: #idName]]; \
} \

/**
 * 如果需要创建id，使用XYZDataBaseId_interface以及XYZDataBaseId_implementation创建
 * 同步异步方法确保不能同时使用，否则将造成crash
 **/
@interface XYZDBModel : NSObject
XYZDataBaseId_interface(id)

@end
