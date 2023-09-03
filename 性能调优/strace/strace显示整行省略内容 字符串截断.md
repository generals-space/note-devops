# strace显示整行省略内容 字符串截断

参考文章

1. [Prevent strace from abbreviating arguments?](https://stackoverflow.com/questions/6672743/prevent-strace-from-abbreviating-arguments)

系统调用的实际参数太长, starce的输出会将其截断, 如下 

```log
readlink("/proc/self/exe", "/usr/local/gopath/src/github.com"..., 128) = 59
open("/usr/local/gopath/src/github.com/containerd/nerdctl/nerdctl", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0755, st_size=111139664, ...}) = 0
pread64(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\2\0>\0\1\0\0\0p1@\0\0\0\0\0"..., 64, 0) = 64
pread64(3, "\213\\$0H\211\\$hH\213\\$`H\211\234$\340\0\0\0H\213\\$hH\211\234$\350"..., 64, 13892458) = 64
pread64(3, "\0\0\0\0\0\0\0\0\0\0\0\0\10\0\0\0\0\0\0\0002\212\7o\0\10\10\26 \"\302\4"..., 64, 27784916) = 64
pread64(3, "3\0C\250=n\2\0\0\0\0google.golang.org/pro"..., 64, 41677374) = 64
pread64(3, "autotmp_1404\0\232\220\1`K\260\1\0\0\0\0github.c"..., 64, 55569832) = 64
pread64(3, "\1\320\3\177\1\200\1\25\0\354\27\267\4\0\352\2\36\2\v\2(\6(\2\27\4\25\4\t\4\23\2"..., 64, 69462290) = 64
pread64(3, "\334\1\0\0\0\0\0\10\0\25bucket<int64,*google.g"..., 64, 83354748) = 64
pread64(3, "\1\2\5\3T\1\2\32\3\t\1;\2\374\0\3\"\1\2\5\3m\1;\2\374\0\3\22\1\2\5"..., 64, 97247206) = 64
```

如果想展示全部的信息, 可以通过`-s`参数指定输出的字符串长度, 默认为32.

```
strace -s 500 -p $PID
```

