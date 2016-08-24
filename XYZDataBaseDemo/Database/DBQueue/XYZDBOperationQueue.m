//
//  XYZDBOperationQueue.m
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDBOperationQueue.h"
#import "SynthesizeSingleton.h"
#import "XYZDBOperation.h"

@interface XYZDBOperationQueue()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation XYZDBOperationQueue
SYNTHESIZE_SINGLETON_FOR_CLASS(XYZDBOperationQueue)

- (void)dealloc
{
    self.operationQueue = nil;
    [super dealloc];
}

- (instancetype)init
{
    if(self = [super init])
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1; // 单线程执行
    }
    
    return self;
}

- (void)addOperation:(XYZDBOperation *)operation
{
    [self.operationQueue addOperation: operation];
}

- (BOOL)cancelOperation:(XYZDBOperation *)operation
{
    [operation cancel];
    return operation.cancelled;
}

- (void)cancelAll
{
    [self.operationQueue cancelAllOperations];
}

@end
