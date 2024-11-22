# OOM分析

参考文章

1. [oom killer理解和日志分析:知识储备](https://www.jianshu.com/p/ba1cdf92a602)
    - linux中物理内存结构: node > zone > page
    - vm.overcommit_memory
2. [oom killer理解和日志分析:日志分析](https://www.jianshu.com/p/8dd45fdd8f33)
    - 以一个完整的 OOM 日志为例, 分析其中各字段的含义.

日志分析:

## 1. 

`kernel: AliYunDun invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0`

上面的日志表明这是由`AliYunDun`进程的一次内存申请失败触发的`OOM`事件, 其中`order=0`表示本次申请内存的大小0, 也就是4KB(一个page的大小). 

不过我个人觉得`AliYunDun`作为一个监控agent, 并不是真的想要申请这么点大的内存, 而是在监控系统性能情况.

## 2. 

```log
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 5424]  1000  5424 36913689  1537770   66407 
...

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Out of memory: Kill process 5424 (java) score 800 or sacrifice child
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Killed process 5424 (java) total-vm:147654756kB, anon-rss:6151080kB, file-rss:0kB
```

上述的进程表中, `total_vm`, `rss`的单位是`4KB`, 为一个页的大小.

其中, `36913689 * 4 = 147654756`, `1537770 * 4 = 6151080kB`, 都是可以对应上的.

