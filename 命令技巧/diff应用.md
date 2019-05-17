比较两个目录下的文件差异, 可以通过`--exclude`排除指定文件

```
diff -rBb ./61.gokit-lorem-consul ./62.gokit-lorem-consul-client --exclude=*.log --exclude=*.md
```

- `-r`: 递归操作, 目标比较的关键选项.
