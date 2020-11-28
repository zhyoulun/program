## 编写server端程序

```c
#include "unp.h"

void str_echo(int connfd);

int main(int argc, char **argv)
{
    int listenfd, connfd;
    pid_t childpid;
    socklen_t clilen;
    struct sockaddr_in in_cliaddr, servaddr;

    listenfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(SERV_PORT);

    Bind(listenfd, (SA *)&servaddr, sizeof(servaddr));
    Listen(listenfd, LISTENQ);
    for (;;)
    {
        clilen = sizeof(in_cliaddr);
        connfd = Accept(listenfd, (SA *)&in_cliaddr, &clilen);
        if ((childpid = Fork()) == 0)
        {
            Close(listenfd);
            str_echo(connfd);
            exit(0);
        }
        Close(connfd);
    }
}

void str_echo(int connfd)
{
    ssize_t n;
    char buf[MAXLINE];
again:
    while ((n = read(connfd, buf, MAXLINE)) > 0)
    {
        Writen(connfd, buf, n);
    }
    if (n < 0 && errno == EINTR)
    {
        goto again;
    }
    else if (n < 0)
    {
        err_sys("str_echo: read error");
    }
}
```

编译

```bash
gcc -I /dataz/codes/github/network-memo/unp /dataz/codes/github/network-memo/unp/*.c echo-tcp-server/tcp-server.c -o temp/unp_server
```

运行

```
$ telnet 127.0.0.1 12345
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
123
123
qwe
qwe
rty
rty
```


## 编写客户端程序

```c
#include "unp.h"

void str_cli(int connfd);

int main(int argc, char **argv)
{
    int sockfd;
    struct sockaddr_in servaddr;

    if (argc != 2)
    {
        err_quit("usage: tcpcli <IPAddresss>");
    }

    sockfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(SERV_PORT);
    Inet_pton(AF_INET, argv[1], &servaddr.sin_addr);

    Connect(sockfd, (SA *)&servaddr, sizeof(servaddr));
    str_cli(sockfd);
    return 0;
}

void str_cli(int connfd)
{
    char sendline[MAXLINE], recvline[MAXLINE];
    while (Fgets(sendline, MAXLINE, stdin) != NULL)
    {
        Writen(connfd, sendline, strlen(sendline));
        if (Readline(connfd, recvline, MAXLINE) == 0)
        {
            err_quit("str_cli: server terminated permaturely");
        }
        Fputs(recvline, stdout);
    }
}
```

编译

```bash
gcc -I/dataz/codes/github/network-memo/unp /dataz/codes/github/network-memo/unp/*.c /dataz/codes/github/network-memo/echo-tcp-client/tcp-client.c -o temp/unp_client
```

运行

```bash
$ ./temp/unp_client 127.0.0.1
abc
abc
123
123
def
def
```

## 提升服务端健壮性

### 僵尸进程

子进程终止时，给父进程发送了一个SIGCHLD信号。由于我们没有在代码中捕获该信号，而该信号的默认行为就是被忽略，子进程于是进入僵尸进程。

![](/static/images/2006/p022.png)

信号（signal）就是告知某个进程发生了某个事件的通知，有时也称为软件中断（software interrupt）。

信号可以由一个进程发送给另外一个进程（或自身），或者由内核发送给某个进程。

SIGCHLD信号就是由内核在任何一个进程终止时，发送它的父进程的一个信号。

无论何时，我们fork子进程都得wait它们，以防它们变成僵尸进程。为此我们建立一个俘获SIGCHLD信号的信号处理函数，在函数体重我们调用wait。

如果使用wait函数，将阻塞到现有子进程第一个终止为止。

如果使用waitpid函数，第一个参数pid允许我们指定想等待的进程ID，值-1表示等待第一个终止的子进程。options参数允许我们指定附加选项。最常用的选项是WNOHANG，告知内核在没有已终止子进程时不要阻塞。

```c
Signal(SIGCHLD, sig_chld);


void sig_chld(int signo)
{
    pid_t pid;
    int stat;
    while ((pid = waitpid(-1, &stat, WNOHANG)) > 0)
    {
        printf("child %d terminated\n", pid);
    }
}
```

### 使用select改造服务端，不使用子进程

