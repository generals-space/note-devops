## linux下expect工具使用详解

<!tags!>: <!expect!>

参考文章

1. [expect学习笔记（一）](http://blog.chinaunix.net/uid-22516719-id-2191642.html)

### 1. expect简单介绍与安装

`expect`是实现与`ssh`, `ftp`等命令交互的工具, 它能根据期望出现的字符串, 自动输入预先设置的值, 实现自动登录等操作. 普通的shell命令没有办法做到自动输入(反正我是没找到). 不过你需要对该交互流程相当熟悉并且其行为可预见才行.

linux的`expect`工具是需要安装的(无法搜索到或无法安装时可以先执行`update`命令):

```shell
sudo apt-get install expect
yum install expect
```

安装完成之后不必使用`whereis`或`man`等查询你在网上看到的`expect`脚本中出现的命令(`spawn`, `send`等)的位置, 因为这些东西是`expect`工具内置的, 在bash下不可使用.

下面看一个简单的`expect`脚本实例

### 2. 初级使用与指令简析

我们先尝试简单的登录脚本的实现, 这是最常用的使用方式.

#### 2.1 登录脚本

用`expect`工具编写一个最简单的登录脚本. 新建文件`login.exp`, 该脚本能实现自动登录不用手动输入密码, **注意第1行**

```bash
#!/usr/bin/expect
set timeout 10
set user "root"
set ip "你的IP地址"
set password "你的密码"

spawn ssh $user@$ip

expect "password:"
send "$password\n"

expect "#"
interact
```

**执行方式**

看脚本第1行就应该知道, 这不是一个bash脚本, 所以`bash ./login.exp`执行会出错. 正确的方式是, `chmod 777 ./login.exp` 赋予其执行权限, `./login.exp`开始执行.

这样就可以实现自动登录, 不必每次登录时重复输入密码与回车了, 尤其是你记不住密码, 每次都需要复制粘贴时, 这个脚本会带给你极大的便利.

**指令简析**

- **`\#!/usr/bin/expect`:** `expect`相当于另一个环境变量下的`bash`, 但在这个环境下只能使用`expect`本身提供的命令. 无法运行`bash`命令(比如`ls`, `echo`等), 甚至连基本的变量赋值都做不到(也不是不可以, 见`spawn`指令), 所以在expect脚本中, `变量名=值`的语句是非法的。

- **`set`:** 用于变量赋值(`expect`脚本内`use="root"`这样的赋值方式是非法的).

- **`spawn`:** 进入`expect`环境后才可以执行的`expect`内部命令, 功能是在`expect`脚本中启动一个新的进程，用来传递交互指令.

- **`expect "password:"`**: 这里的`expect`是expect工具的一个指令, 判断终端输出结果里是否包含"password:"字符串, 如果有则立即返回, 否则就等待一段时间后返回, 这里等待时长就是前面设置的`timeout`值, 10秒.

- **`send "$password\n"`**: 当终端输出包含`expect`期望的字符串后, `send`指令向终端发送指定字符串, 相当于手动输入. 注意末尾的"\n", 相当于按下回车. **如果上面的expect的行为没有匹配到的话,  将会跳过下面的指令.**

- **`expect "#"; interact`**: 当出现"#"字符时, 说明以root身份登录成功, `interact`指令是将终端控制权还给用户, 这时用户可以自行操作了. **注意: 如果没有`interact`这一句, 脚本终将会退出, 不会给用户输入密码或操作远程终端的机会.**

#### 2.2 传入参数

接下来说**传入参数**的问题. 有时候我们希望在`bash`脚本中远程登录某主机, 执行一些指令后退出. 但`expect`脚本只能做一些交互式的工作, 也没有提供`bash`中的命令, 这时我们希望在`bash`脚本中调用`expect`脚本. 那就有可能涉及传入参数和问题, 比如目标IP与密码.

首先说明参数传递的方法, `expect`脚本中通过`[lindex $argv 0]` 这种形式获得命令行中的参数(不能多不能少, 有中括号没有单双引号哦). 需要注意的是, `bash`脚本中第0个参数`$0`一般是脚本名称, 即真正的输入参数是从`$1`开始的; 但`expect`脚本则真的是从第0个开始的, 即`[lindex $argv 0]`.

一个简单示例, 还是`login.exp`:

```bash
#!/usr/bin/expect
set timeout 10
set user "root"
set ip [lindex $argv 0]
set password [lindex $argv 1]

spawn ssh $user@$ip

expect "password:"
send "$password\n"

expect "#"
interact
```

**执行方式**

```shell
./login.exp 目标IP 密码
```

### 3. 进阶使用与语法简析

第2节只是简单介绍了`expect`脚本的基本使用方式, 可以说是理想状态下的场景. 实际上可能出现多种情况, 比如第1次登录远程主机时key的保存, 与接下来脚本的执行流程如何继续, root登录时终端提示符为"#"而普通用户登录时为"$", 密码不正确时怎么办等. 而expect提供了类似程序语言的指令, 我们通过例子学习一下如何处理这些情况.

当使用ssh登录一台远程主机时, 可能有以下4个流程:

- 当前机器第1次登录远程主机, 需要保留目标主机的key.

- 对方已保留我们的key, 此时无需密码直接登录

- 通过提示输入密码完成验证

- 密码不正确, 直接阻塞在这一步或连续3次提示出错然后退出.

我们需要判断执行结果, 引导执行流程.

#### 3.1 if...else.../switch

如下示例, 判断了首次登录时未进行主机验证时的情况:

```bash
#!/usr/bin/expect
set timeout 10
set user "root"
set ip "你的IP地址"
set password "你的密码"

spawn ssh $user@$ip

expect "(yes/no)?" {
    send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
    send "yes\n"

    expect "password:"
	send "$password\n"
} "password:" {
	send_user "\n主机验证通过, 输入密码...\n"
	send "$password\n"
}

expect "#"
interact
```

`expect`语句本身相当于C语言中的`if`, 即在`timeout`时间内如果出现其期望的字符串, 将执行其下一条指令(如果是多条的话, 可以用大括号包围起来); 如果没有出现则跳过, 继续执行下面的语句.

而`else`的情况就像脚本中最大段的`expect`语句所示, 大括号里面的指令为顺序执行, 但两个大括号之间却是只能执行其中一个, 典型的`if...else.../switch`执行方式.

**`send_user:`** 接收一个字符串作为参数, 在脚本执行过程中在终端显示, 相当于日志输出, 方便调试.

#### 3.2 switch

其实`switch`就是多个`if...else...`的方式, 都差不多, 但是`expect`提供了类似`continue`这样的指令, 虽然使用方式跟`if...else...`形式下几乎完全相同, 但还是通过`switch`形式理解起来会更容易一些.

3.1节中的脚本可以改写为

```bash
#!/usr/bin/expect
set timeout 10
set user "root"
set ip "你的IP地址"
set password "你的密码"

spawn ssh $user@$ip

expect {
	"(yes/no)?" {
	    send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
	    send "yes\n"

	    exp_continue
	}
	"password:" {
		send_user "\n主机验证通过, 输入密码...\n"
		send "$password\n"
	}
}

expect "#"
interact
```

**`exp_continue`:** `expect`块中的选项都只能执行1条(如果把exp_continue去掉, 脚本就会卡在输入密码的地方, 需要用户手动输入), 加上了`exp_continue`后, "yes/no"的判断结束会**再次执行当前块的匹配, 就是说从(yes/no)?再次开始**. 是不是很像程序语言中`for`循环的`continue`?

这个指令其实也可以在3.1中`if...else...`形式下使用, 差不了多少. 不过当作`switch`更容易理解些. 不过`break`指令好像只能在`for/while`循环中使用, 至于`for/while`循环是否存在及如何使用, 因为我觉得一般用不到, 就不去深究了.

------

现在提出一个问题, 如果想要实现`break`的功能, 该怎么办? 这个问题的应用场景是, 如果提供的密码不正确, 就结束交互, 退出脚本. 这个问题在下面的4.3节讨论.

### 4. 高级理解

说是高级也只是入门级的"高级", 真正深奥的还是要看官方文档.

#### 4.1 关于匹配

**`expect`支持通配符的匹配, 完全匹配与正则表达式匹配**

通配符是默认就支持的, 可以直接使用?与*;

完全匹配则需要`expect -ex "目标字符串"`选项;

正则表达式则需要`expect -re`选项才能开启, 比如:

```bash
expect -re "(password:.)$"`
```

这个例子有点别扭, 就是匹配ssh登录时输入密码的提示, 以"password: "结尾(但要注意, 冒号后面还有一个空格).其他的可以根据需要自行设计正则.

#### 4.2 混合脚本

`expect`脚本有诸多限制, 而在`bash`脚本中调用`expect`脚本又太麻烦. 当一个简单功能不想分成两个脚本来写时, 就希望能在`bash`脚本中直接运行`expect`中的指令. 我查到有两种方式可以实现, 不过也并不是十分完美, 可以参见本节末尾的解释.

根据man手册, 可以使用`expect`工具的`-c`选项, 如下脚本所示.

> 注意, 这次是`bash`脚本, `bash ./脚本名`就可以运行了.

```bash
#!/bin/bash
user=root
ip="你的IP地址"
password='你的密码'

#expect工具的-c选项可以包含脚本内容
expect -c "
    set timeout 10

    spawn ssh $user@$ip
    expect {
        \"(yes/no)?\" {
            send_user \"\n第1次登录需要接受主机验证哦! 接受...\n\"
            send \"yes\n\"

            exp_continue
        }
        \"password:\" {
            send_user \"\n主机验证通过, 输入密码...\n\"
            send \"$password\n\"
        }
    }

    expect \"\#\"
    interact
