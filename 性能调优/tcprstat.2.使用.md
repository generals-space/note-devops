# tcprstat编译安装

参考文章

1. [tcprstat分析服务的响应速度利器](https://www.cnblogs.com/qmfsun/p/11726702.html)
2. [通过 tcprstat 工具统计应答时间](https://gohalo.me/post/linux-tcprstat.html)
3. [Lowercases/tcprstat](https://github.com/Lowercases/tcprstat/releases)
    - github 仓库地址及二进制下载地址

## 格式

`--format`: 默认格式为`%T\t%n\t%M\t%m\t%a\t%h\t%S\t%95M\t%95a\t%95S\t%99M\t%99a\t%99S`

| 占位符 | 字段标题  | 字段描述     |
| :----- | :-------- | :----------- |
| %T     | timestamp | 单位: 秒     |
| %n     | count     | 响应时间总量 |
| %M     | max       |              |
| %m     | min       |              |
| %a     | avg       |              |
| %h     | med       |              |
| %S     | stddev    |              |
| %95M   | 95_max    |              |
| %95a   | 95_avg    |              |
| %95S   | 95_std    |              |
| %99M   | 99_max    |              |
| %99a   | 99_avg    |              |
| %99S   | 99_std    |              |

