# centos 8装docker-ce缺少containerd.io的问题

参考文章

1. [记一次CentOS Install Docker 报错](https://www.cnblogs.com/kuiyajia/articles/11585493.html)

```
[root@k8s-master-01 yum.repos.d]# yum install docker-ce
Last metadata expiration check: -1 day, 18:44:15 ago on Wed 23 Oct 2019 06:48:06 PM CST.
Error:
 Problem: package docker-ce-3:19.03.4-3.el7.x86_64 requires containerd.io >= 1.2.2-3, but none of the providers can be installed
  - cannot install the best candidate for the job
  - package containerd.io-1.2.10-3.2.el7.x86_64 is excluded
  - package containerd.io-1.2.2-3.3.el7.x86_64 is excluded
  - package containerd.io-1.2.2-3.el7.x86_64 is excluded
  - package containerd.io-1.2.4-3.1.el7.x86_64 is excluded
  - package containerd.io-1.2.5-3.1.el7.x86_64 is excluded
  - package containerd.io-1.2.6-3.3.el7.x86_64 is excluded
(try to add '--skip-broken' to skip uninstallable packages or '--nobest' to use not only best candidate packages)
```

用的是阿里的docker-ce源, centos 7上完全没问题, 但是centos 8就报了上面的错误.

虽然看上去像是包版本冲突, 或是缺少包依赖, 但实际上是因为docker-ce此时(2019-10-23)还没有推出centos 8的源.

解决办法是访问如下地址

```
https://download.docker.com/linux/centos/7/x86_64/edge/Packages/
```

down下来一个最高版本的 containerd.io rpm包, 然后用yum安装, 注意是用yum装, 不是rpm.

然后就可以装 docker-ce 了.

我们访问一下 `https://download.docker.com/linux/centos/`, 会发现只有centos 7的入口, 在`docker-ce.repo`中, 只有版本7的入口, 如果在centos 8使用这个源文件, 就会找不到对应系统的依赖.

```
## Index of linux/centos/
../
7/
docker-ce.repo                                                                        2019-10-18 21:57:38 2.4 KiB
gpg                                                                                   2019-10-18 21:57:38 1.6 KiB
```