"
```

------

上述脚本中引号转义有些麻烦, 有一种非正规的手段, 可以是这样:

```shell
#!/bin/bash
user=root
ip="你的IP地址"
password='你的密码'

/usr/bin/expect <<-EOF
    set timeout 10
    spawn ssh $user@$ip

    expect {
        "(yes/no)?" {
            send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
            send "yes\n"

            exp_continue
        }
        "password:" {
            send_user "\n主机验证通过, 输入密码...\n"
            send "$password\n"
        }
    }
    expect "#"
    interact
EOF

echo "success"
```

但是这种方式有一种缺陷--**无法完成`interact`指令**. 就是说, 登录完成之后或是密码输入提示下的`interact`都不会生效, 无法为用户提供交互终端. 原因应该是脚本执行遇到了EOF结束, 但是去掉EOF这一行依然会退出. 而`expect -c`选项的混合脚本执行完后则可以正常交互, 所以第2种方式只能在有限的情况下使用.

另外, **在混合脚本中使用`set`指令没有办法正确设置变量值**, 因为使用`send_user`输出变量名得到的是空值.

#### 4.3 关于spawn进程

我们已经知道在`expect`脚本中无法执行`bash`命令, 而`spawn`可以将其看作在`expect`脚本中运行`bash`命令的一种方式, 它在`expect`脚本中创建新的进程执行`bash`命令, 该进程的标准输入输出与标准错误与`expect`进程相连, 因此`expect`的指令可以读写它们, 还可以通过指令断开或关闭这个进程.

注意, `send`等操作默认是对当前`spawn`创建的进程进行交互的, 如果多次使用`spawn`运行`bash`命令, `send`可能无法确定该向哪个进程发送ssh的交互信息了.

既然是进程, 就可以有多进程, 而识别进程的方式就是进程id了. 不过好像这个id无法输出, 只能在内部使用, 当前正在与send等沟通的id用$spawn_id标识.

下面看一个小例子, 我们准备一个错误的密码, 这样ssh会连续3次提示密码错误. 在第1次输入密码之后第2次输入之前, 使用`spawn`执行`echo`指令, 这个例子会执行出错, 因为`send`无法找到与它交互的`spawn`进程了, 也就是说, 它不知道接下来把密码发送给哪个进程了.

```shell
#!/bin/bash
user=root
ip="你的IP地址"
password1='错误密码'
password2='正确密码'

