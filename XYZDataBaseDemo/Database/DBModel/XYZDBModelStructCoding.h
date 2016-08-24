//
//  XYZDBModelStructCoding.h
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XYZDBModelStructCoding <NSObject>

@required
- (NSData *)encodeStructProperty:(NSString *)name;
- (void)decodeStructProperty:(NSData *)data name:(NSString *)name;

@end