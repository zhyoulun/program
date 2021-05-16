## 1.4 interfaces

- user or application processes
- TCP
- 低层协议：internet protocol

## 1.5 operation

TCP的主要目的是为两个进程提供可靠的、安全的逻辑线路，或者链接服务。为了在一个不太可靠的internet communication system上提供这个服务，需要具备如下相关能力：

- Basic Data Transfer
- Reliability
- Flow Control
- Multiplexing：多路复用
- Connections
- Precedence and Security：优先级和安全

### Basic Data Transfer

> 暂时没有要记录的

### Reliability

TCP需要解决如下问题：损坏、丢失、重复、乱序

解决方法：

- 为每一个八位字节设置一个序列号
- 需要接收方发送一个ack
- 如果在timeout interval内没有收到ack，需要重新发送数据
- 序列号用于矫正顺序，以及删除重复数据
- 损坏是靠为每一个segment增加一个校验和解决

### Flow Control

TCP为接收方提供了一个工具，用于管理发送者发送数据的数量。每一个ack，都会带有一个“window”信息，表示a range of acceptable sequence numbers beyond the last segment successfully received。The window indicates an allowed number of octets that the sender may transmit before receiving further permission.

### Multiplexing：多路复用

> 暂时没有要记录的

### Connections

> 暂时没有要记录的

### Precedence and Security：优先级和安全

> 暂时没有要记录的

## 3.7 数据通信

The sender of data keeps track of the next sequence number to use in the variable SND.NXT.

The receiver of data keeps track of the next sequence number to expect in the variable RCV.NXT.

The sender of data keeps track of the oldest unacknowledged sequence number in the variable SND.UNA.

If the data flow is momentarily idle and all data sent has been acknowledged then the three variables will be equal.

### Retransmission Timeout(RTO)

因为网络的多变性，RTO必须要动态决定。

测量一次RTT，根据RTT计算SRTT(Smoothed Round Trip Time)

```
SRTT = ( ALPHA * SRTT ) + ((1-ALPHA) * RTT)
```

在此基础上，计算RTO：

```
RTO = min[UBOUND,max[LBOUND,(BETA*SRTT)]]
```

ALPHA是平滑系数，BETA是delay variance系数

## 参考

- [TRANSMISSION CONTROL PROTOCOL](https://tools.ietf.org/html/rfc793)