expect -c "
    set timeout 10
    spawn ssh $user@$ip
    expect {
        \"(yes/no)?\" {
            send_user "\n第1次登录需要接受主机验证哦! 接受...\n\"
            send \"yes\n"

            exp_continue
        }
        \"password:\" {
            send_user \"\n主机验证通过, 输入密码...\n\"
            send \"$password1\n\"
        }
    }
    spawn echo \"我是echo...\"
    expect \"password:\" {
        send \"$password2\n\"
    }
    expect \"\#\"
    interact
"
```

这个脚本在执行时会报错, 如下所示.

```shell
spawn ssh root@你的IP
root@你的IP's password:
主机验证通过, 输入密码...
spawn echo 我是echo...
我是echo...
send: spawn id exp7 not open
    while executing
"send "正确密码\n""
```

这就是因为`spawn echo`又创建了1个新进程, 并且$spawn_id立即指向了它的id, 虽然这个进程立刻就结束了, 但$spawn_id保存的还是这个进程的id, 接下来与`send`等都与这个死掉的进程交互. 这明显是不对的, 所以会提示报错. 去掉`spawn echo`这一行, 脚本即可正常运行.

------

那如何不删除`spawn echo`而让这个脚本能正常运行呢? 那就使用1个中间变量`spawn_id_old`先将`ssh`的`spawn_id`存储下来, 执行完`spawn echo`后, 再将spawn_id_old的值还给spawn_id就行了.

可惜的是, 这种方法在混合脚本中行不通, 混合脚本中`expect`部分的`set spawn_id_old $spawn_id`这句会报错, 所以只能使用纯`expect`脚本了. 示例如下

```shell
#!/usr/bin/expect
set timeout 10
set user "root"
set ip "你的IP地址"
set password1 "错误密码"
set password2 "正确密码"

