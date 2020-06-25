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

## 提升服务健壮性

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
