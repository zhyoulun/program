### 基本流程

![](/static/images/2101/p007.png)

![](/static/images/2101/p006.png)

1. 服务器必须准备好接受外来的连接。这通常通过调用socket、bind、listen这3个函数来完成，我们称之为被动打开。
2. 客户通过调用connect发起主动打开，这导致客户TCP发送一个SYN分节，它告诉服务器客户将在（待建立的）连接中发送的数据的初始序列号。通常SYN分节不携带数据，其所在IP数据报只含有一个IP首部、一个TCP首部及可能有的TCP选项
3. 服务器必须确认（ACK）客户的SYN，同时自己也得发送一个SYN分节，它含有服务器将在同一连接中发送的数据的初始序列号。服务器在单个分节中发送SYN和对客户SYN的ACK
4. 客户必须确认服务器的SYN


1. 某个应用进程首先调用close，我们称该端执行主动关闭。该端的TCP于是发送一个FIN分节，表示数据发送完毕。
2. 接收到这个FIN的对端执行被动关闭。这个FIN由TCP确认。它的接收也作为一个文件结束符（end-of-file）传递给接收端应用进程（放在已排队等待该应用进程接收的任何其他数据之后），因为FIN的接收意味着接收端应用进程在相应连接上再无额外数据可以接收
3. 一段时间后，接收到这个文件结束符的应用进程将调用close关闭它的套接字。这导致它的TCP也发送一个FIN
4. 接收这个最终FIN的原发送端TCP确认这个FIN。


需要认识到，但一个unix进程无论自愿的还是非自愿的终止时，所有打开的描述符都被关闭，这也导致仍然打开的任何TCP连接上也发送一个FIN。

### 发送阻塞的地方

- connect
- accpet
- read
- write

### connect设置超时时间

参考代码：https://github.com/zhyoulun/network-memo/blob/master/doc/unp-master/lib/connect_nonb.c

```c
int
connect_nonb(int sockfd, const SA *saptr, socklen_t salen, int nsec)
{
	int				flags, n, error;
	socklen_t		len;
	fd_set			rset, wset;
	struct timeval	tval;

	flags = Fcntl(sockfd, F_GETFL, 0);
	Fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

	error = 0;
	if ( (n = connect(sockfd, saptr, salen)) < 0)
		if (errno != EINPROGRESS)
			return(-1);

	/* Do whatever we want while the connect is taking place. */

	if (n == 0)
		goto done;	/* connect completed immediately */

	FD_ZERO(&rset);
	FD_SET(sockfd, &rset);
	wset = rset;
	tval.tv_sec = nsec;
	tval.tv_usec = 0;

	if ( (n = Select(sockfd+1, &rset, &wset, NULL,
					 nsec ? &tval : NULL)) == 0) {
		close(sockfd);		/* timeout */
		errno = ETIMEDOUT;
		return(-1);
	}

	if (FD_ISSET(sockfd, &rset) || FD_ISSET(sockfd, &wset)) {
		len = sizeof(error);
		if (getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
			return(-1);			/* Solaris pending error */
	} else
		err_quit("select error: sockfd not set");

done:
	Fcntl(sockfd, F_SETFL, flags);	/* restore file status flags */

	if (error) {
		close(sockfd);		/* just in case */
		errno = error;
		return(-1);
	}
	return(0);
}
```
