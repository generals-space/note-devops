# Shell-无空格分隔分割字符串

原字符串: `12345abcde`

期望结果:

```
1
2
3
4
5
a
b
c
d
e
```

处理方法:

1. `echo 12345abcde | grep -Po '.'`

2. `echo '12345abcde' | fold  -w1`