# Linux命令-PS

[ps命令的-o选项使用](http://fantefei.blog.51cto.com/2229719/1425304)

## 列属性认识


## 指定进程输出(指定行)

指定进程号, 指定用户, 指定某会话相关的进程等

## 指定格式输出(指定列)

`ps`命令的`-o`选项可以输出的列, 格式为`ps -o format`. 其中`format`参数是以空格或逗号分隔的列表. 

常用列属性的关键字如下(使用`man ps`查看`STANDARD FORMAT SPECIFIERS`小节会有更详细的说明...太多了, 无法一一列举)

- `%cpu`: 在第1行的列名显示为`%CPU`, 表示当前进程CPU利用率, 百分数(不过没有百分号`%`), 一般不会出现`100%`的情况. 又名`c`, 不过在第1列的列名显示的就不是`%CPU`而是`C`了.

- `%mem`: 第1行的列名显示为`%MEM`, 表示当前进程对物理内存的利用率, 百分数.

- `command`: 完整的启动命令, 其另一种形式为`comm`, 只显示命令名, 无启动参数.

- `rss`: `resource size`的缩写形式, 表示当前进程占用的, 未被放在swap空间的内存大小, 即活动内存, 以`KB`为单位. 同`top`中的`RES`列.

- `vsz`: `virtual size`的缩写, 表示当前进程占用的虚拟内存大小, 不一定是存储在swap空间的大小, 很可能是非活动性内存(比如缓存之类<???>), 以`KB`为单位. 同`top`中的`VIRT`列.

- `start_time`: 进程启动的时间, 从启动开始到当前的**人类时间**(相对于占用CPU的总时间). 又名`bsdstart`, `start`, `lstart`和`stime`都是同一个意思. 同`top`中的`TIME+`.

- `cputime`: 当前进程占用CPU的总时间, 显示列名为`TIME`. 又名`time`.

- `stat`: 当前进程运行状态, man手册中`PROCESS STATE CODES`章节有对状态码的详细描述.

另外, `ps`的`-o`还可以指定输出结果在第一行的显示的列名, 如下

```
## 查看init进程的cpu和内存状况
$ ps -o pid,%cpu=abc,%mem=123 -p 1
   PID  abc  123
     1  0.3  1.3
```

不过这种自定义有时好像也不是那么好使

```
## 偏移得有点多...
$ ps -o pid=jinchenghao,%cpu=abc,%mem -p 1
jinchenghao,%cpu=abc,%mem
                        1
```

## 输出结果操作-排序