## TASK and CPU states

示例：

![](/static/images/2006/p002.png)

这部分至少包含两行内容。在SMP环境中，会有额外的行来展示每个CPU state percentages。

第一行展示了所有的tasks或者threads。由开关treads-mode控制，可以使用快捷键H来切换。total会进一步拆分为running, sleeping, stopped, zombie。

第二行展示了，从上次刷新之后开始的间隔内，CPU state percentages。

展示形式1如上截图所示，其中的字段解释如下：

- `us`, user    : time running un-niced user processes
  - un-niced用户进程
- `sy`, system  : time running kernel processes
  - 内核进程
- `ni`, nice    : time running niced user processes
  - niced用户进程
- `id`, idle    : time spent in the kernel idle handler
  - 内核idle handler
- `wa`, IO-wait : time waiting for I/O completion
  - 等待I/O完成
- `hi` : time spent servicing hardware interrupts
  - 硬中断
- `si` : time spent servicing software interrupts
  - 软中断
- `st` : time stolen from this vm by the hypervisor
  - 代表real CPU对当前虚拟机（virtual machine）不可用——它被hypervisor偷走了。

展示形式2，可以使用快捷键t切换，示例如下：

![](/static/images/2006/p003.png)

```
           a    b     c    d
%Cpu(s):  75.0/25.0  100[ ...
```

其中字段解释如下：

- a) is the combined `us` and `ni` percentage; 
  - us+ni
- b) is the `sy` percentage; 
  - sy
- c) is the total;
  - a和b的和
- d) is one of two visual graphs of those representations.
  - 图形化展示

### `us` vs `ni`

us和ni分别代表un-niced user processes和niced user processes的运行时间。

那什么是un-niced和niced？

"niced" process是这样的：用nice命令启动的，或者进程的nice value值被renice修改的；否则称为un-niced。

常规进程的default nice value是0，即un-niced状态进程的nice值是0。

nice值可以在top命令中查看：

![](/static/images/2006/p004.png)

其中NI代表nice value：nice value为负值时，表示进程有较高的优先级；正值代表进程有较低的优先级；0代表在决定一个进程的调度能力时，不会修改优先级。

PR代表进程的调度优先级。

## MEMORY Usage

示例：

![](/static/images/2006/p005.png)

可以使用快捷键E调整单位，范围是（KiB->EiB）。

默认情况下，第1行显示了物理内存，分类是：total, free, used, buff/cache

第2行显示了大部分虚拟内存，分类是：total, free, used. avail(这里指可用的物理内存)

第二行的`avail`数值是可用物理内存的估计值，它可用于启动一个新的应用，不包含swapping。和`free`不一样的是，it attempts to account for readily reclaimable page cache and memory slabs。

快捷键m可以切换到另外一种展示形式：

            a    b          c
GiB Mem : 18.7/15.738   [ ...
GiB Swap:  0.0/7.999    [ ...

- a) is the percentage used; 
  - 使用量(total-avail)
- b) is the total available;
  - 总的可用量
- c) is one of two visual graphs of those representations.
  - 图形化展示




 
## 参考

- [https://www.man7.org/linux/man-pages/man1/top.1.html](https://www.man7.org/linux/man-pages/man1/top.1.html)
- [Scheduling in Linux](https://www.cs.montana.edu/~chandrima.sarkar/AdvancedOS/CSCI560_Proj_main/index.html)
- [https://www.man7.org/linux/man-pages/man1/renice.1.html](https://www.man7.org/linux/man-pages/man1/renice.1.html)
- [What exactly is meant by a “niced” and an “un-niced” user process?](https://askubuntu.com/questions/812144/what-exactly-is-meant-by-a-niced-and-an-un-niced-user-process)
  - 里边说的部分内容和man top手册有出入
- [https://man7.org/linux/man-pages/man7/sched.7.html](https://man7.org/linux/man-pages/man7/sched.7.html)
- [Linux “top” command: What are us, sy, ni, id, wa, hi, si and st (for CPU usage)?](https://unix.stackexchange.com/questions/18918/linux-top-command-what-are-us-sy-ni-id-wa-hi-si-and-st-for-cpu-usage)


