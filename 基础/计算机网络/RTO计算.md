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

### linux 4.0-study

`net/ipv4/tcp_input.c`

```c
/* Called to compute a smoothed rtt estimate. The data fed to this
 * routine either comes from timestamps, or from segments that were
 * known _not_ to have been retransmitted [see Karn/Partridge
 * Proceedings SIGCOMM 87]. The algorithm is from the SIGCOMM 88
 * piece by Van Jacobson.
 * NOTE: the next three routines used to be one big routine.
 * To save cycles in the RFC 1323 implementation it was better to break
 * it up into three procedures. -- erics
 */
static void tcp_rtt_estimator(struct sock *sk, long mrtt_us)
{
	struct tcp_sock *tp = tcp_sk(sk);
	long m = mrtt_us; /* RTT */
	u32 srtt = tp->srtt_us;

	/*	The following amusing code comes from Jacobson's
	 *	article in SIGCOMM '88.  Note that rtt and mdev
	 *	are scaled versions of rtt and mean deviation.
	 *	This is designed to be as fast as possible
	 *	m stands for "measurement".
	 *
	 *	On a 1990 paper the rto value is changed to:
	 *	RTO = rtt + 4 * mdev
	 *
	 * Funny. This algorithm seems to be very broken.
	 * These formulae increase RTO, when it should be decreased, increase
	 * too slowly, when it should be increased quickly, decrease too quickly
	 * etc. I guess in BSD RTO takes ONE value, so that it is absolutely
	 * does not matter how to _calculate_ it. Seems, it was trap
	 * that VJ failed to avoid. 8)
	 */
	if (srtt != 0) {
		m -= (srtt >> 3);	/* m is now error in rtt est */
		srtt += m;		/* rtt = 7/8 rtt + 1/8 new */
		if (m < 0) {
			m = -m;		/* m is now abs(error) */
			m -= (tp->mdev_us >> 2);   /* similar update on mdev */
			/* This is similar to one of Eifel findings.
			 * Eifel blocks mdev updates when rtt decreases.
			 * This solution is a bit different: we use finer gain
			 * for mdev in this case (alpha*beta).
			 * Like Eifel it also prevents growth of rto,
			 * but also it limits too fast rto decreases,
			 * happening in pure Eifel.
			 */
			if (m > 0)
				m >>= 3;
		} else {
			m -= (tp->mdev_us >> 2);   /* similar update on mdev */
		}
		tp->mdev_us += m;		/* mdev = 3/4 mdev + 1/4 new */
        //暂时注释掉
		// if (tp->mdev_us > tp->mdev_max_us) {
		// 	tp->mdev_max_us = tp->mdev_us;
		// 	if (tp->mdev_max_us > tp->rttvar_us)
		// 		tp->rttvar_us = tp->mdev_max_us;
		// }
		// if (after(tp->snd_una, tp->rtt_seq)) {
		// 	if (tp->mdev_max_us < tp->rttvar_us)
		// 		tp->rttvar_us -= (tp->rttvar_us - tp->mdev_max_us) >> 2;
		// 	tp->rtt_seq = tp->snd_nxt;
		// 	tp->mdev_max_us = tcp_rto_min_us(sk);
		// }
	} else {
		/* no previous measure. */
		srtt = m << 3;		/* take the measured time to be rtt */
		tp->mdev_us = m << 1;	/* make sure rto = 3*rtt */
        //暂时注释掉
		// tp->rttvar_us = max(tp->mdev_us, tcp_rto_min_us(sk));
		// tp->mdev_max_us = tp->rttvar_us;
		// tp->rtt_seq = tp->snd_nxt;
	}
	tp->srtt_us = max(1U, srtt);
}
```

```c
/* Calculate rto without backoff.  This is the second half of Van Jacobson's
 * routine referred to above.
 */
static void tcp_set_rto(struct sock *sk)
{
	const struct tcp_sock *tp = tcp_sk(sk);
	/* Old crap is replaced with new one. 8)
	 *
	 * More seriously:
	 * 1. If rtt variance happened to be less 50msec, it is hallucination.
	 *    It cannot be less due to utterly erratic ACK generation made
	 *    at least by solaris and freebsd. "Erratic ACKs" has _nothing_
	 *    to do with delayed acks, because at cwnd>2 true delack timeout
	 *    is invisible. Actually, Linux-2.4 also generates erratic
	 *    ACKs in some circumstances.
	 */
	inet_csk(sk)->icsk_rto = __tcp_set_rto(tp);

	/* 2. Fixups made earlier cannot be right.
	 *    If we do not estimate RTO correctly without them,
	 *    all the algo is pure shit and should be replaced
	 *    with correct one. It is exactly, which we pretend to do.
	 */

	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
	 * guarantees that rto is higher.
	 */
	tcp_bound_rto(sk);
}
```

```c
static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
{
	return usecs_to_jiffies((tp->srtt_us >> 3) + tp->rttvar_us);
}
```

```c
static inline void tcp_bound_rto(const struct sock *sk)
{
	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
}
```

## 参考

- [Computing TCP's Retransmission Timer](https://tools.ietf.org/html/rfc6298)
- [RTO的计算方法(基于RFC6298和Linux 3.10)](https://perthcharles.github.io/2015/09/06/wiki-rtt-estimator/)
- [Congestion Avoidance and Control, Jacobson 1988](http://www.cs.binghamton.edu/~nael/cs428-528/deeper/jacobson-congestion.pdf)
- [TRANSMISSION CONTROL PROTOCOL](https://tools.ietf.org/html/rfc793)
