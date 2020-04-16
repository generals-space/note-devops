# Linux-chroot 由救援模式想到的

参考文章

1. [理解 chroot](https://www.ibm.com/developerworks/cn/linux/l-cn-chroot/index.html)
    - 什么是 chroot
    - 为何使用 chroot
    - chroot 的使用

感觉参考文章说得还是比较浅显, 按照其中的实验, 感觉到`chroot`只实现了`PATH`变量的切换, 以及编译链接过程中共享库的寻找, 没有其他额外的解释, 比如环境变量, 进程空间等.

