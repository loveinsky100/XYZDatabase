//
//  XYZDog.m
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDog.h"

@implementation XYZDog
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ name = %@, dog = %@", NSStringFromClass([self class]), self.name, self.dog];
}
@end
