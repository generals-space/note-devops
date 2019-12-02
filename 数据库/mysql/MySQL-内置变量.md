# MySQL-系统变量

参考文章

1. [[MYSQL] 变量（参数）的查看和设置](http://www.cnblogs.com/ning-blogs/p/5063255.html)

MySQL的变量分为以下两种: 

1. 系统变量: 配置MySQL服务器的运行环境, 可以用`show variables`查看

2. 状态变量: 监控MySQL服务器的运行状态, 可以用`show status`查看

系统变量按其作用域的不同可以分为以下两种: 

1. 全局（GLOBAL）级: 对整个MySQL服务器有效

2. 会话（SESSION或LOCAL）级: 只影响当前会话

有些变量同时拥有以上两个级别, MySQL将在建立连接时用全局级变量初始化会话级变量, 但一旦连接建立之后, 全局级变量的改变不会影响到会话级变量. 

## 1. 查看系统变量的值

可以通过`show vairables`语句查看系统变量的值, 不加任何约束条件时可以得到所有变量.

使用like语句过滤, 百分号`%`可作为常规通配符中的'*', 下划线`_`可用作'?'.

```
mysql> show variables like 'log%';
```

可以通过键名与键值双重限定.

```
mysql> show variables where variable_name like 'log%' and value='ON';  
```

注意: `show variables`优先显示会话级变量的值, 如果这个值不存在, 则显示全局级变量的值, 当然你也可以加上`GLOBAL`或`SESSION`关键字区别: 

```
mysql> show global variables;  
mysql> show session/local variables;  
```

也可以使用`select@@变量名`这种方式查询.

```
mysql> select@@version;
+-----------+
| @@version |
+-----------+
| 5.7.18    |
+-----------+
1 row in set (0.00 sec)

```

可用的模式有

1. @@GLOBAL.变量名  

2. @@SESSION.变量名

3. @@LOCAL.变量名  


如果在变量名前没有级别限定符, 将优先显示会话级的值. 

在写一些存储过程时, 可能需要引用系统变量的值, 正好可以使用这种方法.


最后一种查看变量值的方法是从`INFORMATION_SCHEMA`数据库里的`GLOBAL_VARIABLES`和`SESSION_VARIABLES`表按照常规select语句获得.

## 2. 设置和修改系统变量的值

在MySQL服务器启动时, 有以下两种方法设置系统变量的值: 

1）命令行参数, 如: mysqld --max_connections=200

2）选项文件（my.cnf）

在MySQL服务器启动后, 如果需要修改系统变量的值, 可以通过SET语句: 

```
SET GLOBAL var_name = value;  
SET @@GLOBAL.var_name = value;  
SET SESSION var_name = value;  
SET @@SESSION.var_name = value;  
```

如果在变量名前没有级别限定符, 表示修改会话级变量. 

注意: 和启动时不一样的是, 在运行时设置的变量不允许使用后缀字母'K'、'M'等, 但可以用表达式来达到相同的效果, 如: 

```
SET GLOBAL read_buffer_size = 2*1024*1024  
```

这里一个容易把人搞蒙的地方是如果查询时使用的是`show variables`的话, 会发现设置好像并没有生效, 这是因为单纯使用`show variables`的话就等同于使用的是`show session variables`, 查询的是会话变量, 只有使用`show global variables`, 查询的才是全局变量. 

网络上很多人都抱怨说他们set global之后使用show variables查询没有发现改变, 原因就在于混淆了会话变量和全局变量, 如果仅仅想修改会话变量的话, 可以使用类似`set wait_timeout=10;`或者`set session wait_timeout=10;`这样的语法. 

## 3. 状态变量

状态变量可以使我们及时了解MySQL服务器的运行状况, 可以使用`show status`语句查看. 

状态变量和相同变量类似, 也分为全局级和会话级, `show status`也支持`like`匹配查询, 比较大的不同是状态变量只能由MySQL服务器本身设置和修改, 对于用户来说是只读的, 不可以通过SET语句设置和修改它们. 

也不能使用`select @@变量名`查看.

```
mysql> select@@Uptime;
ERROR 1193 (HY000): Unknown system variable 'Uptime'
mysql> 

```