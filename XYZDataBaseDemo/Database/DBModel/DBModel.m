//
//  DBModel.m
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "DBModel.h"

@implementation DBModel
- (void)dealloc
{
    self.name = nil;
    self.type = nil;
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\rname: %@\rtype: %@\rvalue: %@\r\r", self.name, self.type, self.value];
}

@end