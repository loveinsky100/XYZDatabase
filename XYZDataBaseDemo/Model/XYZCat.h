//
//  XYZCat.h
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "XYZAnimal.h"
#import "XYZProprety.h"

@interface XYZCat : XYZAnimal
@property (nonatomic, copy) NSString *cat;
@property (nonatomic, strong) XYZProprety *someProprety;
@end