spawn ssh $user@$ip
set spawn_id_old $spawn_id
expect {
        "(yes/no)?" {
                send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
                send "yes\n"
        }
        "password:" {
                send_user "\n主机验证通过, 输入密码...\n"
                send "$password1\n"
        }
}

spawn echo "我是echo..."

set spawn_id $spawn_id_old
expect "password:"
send "$password2\n"

expect "#"
interact
```

`spawn`创建的进程有3种类型, 存储/取回也另有方法, 这是更高级的层次, 这里就不详细讲述了

------

接下来是对`spawn`进程的操作, 我所知的有2条指令: `exit`和`close` (有一个`disconnect`与fork指令有关, 太深奥了, 不解释).

`close`指令将关闭与当前进程的连接, 或者说将当前$spawn_id进程kill掉.
`exit`指令则是引起`expect`脚本直接退出, 跳过下面的所有内容.

以下面的脚本为例.

在第1次输入错误密码之后第2次输入之前, 用`spawn`创建一个新的`ping`进程(linux中的`ping`命令在没有任何参数的情况下是会一直执行的). 然后让脚本`sleep` 10s的时间, 使用`close`指令将此`ping`进程关闭. 重新找到ssh进程, 输入正确的密码, 完成登录.

需要说明的是`ping`进程在这10s内的输出没有显示在终端(不知道为什么, 按理说该`ping`进程的标准输入输出应该与`expect`脚本连接在一起了), 但是使用`tcpdump -i 目标网络设备 'icmp'`可以捕捉到ping包, 说明`ping`进程的确是执行了.

将`close`换成`exit`试试? 你会发现在`ping`进程结束之后脚本就直接退出了, 没有机会输入正确密码去完成登录. 这就是`close`与`exit`的区别.

```shell
#!/usr/bin/expect
set timeout 10
set user "root"
set ip "你的IP地址"
set password1 "错误密码"
set password2 "正确密码"

spawn ssh $user@$ip
set spawn_id_old $spawn_id

expect {
        "(yes/no)?" {
                send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
                send "yes\n"
        }
        "password:" {
                send_user "\n主机验证通过, 输入密码...\n"
                send "$password1\n"
        }
}

spawn ping "www.baidu.com"
sleep 10
close

set spawn_id $spawn_id_old
expect "password:"
send "$password2\n"

