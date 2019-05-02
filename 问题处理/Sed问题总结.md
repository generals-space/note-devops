# Sed应用方法及问题总结

## 1. 使用sed时出现问题

```
$ sed -n '0,3p' ./result 
sed: -e expression #1, char 4: invalid usage of line address 0
...
$ cat ./result | sed -n '0,3p'
sed: -e expression #1, char 4: invalid usage of line address 0
```

出现原因:

...**sed的行号是从1开始的**, 所以它不明白第0行在哪里.

解决办法: 

把行号从0改成1就行了.

## 符号应用

在使用sed的正则时, 基本正则中没有`+`号(匹配一次或多次), 只有`*`(匹配0次或多次)