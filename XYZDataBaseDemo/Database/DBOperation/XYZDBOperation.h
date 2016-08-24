//
//  XYZDBOperation.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef id (^XYZDBOperationBlock)();
typedef void (^XYZDBOperationCallBack)(id value);

@interface XYZDBOperation : NSOperation
@property (nonatomic, strong) NSObject *dbModel;
@property (nonatomic, copy) XYZDBOperationBlock operation;
@property (nonatomic, copy) XYZDBOperationCallBack callBack;
@end
