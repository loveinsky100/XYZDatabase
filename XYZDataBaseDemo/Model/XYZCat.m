//
//  XYZCat.m
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZCat.h"

@implementation XYZCat
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ name = %@, dog = %@", NSStringFromClass([self class]), self.name, self.cat];
}
@end
