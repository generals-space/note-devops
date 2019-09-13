# Shell-格式化输出之前缀补全printf

参考文章

1. [shell中如何保证数值的位宽,不足补零](https://zhidao.baidu.com/question/1860205257450652267.html)
    - printf, awk printf
2. [C语言格式输出函数printf()详解](http://c.biancheng.net/cpp/html/33.html)

## printf

宽度与对齐

```console
## 指定宽度, 用空格补全
[root@k8s-worker-7-17 ~]# printf '%5d\n' 123
  123
## 指定以0补全...貌似也只能指定0了, 指定其他字符都没法输出
## 除0以外的数字都都当作宽度了, 而指定字母的话会当作进制, 特殊符号直接报错...
[root@k8s-worker-7-17 ~]# printf '%05d\n' 123
00123
## 默认右对齐, 左侧空格补全
[root@k8s-worker-7-17 ~]# printf '%5d %d\n' 123 45
  123 45
## `-`号可指定为左对齐
[root@k8s-worker-7-17 ~]# printf '%-5d %d\n' 123 45
123   45
```

精度

```
## %d无法输出小数位, 需要使用%f
[root@k8s-worker-7-17 ~]# printf '%5d\n' 123.45
-bash: printf: 123.45: 无效数字
  123
[root@k8s-worker-7-17 ~]# printf '%10f\n' 123.45
123.450000
## 点号.指定精度
[root@k8s-worker-7-17 ~]# printf '%10.2f\n' 123.45
    123.45
```

## awk printf

`awk`中的printf指令行为与纯printf命令上几乎完全一致.

```
[root@k8s-worker-7-17 ~]# echo 123 | awk '{printf "%5d\n", $1}'
  123
[root@k8s-worker-7-17 ~]# echo 123 | awk '{printf "%05d\n", $1}'
00123
[root@k8s-worker-7-17 ~]# echo 123 45 | awk '{printf "%5d %d\n", $1, $2}'
  123 45
[root@k8s-worker-7-17 ~]# echo 123 45 | awk '{printf "%-5d %d\n", $1, $2}'
123   45
```

```
[root@k8s-worker-7-17 ~]# echo 123.45 | awk '{printf "%5d\n", $1}'
  123
[root@k8s-worker-7-17 ~]# echo 123.45 | awk '{printf "%10f\n", $1}'
123.450000
[root@k8s-worker-7-17 ~]# echo 123.45 | awk '{printf "%10.2f\n", $1}'
    123.45
```

