//
//  XYZAnimal.m
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZAnimal.h"

@implementation XYZAnimal
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ name = %@", NSStringFromClass([self class]), self.name];
}

- (NSData *)encodeStructProperty:(NSString *)name
{
    XYZ xyz = self.name100;
    return [[NSData alloc] initWithBytes:&xyz length:sizeof(xyz)];
}

- (void)decodeStructProperty:(NSData *)data name:(NSString *)name
{
    XYZ xyz;
    if([name isEqualToString:@"name100"])
    {
        [data getBytes:&xyz length:sizeof(XYZ)];
    }
    
    self.name100 = xyz;
}
@end
