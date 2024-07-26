# shell-echo并发写文件[多进程]

参考文章

1. [Parallel writing to a file from multiple processes by using echo](https://stackoverflow.com/questions/33887938/parallel-writing-to-a-file-from-multiple-processes-by-using-echo)
2. [Is echo atomic when writing single lines](https://stackoverflow.com/questions/9926616/is-echo-atomic-when-writing-single-lines/9927415#9927415)

高级语言进行并发编程时, 如果需要写入同一个文件, 需要对文件加锁, 算是一个常识吧.

现在我遇到了一种场景, 使用`python`多线程调用一系列shell脚本, 这些脚本最终都会生成一些结果写入到同一个文件中, 写入顺序不需要关心, 不会影响最终结果.

那么问题来了, shell脚本中写文件一般是用重定向机制`>>`, `>`, 会造成被写入文件的混乱吗?

