//
//  DBModel.h
//  DiarySchedules
//
//  Created by Leo on 16/1/6.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) id value;
@end
