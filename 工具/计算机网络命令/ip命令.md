- ifconfig 命令已经被 ip 命令所替代


## 常用方法

### 查看设备的协议(ipv4, ipv6)地址

```bash
ip addr # 显示所有的设备信息
ip addr show # 同上
ip addr show enp0s3 # 显示指定设备信息
ip addr show dev enp0s3 # 同上
```

附：ip addr用法

```
ip addr { show | flush } [ dev STRING ] [ scope SCOPE-ID ] [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ]
```

### 启用/禁用网络设备

```bash
ip link set enp0s3 down # 禁用网络设备
ip link set enp0s3 up # 启用网络设备
```

附：ip link用法

```
ip link set DEVICE { up | down | arp { on | off } |
promisc { on | off } |
allmulticast { on | off } |
dynamic { on | off } |
multicast { on | off } |
txqueuelen PACKETS |
name NEWNAME |
address LLADDR | broadcast LLADDR |
mtu MTU |
netns PID |
alias NAME |
vf NUM [ mac LLADDR ] [ vlan VLANID [ qos VLAN-QOS ] ] [ rate TXRATE ] }
```

实验log

```bash
zyl@mydev:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:45:32:10 brd ff:ff:ff:ff:ff:ff
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:a5:d2:72 brd ff:ff:ff:ff:ff:ff
zyl@mydev:~$ ip link show enp0s3 # 查看指定网卡信息
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:45:32:10 brd ff:ff:ff:ff:ff:ff
zyl@mydev:~$ ping -c 2 www.baidu.com # ping测试
PING www.a.shifen.com (220.181.38.150) 56(84) bytes of data.
64 bytes from 220.181.38.150 (220.181.38.150): icmp_seq=1 ttl=63 time=8.82 ms
64 bytes from 220.181.38.150 (220.181.38.150): icmp_seq=2 ttl=63 time=10.4 ms

--- www.a.shifen.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 8.820/9.639/10.459/0.825 ms
zyl@mydev:~$ sudo ip link set enp0s3 down # 禁用网卡
zyl@mydev:~$ ip link show enp0s3 # 查看网卡状态
2: enp0s3: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether 08:00:27:45:32:10 brd ff:ff:ff:ff:ff:ff
zyl@mydev:~$ ping -c 2 www.baidu.com # ping测试
ping: www.baidu.com: Temporary failure in name resolution
zyl@mydev:~$ sudo ip link set enp0s3 up # 启用网卡
zyl@mydev:~$ ip link show enp0s3 # 查看网卡信息
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:45:32:10 brd ff:ff:ff:ff:ff:ff
zyl@mydev:~$ ping -c 2 www.baidu.com # ping测试
PING www.a.shifen.com (220.181.38.150) 56(84) bytes of data.
64 bytes from 220.181.38.150 (220.181.38.150): icmp_seq=1 ttl=63 time=10.4 ms
64 bytes from 220.181.38.150 (220.181.38.150): icmp_seq=2 ttl=63 time=16.5 ms

--- www.a.shifen.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 10.402/13.472/16.543/3.072 ms
```

## 参考

- [man ip](https://linux.die.net/man/8/ip)
- [12 个 ip 命令范例](https://zhuanlan.zhihu.com/p/32945498)
