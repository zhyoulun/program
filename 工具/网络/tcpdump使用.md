## 常用命令

tcpdump需要root权限

```
tcpdump -i eth0 -nn -s0 -v
```

> -i：指定监听的interface。如果没有设置，会选择序号最低的一个（排除掉loopback）
> -nn：如果用一个n，就不会解析hostname，如果用两个n，就不会解析hostname和port
> -s0：设置snap长度，设置为0就表示没有限制。当你希望抓取binaries/files时有用
> -v：使用-v或者-vv来增加输出信息的详情

等价于

```
tcpdump -i eth0 -n -v
```

增加过滤条件

```
tcpdump -i eth0 -n -v port 22 and host 192.168.0.111
```

```
nohup tcpdump -i eth0 tcp port 1935 -W 40 -C 250 -w tcpdump_logfile 2>&1 > /dev/null &
```

- `-W`: 保存文件个数
- `-C`: 单个文件大小，单位是1^6Bytes

保存下来的文件可以在wireshark中分析

## case分析

### case. http访问nginx，nginx proxy_pass到后端

这里抓的nginx->go server的请求与response包，且TCP连接存在一段idle时间，超时时间是120秒。

命令：`tcpdump -i eth0 -nn -s0 -v host 192.168.11.101`

```
14:16:54.371300 IP (tos 0x0, ttl 64, id 50478, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [S], cksum 0x9848 (incorrect -> 0x2c0a), seq 1438562090, win 64240, options [mss 1460,sackOK,TS val 2276984863 ecr 0,nop,wscale 7], length 0
```

**IP协议部分**
- 192.168.11.100：source address
- 192.168.11.101：destination address
- tos 0x0：type of service，8位的服务类型。该字段包括一个3bit的优先权子字段（现在已被忽略），4bit的TOS子字段，和1bit未用位但必须置为0。4bit的TOS分别代表：最小时延、最大吞吐量、最高可靠性和最小费用。4bit中只能置其中1bit。如果所有4bit均为0，那么就意味着是一般服务。RFC1340描述了所有的标准应用如何设置这些服务类型，RFC1349对该RFC进行了修正，更为详细的描述了TOS的特性。
- ttl 64：time to live，生存时间字段设置了数据包可以经过的最多路由器数。它指定了数据报的生存时间。TTL的初始值由源主机设置（通常为32或64），一旦经过一个处理它的路由器，它的值就减去1。当该字段的值为0时，数据报就被丢弃，并发送ICMP报文通知源主机。
- id 50478：16位，标识字段唯一地标识主机发送的每一份数据报。通常每发送一份报文，它的值就会加1。
- id 50478, offset 0：16位标识，13位片偏移，用于分片和重组。
- flags [DF]：various control flags。
    - Bit 0：保留位，必须为0；
    - Bit 1：（DF）0 = May Fragment,  1 = Don't Fragment；
    - Bit 2： (MF) 0 = Last Fragment, 1 = More Fragments.
- proto TCP (6)：协议值，标识data部分所包含的协议类型，TCP是6
- length 60：总长度，指整个IP数据报的长度，单位是字节。

**TCP协议部分**

- 52378：source port
- 8080：Destination Port
- Flags [S]：TCP首部中的6个标志bit，它们中的多个可以同时设置为1，列表如下：

![](/static/images/2006/p021.png)

