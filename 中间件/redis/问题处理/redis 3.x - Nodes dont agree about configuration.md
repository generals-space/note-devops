# redis 3.x - Nodes dont agree about configuration

参考文章

1. [Redis [ERR] Nodes don’t agree about configuration!问题分析处理](https://blog.csdn.net/wgw_dream/article/details/83615503)
2. [Redis 集群错误 Nodes don't agree about configuration!](https://blog.csdn.net/wenhaowang/article/details/84191966)

问题描述

三主三从集群扩展到五主五从时, 将3等份的`slot`重新划分为5等份, 并重新进行迁移, 迁移操作大概如下

### slot分布

0. 0-5460
1. 5461-10922
2. 10923-16383
3. nil
4. nil

### 操作步骤

| id   | node   | count | src slot                  | dst slot                  |
| :--- | :----- | :---- | :------------------------ | :------------------------ |
| 1    | 0 -> 3 | 3277  | (0-5460, nil)             | (3277-5460, 0-3276)       |
| 2    | 1 -> 0 | 1093  | (5460-10922, 3277-5460)   | (6554-10922, 3277-6553)   |
| 3    | 1 -> 4 | 3276  | (6554-10922, nil)         | (9830-10922, 6554-9829)   |
| 4    | 2 -> 1 | 2184  | (10923-16383, 9830-10922) | (13107-16383, 9830-13106) |

第1次迁移是可以成功的, 但是之后的迁移操作经常会报错

```
Nodes don’t agree about configuration!
```

测试发现, 在`reshard`命令执行完毕后, 再次执行`reshard`需要等待一会, 这个时间设置为5-10秒比较合适.
