早在上个世纪七十年代，多核处理器还是一个科研主题，并没有进入普通程序员的视野。 Tony Hoare 于 1977 年提出通信顺序进程（CSP）理论，遥遥领先与他所在的时代。

CSP 的模型由并发执行的实体（线程或者进程）所组成，实体之间通过发送消息进行通信， 这里发送消息时使用的就是通道（channel）。也就是我们常说的 『 Don't communicate by sharing memory; share memory by communicating 』。

多核处理器编程通常与操作系统研究、中断处理、I/O 系统、消息传递息息相关

当时涌现了很多不同的想法：

- 信号量 semaphore [Dijkstra, 1965]
- 监控 monitors [Hoare, 1974]
- 锁与互斥 locks/mutexes
- 消息传递

研究证明了消息传递与如今的线程与锁是等价的 [Lauer and Needham 1979]。

进程代数算符描述看不懂。。 暂且不看

## 参考

- [1.3 顺序进程通讯](https://golang.design/under-the-hood/zh-cn/part1basic/ch01basic/csp/)
- [wikipedia 通信顺序进程](https://zh.wikipedia.org/wiki/%E4%BA%A4%E8%AB%87%E5%BE%AA%E5%BA%8F%E7%A8%8B%E5%BC%8F)