# Linux命令技巧-如何看懂man手册

当你去找某个命令的用法之前, 应该就已经知道它是用来做什么的了.  对新手来说最重要的demo or example, 这方面直接去百度搜索反而好些.

当你渐渐熟练, 要求慢慢复杂, 已经无法再搜索出完全符合的example的时候, 就只有man能帮得上你. **只有知道一条命令是用来做什么, 和它基本的语法的时候, man才是助力**. 刚开始接触shell命令行, 还是按照教程来吧.

## 1. 手册结构

### 1.1 section-章节结构

man的确是个手册, 它把自己保存的命令分成几种类型(第三方软件在安装时也会将自己的使用说明按照这些类型放置到指定位置), 大致分为如下几种:

1. `User Commands`:	用户指令, 所有人都可以使用

2. `System Calls`: 系统调用, 由内核提供的API接口

3. `C Library Functions`: C语言库文档, 与MSDN的作用相似

4. `Devices and Special Files`: `/dev`目录下的设备和特殊文件

5. `File Formats and Conventions`: 文件格式描述, 例如`/etc/passwd`

6. `Games et. Al.`: 游戏(没用过)

7. `Miscellanea`: 杂项

8. `System Administration tools and Deamons`: 系统管理工具和服务

可能不是大懂, 举个例子:

shell下有一个`read`命令, 可从终端读入用户输入, 用于shell脚本与用户的交互. man将其归为第1部分, 可使用`man 1 read`查阅其用法;

然而Linux内核提供了一个同名的系统调用`read`, 用于从文件描述符(打开的文档可用文件描述符标识)中以字节为单位读取数据到内存, 可以在Linux下编写的C程序中直接调用. man将此归为第2部分, 可使用`man 2 read`查阅;

看到差别了?

### 1.2 内容结构

man手册页内容分为几个小节, 可在实际查阅命令用法时指向明确

- `Name`: 命令的名称和用途(摘要)

- `Synopsis`: 命令语法(摘要)

- `Description`: 完整描述

- `Environment`: 命令使用的环境变量

- `Author`: 作者

- `Files`: 对该命令重要的文件列表

- `See also`: 查看相关的信息的位置

- `Diagnostics`: 可能的错误和警告

- `Bugs`: 错误, 缺点, 警告

其中查看命令用法的时候我们最关心的应该是第1, 2, 3项.

## 2. 语法格式

man手册中对指令的说明语法一般时单词和符号的组合, 很多人不清楚单词之间的关系, 还有符号代表的含义.

### 2.1 涉及的单词

单词大致有这么几个:

- `options`: 选项

- `args(arguments)`: 参数

- `command`: 命令

- `pattern`: 模式

- `expression`: 表达式

它们一般按照符号(比如方括号, 圆括号等)表明的方式进行组合, 关系比较密切的是options与args这两个, 因为选项也是可以有自己的参数的, 组合方式会在下面进行说明.

### 2.2 关于option

这个是最常见的了

1. 首先是选项可以有自己的参数;

2. 另外选项的形式有两种: 短选项(-)与长选项(--):

- 长选项: 用 `--` 引导,后面跟完整的单词, 如 `--help`

- 短选项: 用 `-` 引导,后面跟单个的字符, 如 `-a`

多个短选项可以组合使用, 例如: `-h -l -a` == `-hla`

但是长选项不能组合使用, 如 `--help`后面就不能再跟另外一个单词了, 只能分开写.

### 2.3 符号

Linux命令的参数组合方式几乎完全取决于符号的描述, 下面来看一下man手册中可能出现符号所代表的含义.

#### 2.2.1 知识点

1. 方括号`[`, `]`中的内容是可选的;

2. 没有在方括号, 而是在大括号{}, 或是在尖括号<>中的内容是必选的;

3. 黑体(...也可能叫粗体)部分必须原样输入, 这一类可能是命令名, 标识, 或文字字符;

4. 斜体字必须用适当的值代替(不显示斜体字的系统上通常用下划线代替), 就如变量一般, 需要根据情况自己添加适当的值;

5. 后面接省略号…的参数可以多次重复;

6. 由竖线 | (shell中的管道符)字符分开的两个或多个项，表示可以从这个列表中选择一个项;

7. 如果一个单独的选项和一个参数组合在一起, 那么该选项和参数必须同时使用;

#### 2.2.2 示例

(1)以`find`命令为例, 其man手册的`SYNOPSIS`的格式为

```
SYNOPSIS
       find [-H] [-L] [-P] [-D debugopts] [-Olevel] [starting-point...] [expression]
```

所有的选项都处于[]中, 所以所有选项都是可选的, 当然也可以不选(不过这样就没什么意义了...), 直接运行find命令看看发生了什么? 好吧, 它将当前目录下的所有文件全部列出来了(子目录下的也是). 印证了第1点;

看看`[-D debugopts]`, `-D`选项与自己的参数`debugopts`组合在一起, 必须要同时使用哦. man手册中有对-D选项的debugopts参数的详细介绍. `find -D help`看看吧. 印证了第7点;

还有`[starting-point...]`, 这个是搜索路径, 默认是当前目录, 它后面有一个省略号..., 说明可以同时搜索多个目录. 运行`find /etc/ /home/ -name profile`试试看?(`-name profile`是`[expression]`中的东西, 可以自行翻阅man手册). 印证了第5点;

说到`expression`, 翻阅`find`的`expression`部分, 它有自己的选项, 有`-mindepth levels`/`-regextype type`等, 呐,斜体或者下划线, 也就是说`levels/type`是你可以自定义的变量, 可以根据需要自行赋值. 印证了第4点;

(2)再来看`yum/dnf`命令, 它们两个一样的哦

```
SYNOPSIS
       dnf [options] <command> [<args>...]
```

这里的<command>就比如install, update, upgrade这些, 他们是必须存在的. 印证了第2点(你也可以找找在{}或是在括号外面的选项, 它们的含义一样的);

仔细看看man中`dnf`与其他普通字体是不是有些不同? 它是黑体的哦(...还是叫粗体?), 所以`dnf`这三个字母必须原样输入...其实含义差不多啦. 向下翻翻, 应该会有`dnf clean dbcache`这样的命令, 它们都是黑体的, 所以直接原样输入就好了, 用以实现特定功能. 印证了第3点;

(3)netstat

```
SYNOPSIS
       netstat [address_family_options]  [--tcp|-t]  [--udp|-u]  [--udplite|-U]  [--sctp|-S]  [--raw|-w]  [--l2cap|-2]
       [--rfcomm|-f]  [--listening|-l] [--all|-a] [--numeric|-n] [--numeric-hosts] [--numeric-ports] [--numeric-users]
       [--symbolic|-N]  [--extend|-e[--extend|-e]]  [--timers|-o]  [--program|-p]   [--verbose|-v]   [--continuous|-c]
       [--wide|-W] [delay]

       ...
       netstat {--version|-V}

       netstat {--help|-h}
```

其实长选项与短选项都可以用管道符分隔, 印证了第6点;

注意可能有很多netstat这样有多行语法的命令, 只需要选取确定的行就好了, 不必为了其他行而眼花缭乱. 如果我只是想看netstat的版本, 就选取倒数第二行, 按照它的语法放置参数即可.