- cksum 0x9848 (incorrect -> 0x2c0a)：16位检验和。检验和覆盖了整个TCP报文段：TCP首部和TCP数据。这是一个强制性的字段，一定是由发端计算和存储，并由收端进行验证。
    - 抓包结果不准确，原因参考[cksum incorrect](https://huataihuang.gitbooks.io/cloud-atlas/network/packet_analysis/tcpdump/udp_tcp_checksum_errors_from_tcpdump_nic_hardware_offloading.html)
- seq 1438562090：32位序号
- win 64240：16位窗口大小
- options [mss 1460,sackOK,TS val 2276984863 ecr 0,nop,wscale 7]：选项
    - mss 1460：最长报文大小，maximum segment size
    - sackOK：
    - TS val 2276984863 ecr 0
    - nop
    - wscale 7
- length 0

```
14:16:54.371371 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [S.], cksum 0x9848 (incorrect -> 0xdf0c), seq 664776849, ack 1438562091, win 65160, options [mss 1460,sackOK,TS val 2170875838 ecr 2276984863,nop,wscale 7], length 0
```

- Flags [S.]：S代表SYN，.代表ACK
- ack 1438562091：确认序号

```    
14:16:54.371384 IP (tos 0x0, ttl 64, id 50479, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x0a6c), ack 1, win 502, options [nop,nop,TS val 2276984863 ecr 2170875838], length 0
```

- Flags [.]：.代表ACK

以上代表3次握手成功，建连成功


```
14:16:54.371416 IP (tos 0x0, ttl 64, id 50480, offset 0, flags [DF], proto TCP (6), length 277)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [P.], cksum 0x9921 (incorrect -> 0xd2af), seq 1:226, ack 1, win 502, options [nop,nop,TS val 2276984863 ecr 2170875838], length 225: HTTP, length: 225
	GET /go_keepalive/abcd HTTP/1.1
	Host: go_servers_keepalive
	User-Agent: PostmanRuntime/7.23.0
	Accept: */*
	Cache-Control: no-cache
	Postman-Token: 9edfc484-8a6b-4818-ba4c-26a1b1aee046
	Accept-Encoding: gzip, deflate, br
```

nginx向go server发送request

- Flags [P.]：P代表PSH，.代表ACK
- length：225，代表数据的长度

```
14:16:54.371425 IP (tos 0x0, ttl 64, id 34988, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0x0985), ack 226, win 508, options [nop,nop,TS val 2170875838 ecr 2276984863], length 0
```

nginx接收到go server的ack

```
14:16:54.371731 IP (tos 0x0, ttl 64, id 34989, offset 0, flags [DF], proto TCP (6), length 465)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [P.], cksum 0x99dd (incorrect -> 0x8fd0), seq 1:414, ack 226, win 508, options [nop,nop,TS val 2170875839 ecr 2276984863], length 413: HTTP, length: 413
	HTTP/1.1 200 OK
	Content-Type: application/json
	Date: Sun, 22 Mar 2020 14:16:54 GMT
	Content-Length: 304

	{"Host":"go_servers_keepalive","ServerIP":"192.168.11.101","ServerPort":8080,"RequestURI":"/go_keepalive/abcd","Header":{"Accept":["*/*"],"Accept-Encoding":["gzip, deflate, br"],"Cache-Control":["no-cache"],"Postman-Token":["9edfc484-8a6b-4818-ba4c-26a1b1aee046"],"User-Agent":["PostmanRuntime/7.23.0"]}}[!http]
```

nginx接收到go server的response



```
14:16:54.371748 IP (tos 0x0, ttl 64, id 50481, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x07ed), ack 414, win 501, options [nop,nop,TS val 2276984864 ecr 2170875839], length 0
```

nginx向go server发送ack


```
14:16:59.398706 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.101 tell 192.168.11.100, length 28
14:16:59.398809 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.100 tell 192.168.11.101, length 28
14:16:59.398821 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.100 is-at 02:42:c0:a8:0b:64, length 28
14:16:59.398828 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.101 is-at 02:42:c0:a8:0b:65, length 28
```

ARP询问


```
14:17:09.383176 IP (tos 0x0, ttl 64, id 34990, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0xcd43), ack 226, win 508, options [nop,nop,TS val 2170890850 ecr 2276984864], length 0
```

nginx接收到go server的ack

```
14:17:09.383202 IP (tos 0x0, ttl 64, id 50482, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0xcd49), ack 414, win 501, options [nop,nop,TS val 2276999875 ecr 2170875839], length 0
```

nginx向go server发送ack

```
14:17:24.487052 IP (tos 0x0, ttl 64, id 34991, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0x57a0), ack 226, win 508, options [nop,nop,TS val 2170905954 ecr 2276999875], length 0
14:17:24.487077 IP (tos 0x0, ttl 64, id 50483, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x9249), ack 414, win 501, options [nop,nop,TS val 2277014979 ecr 2170875839], length 0
14:17:39.591028 IP (tos 0x0, ttl 64, id 34992, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0xe19f), ack 226, win 508, options [nop,nop,TS val 2170921058 ecr 2277014979], length 0
14:17:39.591053 IP (tos 0x0, ttl 64, id 50484, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x5749), ack 414, win 501, options [nop,nop,TS val 2277030083 ecr 2170875839], length 0
14:17:44.710653 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.101 tell 192.168.11.100, length 28
14:17:44.710729 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.101 is-at 02:42:c0:a8:0b:65, length 28
14:17:54.695044 IP (tos 0x0, ttl 64, id 34993, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0x6b9f), ack 226, win 508, options [nop,nop,TS val 2170936162 ecr 2277030083], length 0
14:17:54.695069 IP (tos 0x0, ttl 64, id 50485, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x1c49), ack 414, win 501, options [nop,nop,TS val 2277045187 ecr 2170875839], length 0
14:17:59.815019 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.100 tell 192.168.11.101, length 28
14:17:59.815033 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.100 is-at 02:42:c0:a8:0b:64, length 28
14:18:09.798561 IP (tos 0x0, ttl 64, id 34994, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0xf59e), ack 226, win 508, options [nop,nop,TS val 2170951266 ecr 2277045187], length 0
14:18:09.798575 IP (tos 0x0, ttl 64, id 50486, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0xe148), ack 414, win 501, options [nop,nop,TS val 2277060291 ecr 2170875839], length 0
14:18:24.903035 IP (tos 0x0, ttl 64, id 34995, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0x7f9e), ack 226, win 508, options [nop,nop,TS val 2170966370 ecr 2277060291], length 0
14:18:24.903059 IP (tos 0x0, ttl 64, id 50487, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0xa648), ack 414, win 501, options [nop,nop,TS val 2277075395 ecr 2170875839], length 0
14:18:30.022986 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.101 tell 192.168.11.100, length 28
14:18:30.023055 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.101 is-at 02:42:c0:a8:0b:65, length 28
14:18:40.006655 IP (tos 0x0, ttl 64, id 34996, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [.], cksum 0x9840 (incorrect -> 0x099e), ack 226, win 508, options [nop,nop,TS val 2170981474 ecr 2277075395], length 0
14:18:40.006673 IP (tos 0x0, ttl 64, id 50488, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x6b48), ack 414, win 501, options [nop,nop,TS val 2277090499 ecr 2170875839], length 0
14:18:45.130735 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 192.168.11.100 tell 192.168.11.101, length 28
14:18:45.130747 ARP, Ethernet (len 6), IPv4 (len 4), Reply 192.168.11.100 is-at 02:42:c0:a8:0b:64, length 28
```


```
14:18:54.382429 IP (tos 0x0, ttl 64, id 50489, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [F.], cksum 0x9840 (incorrect -> 0x3320), seq 226, ack 414, win 501, options [nop,nop,TS val 2277104874 ecr 2170875839], length 0
```

nginx主动断开连接

- Flags [F.]：F代表FIN，.代表ACK

```
14:18:54.382586 IP (tos 0x0, ttl 64, id 34997, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.101.8080 > 192.168.11.100.52378: Flags [F.], cksum 0x9840 (incorrect -> 0x5e4b), seq 414, ack 227, win 508, options [nop,nop,TS val 2170995850 ecr 2277104874], length 0
```

go server主动断开连接

- Flags [F.]：F代表FIN，.代表ACK

```
14:18:54.382605 IP (tos 0x0, ttl 64, id 50490, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.11.100.52378 > 192.168.11.101.8080: Flags [.], cksum 0x9840 (incorrect -> 0x5e51), ack 415, win 501, options [nop,nop,TS val 2277104875 ecr 2170995850], length 0
```


## 参考

- [IP rfc](https://tools.ietf.org/html/rfc791)
- [TCP rfc](https://tools.ietf.org/html/rfc793)
- TCP/IP协议
- [ASSIGNED NUMBERS](https://tools.ietf.org/html/rfc790)
- [cksum incorrect](https://huataihuang.gitbooks.io/cloud-atlas/network/packet_analysis/tcpdump/udp_tcp_checksum_errors_from_tcpdump_nic_hardware_offloading.html)

**IP与TCP关系**

![](/static/images/2006/p018.png)

**IP header Protocol**

![](/static/images/2006/p019.png)

![](/static/images/2006/p020.png)
