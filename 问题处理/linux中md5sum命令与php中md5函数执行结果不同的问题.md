# linux中md5sum命令与php中md5函数执行结果不同的问题

原文链接

[php中md5函数与linux中md5sum命令执行结果不同的问题(转)]()

简而言之, linux中用`echo "123"| md5sum`或`md5sum 文件名`方式来计算某串的md5值, 串中都有隐含的字符串`\0`终止符或换行符的存在, 所以并非只计算了"123"的md5值.

大可不必怀疑md5算法. 用`echo –n "123" | md5sum`即可得出与php中md5函数相同的结果.

如果是针对文件计算md5值, 则可以使用`tr`命令将最后一个字段移除

```
cat test.txt | tr -d '\n' | md5sum
```
