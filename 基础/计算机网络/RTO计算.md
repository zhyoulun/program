## Jacobson 1988

### 理论

RFC793中估算平均RTT算法是如下估算器的最简单的一个例子：recursive prediction error，或者stochastic gradient。

给定一个新的RTT测量$M$，TCP更新平均RTT$A$：

$$
A=(1-g)A+gM
$$

其中$g$是一个增益'gain'($0<g<1$)，改变公式形态：

$$
A=A+g(M-A)
$$

可以认为$A$是下次测量的预测。$M-A$是预测中的误差，这个误差由两部分组成：1. 噪声，记为$E_r$，2. $A$的一次错误选择，记为$E_e$

$$
A=A+gE_r+gE_e
$$

$gE_e$给$A$带来了正向的作用，$gE_r$给$A$带来了随机的作用。$g$代表了一个折中：我们希望$E_e$的$g$足够大，$E_r$的$g$足够小。

一般gain的选择是$0.1~0.2$

显然，$A$的标准偏差（standard deviation）是$g*sdev(M)$，$A$以指数的形式，时间常数是$1/g$，收敛到真实的平均值。所以，$g$越小，$A$越稳定，收敛的速度越慢。

如果我们希望测量$M$的variation，有若干个选择。$\sigma^2$是比较好的选择，因为有比较的数学性质。但是需要计算$(M-A)$的平方，会包含一个乘法，可能会导致整数溢出。mean deviation是更好的选择：

$$
mdev^2=\left ( \sum\left | M-A \right | \right )^2\geq \sum\left | M-A \right |^2=\sigma^2
$$

### 实践

给定测量$M$估算$A$和mean deviation $D$

$$
Err=M-A
$$

$$
A=A+gErr
$$

$$
D=D+g\left ( \left | Err \right | -D \right )
$$

为了更快的计算，上述计算应该是纯整数的，但是$g<1$，可以让$g=1/2^n$，从而可以进行移位计算。

$$
2^nA=2^nA+Err
$$

$$
2^nD=2^nD+\left ( \left | Err \right | -D \right )
$$

为了最小化四舍五入误差，应该记录$A$,$D$的倍数$SA$,$SD$，选择$g=1/8$：

```c
M-=(SA>>3) /* =Err */
SA+=M
if(M<0) M=-M; /* =abs(Err) */
M-=(SD>>3)
SD+=M
```

最终的伪代码：

```c
M-=(SA>>3)
SA+=M
if(M<0) M=-M;
M-=(SD>>2)
SD+=M
rto=((SA>>2)+SD)>>1
```

## 参考

- [Computing TCP's Retransmission Timer](https://tools.ietf.org/html/rfc6298)
- [RTO的计算方法(基于RFC6298和Linux 3.10)](https://perthcharles.github.io/2015/09/06/wiki-rtt-estimator/)
- [Congestion Avoidance and Control, Jacobson 1988](http://www.cs.binghamton.edu/~nael/cs428-528/deeper/jacobson-congestion.pdf)
- [TRANSMISSION CONTROL PROTOCOL](https://tools.ietf.org/html/rfc793)
