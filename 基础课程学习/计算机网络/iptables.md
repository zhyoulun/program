## 基础

iptables用于设置、维护、查看linux kernel中的ip packet filter规则。

定义了几个不同的表，每个表包含几个内置的chains，也可能包含用户定义的chains。

每个chain是一系列的规则，这些规则可以匹配一些packets。每个规则会指定如何处理匹配上的packet。如何做被叫做target，它可能会跳转到同一个表中一个用户定义的chain。

## 用法

查看和删除规则

```
# 查看
iptables -L [chain]
# 删除
iptables -D chain rule-specification
iptables -D chain rulenum
```

## 丢包

```
iptables -I INPUT -s x.x.x.x -m statistic --mode random --probability 0.2 -j DROP
```

statistic模块解释：

statistic
This module matches packets based on some statistic condition. It supports two distinct modes settable with the --mode option.
Supported options:

- --mode mode
  - Set the matching mode of the matching rule, supported modes are random and nth.
- --probability p
  - Set the probability for a packet to be randomly matched. It only works with the random mode. p must be within 0.0 and 1.0. The supported granularity is in 1/2147483648th increments.
- --every n
  - Match one packet every nth packet. It works only with the nth mode (see also the --packet option).
- --packet p
  - Set the initial counter value (0 <= p <= n-1, default 0) for the nth mode.


## 参考

- [man iptables](https://linux.die.net/man/8/iptables)
- [iptables extensions](http://ipset.netfilter.org/iptables-extensions.man.html)