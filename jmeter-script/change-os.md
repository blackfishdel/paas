
当我们在架设高可用服务器环境时会遇到来自于系统级别的连接数限制问题，这是因为CentOS根据系统硬件信息自己默认初始了一个限制连接数量，往往这个数量是我们遇到
的问题，所以今天我们需要修改系统的默认值来达到我们需要的要求，解决一定的高并发产生的连接数问题。

# 解除 Linux 系统的最大进程数和最大文件打开数限制
> 说明：* 代表针对所有用户，noproc 是代表最大进程数，nofile 是代表最大文件打开数

根据下面提示修改系统文件：

``` text
[root@server ~]# vi /etc/security/limits.conf
新增：
*               soft    nofile          65535
*               hard    nofile          65535
*               soft    nproc           65535
*               hard    nproc           65535
```
退出当前ssh，并从新连接服务器。

当前系统limits配置：

``` text
[root@server ~]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 257755
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited

open files                      (-n) 65535
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 65535
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

```
首先，假如要使用大量线程的话，ramp-up period 一般不要设置成零。 因为假如设置成零，Jmeter将会在测试的开始就建立全部线程并立即发送访问请求
，这样一来就很轻易使服务器饱和，更重要的是会隐性地增加了负载，这就意味着服务器将可能过载，不是因为平均访问率高而是因为所有线程的第一次并发访问而引起的不正常的
初始访问峰值，可以通过Jmeter的聚合报告监听器看到这种现象。

load averages:负载均值(系统)

Load Balancing:负载均衡(网络)
