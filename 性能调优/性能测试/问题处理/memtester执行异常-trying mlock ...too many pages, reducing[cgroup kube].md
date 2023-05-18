参考文章

1. [Memtester?](https://forums.raspberrypi.com/viewtopic.php?t=211648)
    - memtester 的执行需要 root 权限, 如果是在 kube/docker 容器中, 则需要 privileged 特权.

## 问题描述

在Pod里面进行内存申请测试, 判断 cgroup 的内存限制是否生效时(limit), 无法成功, 甚至1M都申请不下来.

```log
[root@general-deploy01-7fbf77466b-5bnmf /]# memtester 1m 1
memtester version 4.5.1 (64-bit)
Copyright (C) 2001-2020 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 1MB (1048576 bytes)
got  1MB (1048576 bytes), trying mlock ...too many pages, reducing...
got  0MB (1044480 bytes), trying mlock ...too many pages, reducing...
got  0MB (102400 bytes), trying mlock ...too many pages, reducing...
got  0MB (98304 bytes), trying mlock ...too many pages, reducing...
got  0MB (69632 bytes), trying mlock ...too many pages, reducing...
got  0MB (65536 bytes), trying mlock ...locked.
Loop 1/1:
  Stuck Address       : ok
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok
  Block Sequential    : ok
  Checkerboard        : ok
  Bit Spread          : ok
  Bit Flip            : ok
  Walking Ones        : ok
  Walking Zeroes      : ok
  8-bit Writes        : ok
  16-bit Writes       : ok

Done.
```

按照参考文章1中所说, memtester 需要 sudo 权限, 让我想起可能容器需要 privileged 特权模式.

开启特权模式后, 果然可以了.
