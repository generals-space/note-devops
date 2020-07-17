# Linux命令-curl -w选指定项输出格式

curl命令内置了许多输出, 如状态码, 抓取速度, 总时间等, 可通过`-w`选项选择性输出.

```shell
## 输出抓取百度首页的平均速度
$ curl -s -o /dev/null -w '%{speed_download}\n' www.baidu.com
61669.000
## 平均速度与总时间
$ curl -s -o /dev/null -w '--%{speed_download}--%{time_total}--\n' www.baidu.com
--96451.000--0.025--
```

其他可使用的字段可以参见curl命令的man手册.
