# XYZDatabase
```
dispatch_async(xyz_database_test_queue(), ^{
        XYZ xyz; // struct
        xyz.xyz = 9000;
        XYZAnimal *animal = [[XYZAnimal alloc] init];
        animal.name6= @[@1, @2, @3];
        animal.name7 = @{@1:@100, @2:@200, @3:@300};
        animal.name = @"animal";
        animal.name100 = xyz;
        [animal save];
        
        XYZAnimal *find = [XYZAnimal find:animal.id];
        NSLog(@"%@", find);
        
        find.name = @"change";
        [find update];
        
        [find delete];
    });
    
    [XYZAnimal find:1
           callBack:^(id value) {
               //
           }];
           
 ```