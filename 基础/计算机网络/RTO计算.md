## Jacobson 1988

### 理论

RFC793中估算平均RTT算法是如下估算器的最简单的一个例子：recursive prediction error，或者stochastic gradient。

给定一个新的RTT测量$M$，TCP更新平均RTT$A$：

$$
A=(1-g)A+gM
$$


## 参考

- [Computing TCP's Retransmission Timer](https://tools.ietf.org/html/rfc6298)
- [RTO的计算方法(基于RFC6298和Linux 3.10)](https://perthcharles.github.io/2015/09/06/wiki-rtt-estimator/)
- [Congestion Avoidance and Control, Jacobson 1988](http://www.cs.binghamton.edu/~nael/cs428-528/deeper/jacobson-congestion.pdf)
- [TRANSMISSION CONTROL PROTOCOL](https://tools.ietf.org/html/rfc793)
