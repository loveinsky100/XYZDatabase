//
//  XYZAnimal.h
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZDBModelStructCoding.h"
#import <UIKit/UIKit.h>

typedef struct _XYZ
{
    int xyz;
}XYZ;

@interface XYZAnimal : NSObject<XYZDBModelStructCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger name1;
@property (nonatomic, assign) CGFloat name2;
@property (nonatomic, assign) NSInteger name3;
@property (nonatomic, assign) XYZ name100;

@property (nonatomic, strong) NSArray *name6;
@property (nonatomic, strong) NSDictionary *name7;
@end
