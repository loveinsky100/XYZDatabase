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
#import "NSObject+XYZDB.h"
#import "XYZDatabaseSQL.h"
#import "XYZDatabase.h"

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
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", docsDir, @"XYZDatabase.sqlite"];;
    
    XYZDatabase *database = [[XYZDatabase alloc] initWithDatabasePath:path];
    XYZDatabaseSQL *SQL = [[XYZDatabaseSQL alloc] init];

    XYZ xyz; // struct
    xyz.xyz = 9000;
    XYZAnimal *animal = [[XYZAnimal alloc] initWithDatabase:database];
    animal.name6= @[@1, @2, @3];
    animal.name7 = @{@1:@100, @2:@200, @3:@300};
    animal.name = @"animal";
    animal.name100 = xyz;
    [animal save];
    
    XYZAnimal *find = SQL.
    
    select(@"*").
    from([XYZAnimal class]).
    where(@"id").
    equal([NSString stringWithFormat:@"%ld", animal.id]).
    excuteQuery(database)[0];
    
    NSLog(@"%@", find);
    
    find.name = @"change";
    [find update];
    
    NSLog(@"%@", find.variables);
    
    [find delete];
    
 
    XYZDog *dog = [[XYZDog alloc] initWithDatabase:self.database];
    dog.name = @"dog";
    dog.dog = @"Hello";
    [dog save];
    
    XYZCat *cat = [[XYZCat alloc] init];
    XYZProprety *pro = [[XYZProprety alloc] initWithDatabase:self.database];
    pro.proName = @"Hello world";
    cat.name = @"cat";
    cat.cat = @"World";
    cat.someProprety = pro;
    [cat save];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
