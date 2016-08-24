//
//  XYZDBOperationQueue.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYZDBOperation;

@interface XYZDBOperationQueue : NSObject
+ (id)sharedXYZDBOperationQueue;
- (void)addOperation:(XYZDBOperation *)operation;
- (BOOL)cancelOperation: (XYZDBOperation *)operation;
- (void)cancelAll;
@end
