### dstat

> versatile tool for generating system resource statistics

dstat可以替换vmstat、iostat、ifstat

dstat示例

```
$ dstat
You did not select any stats, using -cdngy by default.
----total-cpu-usage---- -dsk/total- -net/total- ---paging-- ---system--
usr sys idl wai hiq siq| read  writ| recv  send|  in   out | int   csw
  2   3  95   0   0   0| 431B   57k|   0     0 |   0     0 |6533    22k
  5   8  86   1   0   0|   0   144k|  16k   41k|   0     0 |  30k   58k
  4   7  89   0   0   0|   0    40k|5903B 9497B|   0     0 |  29k   56k
  3   7  90   0   0   0|   0    40k|1681B 3591B|   0     0 |  28k   55k
  3   7  90   0   0   0|   0     0 |1390B 3392B|   0     0 |  28k   55k
```

### vmstat

> Report virtual memory statistics

2秒间隔，共计5次

```
$ vmstat 2 5
procs -----------memory------------    ---swap-   ----io-- ---system--   ------cpu------
 r  b   swpd    free   buff    cache   si   so    bi    bo     in   cs   us  sy id wa st
 3  1      0 2791140 462208 11551124    0    0     0     6     0    1    2   3  95  0  0
 0  0      0 2788628 462208 11551148    0    0     0    22 29005 56548   3   6  89  0  1
 0  0      0 2804836 462208 11551168    0    0     0    32 28713 55950   3   7  89  0  1
 0  0      0 2794108 462208 11551208    0    0     0    30 28791 56036   4   7  87  0  1
 0  0      0 2794484 462208 11551172    0    0     0    40 28482 55801   3   6  89  0  1
```

free 与 available 的区别
free 是真正尚未被使用的物理内存数量。
available 是应用程序认为可用内存数量，available = free + buffer + cache (注：只是大概的计算方法)

Linux 为了提升读写性能，会消耗一部分内存资源缓存磁盘数据，对于内核来说，buffer 和 cache 其实都属于已经被使用的内存。但当应用程序申请内存时，如果 free 内存不够，内核就会回收 buffer 和 cache 的内存来满足应用程序的请求。这就是稍后要说明的 buffer 和 cache。

buff 和 cache 的区别

缓冲区

内核缓冲区使用的内存（Buffersin /proc/meminfo）

快取

页面缓存和slab（Cached和 SReclaimable中/proc/meminfo）使用的内存

https://blog.csdn.net/gpcsy/article/details/84951675
