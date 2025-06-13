# Linux查看系统与硬件信息.2.proc目录

## 1. CPU信息

`cat /proc/cpuinfo`中的信息

- processor       逻辑处理器的id. 
- physical id    物理封装的处理器的id. 
- core id        每个核心的id. 
- cpu cores      位于相同物理封装的处理器中的内核数量. 
- siblings       位于相同物理封装的处理器中的逻辑处理器的数量. 

1. 查看物理CPU的个数

```
cat /proc/cpuinfo | grep "physical id"| sort | uniq| wc -l
```

2. 查看逻辑CPU的个数

```
cat /proc/cpuinfo | grep "processor"| wc -l
```

3. 查看CPU是几核

```
cat /proc/cpuinfo | grep "cores"| uniq
```

4. 查看CPU的主频

```
cat /proc/cpuinfo | grep MHz| uniq 
```
