Unix下可用的5种I/O模型的基本区别：

- 阻塞式I/O
- 非阻塞式I/O
- I/O复用（select和poll）
- 信号驱动式I/O（SIGIO）
- 异步I/O（POSIX的aio_系列函数）

一个输入操作通常包含两个不同的阶段：

1. 等待数据准备好
2. 从内核向进程复制数据

对于一个套接字上的输入操作，第一步通常涉及等待数据从网络中到达。当所等待分组到达时，它被复制到内核中的某个缓冲区，第二步就是把数据从内核缓冲区复制到应用进程缓冲区。

## 阻塞式I/O模型

![](/static/images/2006/p023.png)


## 非阻塞式I/O

![](/static/images/2006/p024.png)

当一个应用进程像这样对一个非阻塞描述符循环调用recvfrom时，我们称之为轮询（polling）。

应用程序持续轮询内核，以查看某个操作是否就绪。

这么做往往耗费大量CPU时间，不过这种模型偶尔也会用到，通常是在专门提供某一种功能的系统中才有。

## I/O复用（select和poll）

![](/static/images/2006/p025.png)

当用户进程调用了select，那么整个进程会被block；kernel会“监视”所有select负责的socket，当任何一个socket中的数据准备好了，select就会返回。这个时候用户进程再调用read操作，将数据从kernel拷贝到用户进程。

在我理解，多路复用就是可以在一个线程中监测多个套接字，比如select，poll，epoll，当这些套接字（文件描述符）中的任意一个进入有数据到来，以上三个函数就会返回，之后进入数据处理状态。

这个图和blocking IO的图其实并没有太大的不同，事实上，还更差一些。因为这里需要使用两个system call (select 和 recvfrom)，而blocking IO只调用了一个system call (recvfrom)。但是，用select的优势在于它可以同时处理多个connection。所以，如果处理的连接数不是很高的话，使用select/epoll的web server不一定比使用multi-threading + blocking IO的web server性能更好，可能延迟还更大。select/epoll的优势并不是对于单个连接能处理得更快，而是在于能处理更多的连接。

实际中，对于每一个socket，一般都设置成为non-blocking，但是，如上图所示，整个用户的process其实是一直被block的。只不过process是被select这个函数block，而不是被socket IO给block。

## 信号驱动式I/O（SIGIO）

![](/static/images/2006/p026.png)

## 异步I/O（POSIX的aio_系列函数）

![](/static/images/2006/p027.png)

异步I/O由POSIX规范定义。演变成当前POSIX规范的各种早期标准所定义的实时函数中存在的差异已经取得一致。???

一般的，这种函数的工作机制是：告知内核启动某个操作，并在内核在整个操作（包括将数据从内核复制到我们自己的缓冲区）完成后通知我们。

这种模型和信号驱动模型的主要区别是：后者是由内核通知我们何时可以启动一个I/O操作，而前者是由内核通知我们I/O操作何时完成。

## 各种I/O模型的比较

![](/static/images/2006/p028.png)

## 参考

- [linux select函数解析以及事例](https://zhuanlan.zhihu.com/p/57518857)
- [Linux IO模式及 select、poll、epoll详解](https://segmentfault.com/a/1190000003063859)