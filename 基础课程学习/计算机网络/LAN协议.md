## LAN的网络设备

- 中继器：是一种物理设备，用于连接扩展网络的介质部分。该设备从一个网络端上接收信号，将其放大、重新定时后传送到另一个网段上，防止电缆过长和连接设备过多而造成的信号丢失或者衰减
- 网桥：该设备用于OSI参考模型第二层，属于数据链路层设备。在传递信息时，他们首先分析接收到的数据帧，并根据数据帧中包含的信息作出转发决定，然后将数据帧转发到目的地的结点
- 交换机：该设备从本质上说，是一个快速网桥
  - 由于交换机是由硬件进行交换，速度很快。而网桥是由软件进行交换，且能互联
  - 交换机支持的端口密度比网桥高
  - 由于交换机支持断-通交换，因此网络潜伏和延迟时间短，而网桥只支持存储-转发的数据包交换
  - 交换机为每个网络段提供专用的带宽，减少了网段的冲突
- 路由器
  - 作用于OSI模型的网络层。路由器利用了一种中继到中继的技术。与目的地之间没有直接物理连接的路由器会检查它的路由表，向前转发数据包到更接近目的地的下一个中继的路由器。这个过程重复进行，知道数据包通过网络找到它的路并到达最终目的地。

## 参考

- 局域网交换机和路由器配置与管理，李建林