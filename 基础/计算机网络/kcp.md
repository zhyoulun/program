## 流程

协程1：

- ListenWithOptions
- serveConn
- go l.monitor()

- struct Listener
    - monitor()
    - defaultMonitor() -- main cycle
    - packetInput()
    - var sessions map[string]*UDPSession, session.kcpInput()
        - var kcp *KCP, session.kcp.Input()
        - 将数据存放到kcp的rcv_queue中

协程2：

- go handleEcho(session)
- session.Read()
- session.kcp.Recv()
- 从kcp的rcv_queue中读取数据

接受数据流：

- Listener.conn.ReadFrom，将数据存放到mtuLimit的buf中
- Listener.packetInput处理这个buf
- 在Listener.sessions中根据remote addr找到UDPSession，没有则创建一个
- UDPSession.kcpInput处理这个buf
- UDPSession.KCP.Input处理这个buf
- 如果判断是一个对端发送过来的数据包，将buf格式为seg，并将buf中剩余的数据段存放到seg.data上
- UDPSession.KCP.parse_data处理seg
- 将seg.data中的数据复制到xmitBuf上，并复制给seg.data
- 将seg append到kcp.rev_buf上
- 如果rev_buf上的sn连续，并与rcv_next相等，则将前边若干个连续的seg存放到rev_queue中，并从rev_buf中移除

## kcp ARQ结构

kcp header大小：24B

- conv, 4B
- cmd, 1B
  - IKCP_CMD_PUSH=81, cmd: push data
  - IKCP_CMD_ACK=82, cmd: ack
  - IKCP_CMD_WASK=83, cmd: window probe (ask)
  - IKCP_CMD_WINS=84, cmd: window size (tell)
- frg, 1B
- wnd, 2B
- ts, 4B
- sn, 4B
- una, 4B
- length, 4B
- data, 长度为length的值

## 参考

- [https://github.com/zhyoulun/kcp-go](https://github.com/zhyoulun/kcp-go)
- [https://github.com/zhyoulun/kcp](https://github.com/zhyoulun/kcp)
- [可靠UDP，KCP协议快在哪？](https://zhuanlan.zhihu.com/p/159045587)