```c
#include "unp.h"

int main(int argc, char **argv)
{
    int listenfd, connfd;
    pid_t childpid;
    socklen_t clilen;
    struct sockaddr_in in_cliaddr, servaddr;

    int maxi, maxfd;
    int n;
    int i;
    int client[FD_SETSIZE];
    int nready;
    fd_set rset, allset;

    char buf[MAXLINE];

    listenfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(SERV_PORT);

    Bind(listenfd, (SA *)&servaddr, sizeof(servaddr));
    Listen(listenfd, LISTENQ);

    maxfd = listenfd;
    maxi = -1;
    for (i = 0; i < FD_SETSIZE; i++)
    {
        client[i] = -1;
    }
    FD_ZERO(&allset);
    FD_SET(listenfd, &allset);

    for (;;)
    {
        rset = allset;
        nready = Select(maxfd + 1, &rset, NULL, NULL, NULL);
        if (FD_ISSET(listenfd, &rset))
        {
            clilen = sizeof(in_cliaddr);
            connfd = Accept(listenfd, (SA *)&in_cliaddr, &clilen);
            for (i = 0; i < FD_SETSIZE; i++)
            {
                if (client[i] == -1)
                {
                    client[i] = connfd;
                    break;
                }
            }
            if (i == FD_SETSIZE)
            {
                err_quit("too many clients");
            }
            FD_SET(connfd, &allset);
            if (connfd > maxfd)
            {
                maxfd = connfd;
            }
            if (i > maxi)
            {
                maxi = i;
            }
            nready--;
            if (nready <= 0)
            {
                continue;
            }
        }

        for (i = 0; i < FD_SETSIZE; i++)
        {
            if ((connfd = client[i]) < 0)
            {
                continue;
            }
            if (FD_ISSET(connfd, &rset))
            {
                if ((n = Read(connfd, buf, MAXLINE)) == 0)
                {
                    Close(connfd);
                    FD_CLR(connfd, &allset);
                    client[i] = -1;
                }
                else
                {
                    Writen(connfd, buf, n);
                }
                nready--;
                if (nready <= 0)
                {
                    break;
                }
            }
        }
    }
}
```

![](/static/images/2006/p032.png)

## 提升客户端健壮性

### 服务器进程异常终止，客户端阻塞在fgets调用上

> 这里需要区分服务器进程崩溃，以及服务器主机崩溃

复现步骤：

1. 在同一个主机上，启动服务端，客户端
2. 在客户端上输入一行文本，验证正常
3. 杀死服务端子进程：作为进程终止处理的部分工作，子进程中所有打开着的描述符都被关闭。这就导致向客户端发送一个FIN，而客户端TCP则相应一个ACK。这是TCP终止连接工作的前半部分
  ![](/static/images/2006/p029.png)
4. 然而这时客户端进程阻塞在fgets调用上，等待从stdin接收一行文本
5. 这时，我们可以在客户端上输入一行文本，str_cli调用writen，客户端TCP接着把数据发送给服务器，TCP允许这么做，因为客户端不知道服务端关闭连接
6. 服务端接收到来自客户端的数据时，响应RST
7. 然而客户端看不到这个RST，因为它在调用writen之后立即调用readline，并且由于客户端接收到了FIN，所以调用readline的时候会立即返回0

使用select解决该问题

```c
void str_cli(FILE *fp, int connfd)
{
    char sendline[MAXLINE], recvline[MAXLINE];
    int maxfdp1 = max(fileno(fp), connfd) + 1;
    fd_set rset;

    FD_ZERO(&rset);
    while (1)
    {
        FD_SET(fileno(fp), &rset);
        FD_SET(connfd, &rset);
        Select(maxfdp1, &rset, NULL, NULL, NULL);

        if (FD_ISSET(connfd, &rset))
        {
            if (Readline(connfd, recvline, MAXLINE) == 0)//socket is readable
            {
                err_quit("str_cli: server terminated permaturely");
            }
            Fputs(recvline, stdout);
        }

        if (FD_ISSET(fileno(fp), &rset))
        {
            if (Fgets(sendline, MAXLINE, fp) == NULL)//input is readable
            {
                write(stdout, "Fgets EOF\n", 10);
                return;
            }
            Writen(connfd, sendline, strlen(sendline));
        }
    }
}
```

### 使用shutdown解决响应不完整问题

![](/static/images/2006/p030.png)

```c
void str_cli(FILE *fp, int connfd)
{
    char buf[MAXLINE];
    int maxfdp1 = max(fileno(fp), connfd) + 1;
    fd_set rset;
    int stdineof = 0;
    int n;

    FD_ZERO(&rset);
    while (1)
    {
        if (stdineof == 0)
            FD_SET(fileno(fp), &rset);
        FD_SET(connfd, &rset);
        Select(maxfdp1, &rset, NULL, NULL, NULL);

        if (FD_ISSET(connfd, &rset))
        {
            if ((n = Read(connfd, buf, MAXLINE)) == 0) //socket is readable
            {
                if (stdineof == 1)
                    return; //normal terminated
                else
                    err_quit("str_cli: server terminated permaturely");
            }
            Writen(fileno(stdout), buf, n);
        }

        if (FD_ISSET(fileno(fp), &rset))
        {
            if ((n = Read(fileno(fp), buf, MAXLINE)) == 0) //input is readable
            {
                stdineof = 1;
                Shutdown(connfd, SHUT_WR); //send FIN
                FD_CLR(fileno(fp), &rset);
                write(stdout, "Fgets EOF\n", 10);
                continue;
            }
            Writen(connfd, buf, n);
        }
    }
}
```

这时就能保证每次都能得到完整的输出

![](/static/images/2006/p031.png)
