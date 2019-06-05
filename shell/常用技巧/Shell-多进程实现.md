# Shell脚本技巧-多进程实践

<!tags!>: <!shell!> <!多进程!>

参考文章

1. [用fifo来处理linux shell下的多进程并发](https://my.oschina.net/sanpeterguo/blog/133304)

shell脚本在大部分情况下都是顺序执行的, 后面的语句必须要等待前面的执行完毕后才能执行. 但是通过`&`可以将当前要执行的命令放到后台, 而不阻塞之后的代码执行.

## 1. 子进程pid

很多高级语言中(如C, python等), 都是使用`fork`系统调用创建子进程, `fork`会返回两次, 父进程中可以得到子进程的pid, 子进程则会得到0.

shell脚本中可以通过内置变量`$!`得到后台运行的最后一个进程号.

下面是一个简单的双进程脚本

```shell
#!/bin/bash

ping -c 10 www.baidu.com > /tmp/ping_baidu &
subpid1=$!
ping -c 20 www.taobao.com > /tmp/ping_taobao &
subpid2=$!

echo $subpid1 $subpid2
jobs
```

执行它, 在控制终端你会得到如下输出, 6811与6812分别是对baidu和taobao的ping进程pid.

```
6811 6812
[1]-  Running                 ping -c 10 www.baidu.com > /tmp/ping_baidu &
[2]+  Running                 ping -c 20 www.taobao.com > /tmp/ping_taobao &
```

## 2. 等待子进程结束-wait

在多进程的代码实现中, 很多时候我们需要等待某个子进程执行完毕后再决定之后的流程走向, 这就需要用到`wait`命令.

wait的使用方法这里不再详述, 这里来一个多进程实现的示例.

```
#!/bin/bash

ping -c 20 www.baidu.com > /tmp/ping_baidu &
subpid1=$!
ping -c 10 www.taobao.com > /tmp/ping_taobao &
subpid2=$!

echo $subpid1 $subpid2
jobs

wait $subpid1 ; echo '百度已ping完'
```

执行它, 得到如下输出

```
general@ubuntu:/tmp$ bash multiproc.sh 
6951 6952
[1]-  Running                 ping -c 20 www.baidu.com > /tmp/ping_baidu &
[2]+  Running                 ping -c 10 www.taobao.com > /tmp/ping_taobao &
百度已ping完
```

不过, 也正是因为它只能指定特定的子进程, 所以没有办法让所有子进程像回调一样在完成时执行指定操作, 其它语言也没这么用的. 

## 3. 锁

多进程编程里, 最重要的是就是锁的设计和使用了. 下面的代码中使用了`fifo`表示锁, 使用`read`与`echo`来获取与解除锁, 很巧妙. 

```shell
#!/bin/bash

#创建一个fifo文件
FIFO_FILE=/tmp/$.fifo
mkfifo $FIFO_FILE

#关联fifo文件和fd6
## 这里关联fifo文件与描述符是有必要的, 因为直接对fifo的写入操作是一个
## 阻塞的过程, 但是对该描述符的写入是不需要等待的...好强大
exec 6<>$FIFO_FILE
rm $FIFO_FILE

#最大进程数
PROCESS_NUM=4

#向fd6中输入$PROCESS_NUM个回车
for ((idx=0;idx<$PROCESS_NUM;idx++));
do
    echo
done >&6 

#sub process do something
function sub_process {
    ## 我想我知道作者使用$$的意图, 但是它不能得到子进程的pid.
    echo "processing in pid [$$]"
    sleep 1
}

#处理业务，可以使用while
for ((idx=0;idx<20;idx++));
do
    #read -u6命令执行一次，相当于尝试从fd6中获取一行，如果获取不到，则阻塞
    #获取到了一行后，fd6就少了一行了，开始处理子进程，子进程放在后台执行
    read -u6  
    {
      sub_process && { 
         echo "sub_process is finished"
      } || {
         echo "sub error"
      }
      #完成后再补充一个回车到fd6中，释放一个锁
      echo >&6 # 当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
    } &
done

#关闭fd6
exec 6>&- 
```

## 4. 示例

要求是对以下列表中每个网站ping 10次.

`pinglist.txt`

```
www.baidu.com
www.taobao.com
www.jd.com
www.mi.com
www.zhihu.com
www.douban.com
weibo.com
www.163.com
www.qq.com
v.qq.com
www.huawei.com
www.meizu.com
www.apple.com
cn.razerzone.com
cn.bing.com
www.amazon.com
```

以下是单进程的脚本, `single.sh`

```shell
#!/bin/bash
filename=pinglist
echo '' > /tmp/ping_result
line_sum=$(cat $filename | wc -l)
for ((line_num = 1; line_num <= $line_sum; line_num ++))
do
    line=$(sed -n "${line_num}p" $filename)
    ## echo $line
    ping -c 10 $line >> /tmp/ping_result && echo $line 'finished'
done
```

执行结果是

```
general@ubuntu:/tmp$ time bash single.sh 
www.baidu.com finished
www.taobao.com finished
www.jd.com finished
www.mi.com finished
www.zhihu.com finished
www.douban.com finished
weibo.com finished
www.163.com finished
www.qq.com finished
v.qq.com finished
www.huawei.com finished
www.meizu.com finished
www.apple.com finished
cn.razerzone.com finished
cn.bing.com finished
www.amazon.com finished

real	2m30.167s
user	0m0.124s
sys	0m0.394s
```

下面是使用了多进程的脚本, `multi.sh`

```shell
#!/bin/bash

#创建一个fifo文件
FIFO_FILE=/tmp/$.fifo
mkfifo $FIFO_FILE

#关联fifo文件和fd6
exec 6<>$FIFO_FILE
rm $FIFO_FILE

#最大进程数
PROCESS_NUM=4

#向fd6中输入$PROCESS_NUM个回车
for ((idx=0;idx<$PROCESS_NUM;idx++));
do
    echo
done >&6 

filename=pinglist
echo '' > /tmp/ping_result
line_sum=$(cat $filename | wc -l)
for ((line_num = 1; line_num <= $line_sum; line_num ++))
do
    line=$(sed -n "${line_num}p" $filename)
    ## echo $line
    read -u6
    {
        ping -c 10 $line >> /tmp/ping_result && {
            echo $line 'finished'
        } || {
            echo $line 'error'
        }
        echo >&6
    } &
done

#关闭fd6
exec 6>&- 
```

执行它, 得到

```
general@ubuntu:/tmp$ time bash multiproc.sh 
www.baidu.com finished
www.taobao.com finished
www.jd.com finished
www.mi.com finished
www.zhihu.com finished
www.douban.com finished
weibo.com finished
www.163.com finished
www.qq.com finished
v.qq.com finished
www.meizu.com finished
www.huawei.com finished

real	0m27.256s
user	0m0.086s
sys	0m0.299s
```

...好像不只快了`PROCESS_NUM`倍...神了.