expect "#"
interact
```

#### 4.4 输出与日志

有时我们总需要在脚本执行过程中输出一些信息, 不管是控制台还是日志文件.

前面的例子可以看出`send_user`指令的作用, 就是将字符串在控制台输出, 使用比较方便(起码比`spawn echo "..."`方式好多了). 不过如果想要将结果输出到文件, 貌似只有用`spawn echo`重定向了. 不过`expect`提供了日志工具, 可以将结果直接输出到指定文件.

有一个设想的应用场景: 公司有几千台服务器, 几经人事交接, 有的主机已经不知道密码是什么, 但由于有的人还保留着登录key, 所以还有补救的方法, 现在需要确定的是那些没有key又没有密码的主机IP.

用脚本判断目标主机上是否保留有本机的key, 也是就说是否需要密码登录, 需要密码时提供的密码是否正确. 能够成功登录时则自动退出, 如果没有key并且提示密码错误, 不要等待3次, 直接结束本次验证并输出当前IP.

##### 4.4.1 控制台输出

```shell
#!/bin/bash
user=root
ip="你的IP地址"
password='错误/正确密码'

/usr/bin/expect <<-EOF
    set timeout 10
    spawn ssh $user@$ip

    expect {
        "(yes/no)?" {
            send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
            send "yes\n"

            exp_continue
        }
        "password:" {
            send_user "\n主机验证通过, 输入密码...\n"
            send "$password\n"
        }        
    }

    expect {
        "#" {
            send "exit\n"
        }
        "password:" {
            send_user "\n 密码错误, 该IP为 $ip\n"
            close
        }
    }
EOF
```

改动下密码, 看看分别会输出什么?

##### 4.4.2 日志输出

控制台的信息还是太繁杂而且没办法重定向到文件, 需要日志输出时可以使用`expect`的`log_file`与`send_log`命令.

- **`log_file "文件名"`:** 指定目标日志文件
- **`send_log "字符串"`:** 向日志文件**追加**字符串

4.4.1节的脚本可以改写为

```
#!/bin/bash
user=root
ip="你的IP地址"
password='待检测密码'

/usr/bin/expect <<-EOF
    set timeout 10
    log_file login.log

    spawn ssh $user@$ip

    expect {
        "(yes/no)?" {
            send_user "\n第1次登录需要接受主机验证哦! 接受...\n"
            send "yes\n"

            exp_continue
        }
        "password:" {
            send_user "\n主机验证通过, 输入密码...\n"
            send "$password\n"
        }        
    }

    expect {
        "#" {
            send "exit\n"
        }
        "password:" {
            send_log "\n 密码错误, 该IP为 $ip\n"
            close
        }
    }
EOF
```

不过日志输出的结果其实也不简洁, 但是可以通过前缀字符串找到我们需要的信息, 所以查找起来也还算方便.

#### 4.5 作用域与返回值

还是4.4节要解决的问题. 这里只是稍作讨论, 作用域的应用场景还是混合脚本, 而返回值则是分离脚本时使用的了.

##### 4.5.1 作用域

这里在 **`bash`** 部分设置一个标识位`result`, 值为0; 在`expect`部分, 如果能够成功登录则将其设置为1, 否则保持不变. 最后回到`bash`, 输出`result`的值.

尝试结果:

- `expect`部分不能执行`bash`命令, 也不能完成运算, `result=1`语句会报错.

- `set result 1`并没有对`bash`部分的result值产生影响

- `spawn result=1`方式会报错.

- 甚至在登录成功时`spawn touch success`, 在登录失败时`spawn touch fail`也不行, 看来`expect`会在自身执行完毕之后清除自己产生的所有痕迹.

没有找到其他可行的方法完成变量传递, 想法搁浅.

##### 4.5.2 返回值

最初在解决密码验证问题时的想法是, 查看`expect`中ssh的执行结果(退出码), 如果成功登录, 则$?==0, 如果未完成密码验证$?==n(n>0, ctrl+c取消时n是130)--但是并没有成功, `expect`脚本不支持设置自定义的退出码, 而直接在调用`expect`脚本完成之后输出其执行结果总是得到0.

从程序语言角度上来看, 传值传递与传址传递还有返回值

### 5. 结语

这里只是讲了对`expect`在实际运维使用时的一些认识, 入门时可以少走很多弯路, 真正高深的在于`expect`所依赖的Tcl程序语言, 我自己是没什么兴趣的, 不过想深入了解的话参考\<\<Expect 教程中文版\>\>, 译者是*葫芦娃*, 讲的比较深入与透彻.
