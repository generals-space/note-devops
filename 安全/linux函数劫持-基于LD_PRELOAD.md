# linux函数劫持-基于LD_PRELOAD

<!--

<!tags!>: <!共享库!> <!链接库!>

-->

原文链接

[The magic of LD_PRELOAD for Userland Rootkits](http://fluxius.handgrep.se/2011/10/31/the-magic-of-ld_preload-for-userland-rootkits/)

参考文章

[linux--函数劫持--基于LD_PRELOAD](http://www.2cto.com/os/201406/306008.html)

[解决LD_PRELOAD无法截获printf的问题](http://www.bubuko.com/infodetail-899506.html)

用户空间的`rootkit`虽然拥有的权限比内核空间`rootkit`低了许多, 但对用户来说, 它们依然是一个重大威胁. 为了证明这点, 本文我们将讨论一个有意思的技术-函数劫持/函数钩子(hook functions), 这个技术被普遍用于程序中**共享库**的实现.

## 1. 共享库

我们都知道, 动态库的链接是在程序加载时实现. 链接工作是由`ld-linux-x86-64.so.X`实现, 32位系统可能是`ld-linux.so.X`, 可以通过如下手段验证.

```
$ readelf -l /bin/ls
  INTERP         0x0000000000000238 0x0000000000400238 0x0000000000400238
                 0x000000000000001c 0x000000000000001c  R      1
      [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
```

相对于静态编译庞大的体积而言, 动态编译就小多了. 对于其中的部分库函数只保留了一个指向相关库的指针, 并没有包含函数的实体. 

可以使用`ldd`命令列出指定程序所依赖的共享库.

```
general@ubuntu:~$ ldd /bin/ls
	linux-vdso.so.1 =>  (0x00007fffe01fe000)
	libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007faf6720e000)
	librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007faf67006000)
	libacl.so.1 => /lib/x86_64-linux-gnu/libacl.so.1 (0x00007faf66dfd000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007faf66a3c000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007faf66838000)
	/lib64/ld-linux-x86-64.so.2 (0x00007faf67437000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007faf6661a000)
	libattr.so.1 => /lib/x86_64-linux-gnu/libattr.so.1 (0x00007faf66415000)
```

------

一个编译的实例.

```c
/*shared.c*/
#include <stdio.h>
int main()
{
    printf("shared lib test...\n");
}
```

分别进行动态和静态编译.

```
$ gcc shared.c -o shared-dyn
$ gcc -static shared.c -o shared-stat
$ ll
-rwxrwxr-x  1 general general   8378 Apr 24 04:07 shared-dyn*
-rwxrwxr-x  1 general general 879423 Apr 24 04:07 shared-stat*
```

两者都可以正常执行, 但静态程序与动态程序体积相差了100多倍. 我们看看它们两者所依赖的共享库都有啥.

```
$ ldd ./shared-dyn 
	linux-vdso.so.1 =>  (0x00007fffd9de4000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f6d19c26000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f6d19ff1000)
$ ldd ./shared-stat 
	not a dynamic executable
```

呐, `shared-stat`没有依赖共享库.

对于共享库的命名, 我们有一些习惯. 如果一个库的名字是"soname", 那么通常会加一个前缀"lib",一个后缀".so",以及一个版本号. 

现在我们可以来看一下LD_PRELOAD了.

## 2. 简单的LD_PRELOAD

我们知道, 库文件一般存放在`/lib`目录下. 所以如果想修改一个库, 最容易想到的办法就是找到该库的源码 , 修改之后再重新编译一遍. 但除了这种方案, 我们还有另一种很酷的方法, 就是使用Linux提供给我们的一个外部接口: `LD_PRELOAD`.

### 2.1 制作和使用共享库

假如你希望重写C提供的`printf`函数, 可以这样先编写一个你自己的`printf`函数.

```c
/*my_printf.c*/
#define _GNU_SOURCE
#include <unistd.h>
int printf(const char *format, ...)
{
    write(0, "abc\n", 5);
    return;
}
```

然后把它编译成一个共享库.

```
## 首先编译, 但不链接
$ gcc -Wall -fPIC -c -o my_printf.o my_printf.c
## 然后使用中间文件生成共享库
$ gcc -shared -fPIC -Wl,-soname -Wl,libmy_printf.so -o libmy_printf.so  my_printf.o
```

然后我们修改一个环境变量, 再运行刚才的测试程序`shared-dyn`.

```
$ export LD_PRELOAD=$PWD/libmy_printf.so
$ ./shared-dyn
abc
```

> 原文中这里顺利执行, 但我自己实验时, 发现`shared-dyn`测试程序依然保持原来的行为. 这个问题通过第2篇参考文章中提到的方法得以解决. 做法是, 在编译`shared-dyn`时, 加上`-fno-builtin-printf`选项, 禁止gcc使用内建函数. 

现在来看一个新问题. 如果我们的目标仅仅是简单的修改一下"printf"的行为, 但不破坏原有的功能. 那要怎么办呢, 重写整个函数?！！ 那样明显是不合适的, 为了处理这个问题, 可以看下面的几个函数. 

### 2.2 dlsym()

在库"libdl"中有几个有趣的函数

- `dlopen()`: 加载一个库

- `dlsym()`: 获取一个特定符号的指针

- `dlclose()`: 卸载一个库

因为库已经在程序启动时就加载好了, 我们只需要直接调用`dlsym`就可以了. 我们给`dlsym`传`RTLD_NEXT`参数, 用来获取指向原有的`printf`函数的指针. 就像这样

```c
	[...]
			typeof(printf) *old_printf;
	[...]		 
			//DO HERE SOMETHING VERY EVIL
			old_printf = dlsym(RTLD_NEXT, "printf");
	[...]
```

然后我们需要对格式化字符串进行一点特殊处理(对应一般的参数是不需要这么麻烦的, 因为`printf`接受的是可变参数)，处理完了之后就可以直接用了.

```c
/*my_printf.c*/
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <stdarg.h>

int printf(const char *format, ...)
{
    va_list list;
    char *parg;
    typeof(printf) *old_printf;

    // format variable arguments
    va_start(list, format);
    // vasprintf()函数类似于sprintf(), 输出指定格式的字符串到char*变量
    vasprintf(&parg, format, list);
    va_end(list);

    // 这里你可以写你自己的攻击性代码了.
    write(0, "wakaka\n", 7);

    // 得到原"printf"函数的指针
    old_printf = dlsym(RTLD_NEXT, "printf");
    // vasprintf()时已经得到了要输出的字符串, 
    // 这里就只用printf直接输出就可以了, 不必再次进行格式化
    (*old_printf)("%s", parg); // and we call the function with previous arguments

    free(parg);
    return 0;
}
```

再重新编译并生成共享库

```
$ gcc -Wall -fPIC -c -o my_printf.o my_printf.c
$ gcc -shared -fPIC -Wl,-soname -Wl,libmy_printf.so -o libmy_printf.so  my_printf.o
$ export LD_PRELOAD=$PWD/libmy_printf.so
$ ./shared-dyn
wakaka
./shared-dyn: symbol lookup error: /tmp/libmy_printf.so: undefined symbol: dlsym
```

可以看到printf()函数已经被成功改写, 但是真正的`printf()`并未执行, 这是由于上面2.1节尾部的问题引起的, 如果在编译时加了`-fno-builtin-printf`, 则无法再调用原来的`printf`函数, 但如果不加这个选项, 则`printf`根本不会被劫持. 这算是一点疑问, 未能解决<???>.

### 2.3 使用限制

这种方式虽然很酷，但却有一些限制。比如对于静态编译的程序是无效的。因为静态编译的程序不需要连接动态库的面的函数。而且，假如文件的SUID或SGID位被置1，加载的时候会忽略LD_PRELOAD(这是ld的开发者出于安全考虑做的)。

## 3. 相关的隐匿技术

接下来的看不懂了...<???>