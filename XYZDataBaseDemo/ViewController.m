//
//  ViewController.m
//  XYZDataBaseDemo
//
//  Created by Leo on 16/8/24.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "ViewController.h"
#import "XYZAnimal.h"
#import "XYZCat.h"
#import "XYZDog.h"

static dispatch_queue_t xyz_database_test_queue()
{
    static dispatch_queue_t xyz_database_test_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xyz_database_test_queue = dispatch_queue_create("xyz_database_test_queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return xyz_database_test_queue;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_async(xyz_database_test_queue(), ^{
        XYZ xyz; // struct
        xyz.xyz = 9000;
        XYZAnimal *animal = [[XYZAnimal alloc] init];
        animal.name6= @[@1, @2, @3];
        animal.name7 = @{@1:@100, @2:@200, @3:@300};
        animal.name = @"animal";
        animal.name100 = xyz;
        [animal save];
        
        XYZAnimal *find = [XYZAnimal find:animal.id][0];
        NSLog(@"%@", find);
        
        find.name = @"change";
        [find update];
        
        NSLog(@"%@", find.variables);
        
        [find delete];
    });
    
    [XYZAnimal find:1
           callBack:^(id value) {
               //
           }];
 
    dispatch_async(xyz_database_test_queue(), ^{
        XYZDog *dog = [[XYZDog alloc] init];
        dog.name = @"dog";
        dog.dog = @"Hello";
        [dog save];
    });
    
    dispatch_async(xyz_database_test_queue(), ^{
        XYZCat *cat = [[XYZCat alloc] init];
        XYZProprety *pro = [[XYZProprety alloc] init];
        pro.proName = @"Hello world";
        cat.name = @"cat";
        cat.cat = @"World";
        cat.someProprety = pro;
        [cat save];
    });
    
    dispatch_async(xyz_database_test_queue(), ^{
        NSLog(@"%@", [XYZDog findBy:@"_name" value:@"dog"]);
        
//        NSLog(@"%@", [XYZAnimal findBy:@"_name" value:@"animal"]);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
