#!/bin/bash -ex

# 秒为单位
time=1
time_count=$[60*60]
dir_path=~/log

rm -rf $dir_path

mkdir -p $dir_path

# CPU使用情况的统计信息
sar -u $time $time_count >> $dir_path/sar-cpu.log

# 内存和交换空间的统计信息
sar -r $time $time_count >> $dir_path/sar-memory.log

# I/O和传送速率的统计信息
sar -b $time $time_count >> $dir_path/sar-io.log

# 进程队列长度和平均负载状态统计信息
sar -q $time $time_count >> $dir_path/sar-load.log

# 进程队列长度和平均负载状态统计信息
sar -w $time $time_count >> $dir_path/sar-context.log

