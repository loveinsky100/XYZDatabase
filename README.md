# XYZDatabase

####主要功能
支持多数据库模式

```
NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
NSString *docsDir = dirPaths[0];
NSString *path = [NSString stringWithFormat:@"%@/%@", docsDir, @"XYZDatabase.sqlite"];;
    
XYZDatabase *database = [[XYZDatabase alloc] initWithDatabasePath:path];
XYZDatabaseSQL *SQL = [[XYZDatabaseSQL alloc] init];
```


支持自定义表结构，默认采用属性进行生成表结构，以id为主键，支持表结构动态更新

```
功能完善中
```

支持model存储，查找数据，自动转化为model，也可重载方法手动转化，或者进行加密存储

```
XYZDog *dog = [[XYZDog alloc] initWithDatabase:self.database];
dog.name = @"dog";
dog.dog = @"Hello";
[dog save];

------------------------------------------------------

find.name = @"change";
[find update];
    
[find delete];

```
支持直接执行SQL，支持链式语法生成SQL

```
XYZAnimal *find = SQL.

select(@"*").
from([XYZAnimal class]).
where(@"id").
equal([NSString stringWithFormat:@"%ld", animal.id]).
excuteQuery(database)[0];
```