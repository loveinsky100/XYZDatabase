//
//  XYZDBOperation.m
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDBOperation.h"

@implementation XYZDBOperation
- (void)dealloc
{
    self.dbModel = nil;
    self.operation = nil;
    self.callBack = nil;
    [super dealloc];
}

- (void)main
{
    if(self.operation)
    {
        id value = self.operation();
        if(self.callBack)
        {
            [self performSelectorOnMainThread:@selector(callBackAction:)
                                   withObject:value
                                waitUntilDone:NO];
        }
    }
}

- (void)callBackAction:(id)value
{
    self.callBack(value);
}
@end
