## 编写客户端与daytime交互

### 程序

```c
#include "unp.h"

int main(int argc, char **argv){
    int sockfd, n;
    char recvline[MAXLINE+1];
    struct sockaddr_in servaddr;

    if(argc!=2){
        err_quit("usage: a.out <IPAddress>");
    }

    if((sockfd = socket(AF_INET, SOCK_STREAM, 0))<0){
        err_sys("socket error");
    }

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(13);
    if(inet_pton(AF_INET, argv[1], &servaddr.sin_addr)<=0){
        err_quit("inet_pton err for %s", argv[1]);
    }

    if(connect(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr))<0){
        err_sys("connect error");
    }
    while((n=read(sockfd, recvline, MAXLINE))>0){
        recvline[n] = 0;
        if(fputs(recvline, stdout)==EOF){
            err_sys("fputs error");
        }
    }
    if(n<0){
        err_sys("read error");
    }

    return 0;
}
```

编译运行

```bash
 $ gcc -I/dataz/codes/github/network-memo/unp /dataz/codes/github/network-memo/unp/*.c daytime-tcp-client/tcp_client.c -o temp/client

$ ./a.out 127.0.0.1
Sat Jun 13 22:56:36 2020
```

### 打开daytime服务

安装 openbsd-inetd

```bash
sudo apt-get install openbsd-inetd
```

编辑`/etc/inetd.conf`，取消daytime注释

```
daytime		stream	tcp	nowait	root	internal
```

启动服务

```bash
sudo /etc/init.d/openbsd-inetd start
```

检查13端口是否有在被监听

## 编写自己的daytime服务

### 代码

```c
#include "unp.h"

int main(int argc, char **argv){
    int listenfd, connfd;
    struct sockaddr_in servaddr;
    char buff[MAXLINE];
    time_t ticks;

    listenfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(13);

    Bind(listenfd, (SA *) &servaddr, sizeof(servaddr));
    Listen(listenfd, LISTENQ);

    for(;;){
        connfd = Accept(listenfd, (SA *)NULL, NULL);
        ticks = time(NULL);
        snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
        Write(connfd, buff, strlen(buff));
        Close(connfd);
    }

    return 0;
}
```

运行

服务端

```bash
$ gcc -I/dataz/codes/github/network-memo/unp /dataz/codes/github/network-memo/unp/*.c daytime-tcp-server/tcp_server.c -o temp/server

$ sudo ./temp/server
```


客户端

```bash
$ ./temp/client 127.0.0.1
Sat Jun 13 23:29:44 2020
```

## 获取客户端IP port

```c
for(;;){
      len = sizeof(cliaddr);
      connfd = Accept(listenfd, (SA *)&cliaddr, &len);
      printf("connection from %s:%d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, buff, sizeof(buff)), ntohs(cliaddr.sin_port));
      ticks = time(NULL);
      snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
      Write(connfd, buff, strlen(buff));
      Close(connfd);
  }
```

运行

服务端

```bash
$ sudo ./temp/server
connection from 127.0.0.1:58038
connection from 127.0.0.1:58052
```

客服端

```bash
$ ./temp/client 127.0.0.1
Sun Jun 14 10:28:52 2020
$ ./temp/client 127.0.0.1
Sun Jun 14 10:28:54 2020
```

## 使用子进程处理客户端请求

```c
#include "unp.h"

void doit(int connfd);

int main(int argc, char **argv){
    int listenfd, connfd;
    int len;
    struct sockaddr_in servaddr, cliaddr;
    char buff[MAXLINE];
    size_t pid;

    listenfd = Socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servaddr.sin_port = htons(12345);

    Bind(listenfd, (SA *) &servaddr, sizeof(servaddr));
    Listen(listenfd, LISTENQ);

    for(;;){
        len = sizeof(cliaddr);
        connfd = Accept(listenfd, (SA *)&cliaddr, &len);
        printf("connection from %s:%d\n", inet_ntop(AF_INET, &cliaddr.sin_addr, buff, sizeof(buff)), ntohs(cliaddr.sin_port));

        if((pid=Fork())==0){//子进程
            Close(listenfd);
            doit(connfd);
            Close(connfd);
            exit(0);
        }

        Close(connfd);
    }

    return 0;
}

void doit(int connfd){
    time_t ticks;
    char buff[MAXLINE];

    ticks = time(NULL);
    snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
    Write(connfd, buff, strlen(buff));
}
```

运行

服务端

```bash
$ ./temp/server
connection from 127.0.0.1:52142
connection from 127.0.0.1:52148
connection from 127.0.0.1:52150
```

客户端

```bash
$ ./temp/client 127.0.0.1
Sun Jun 14 10:45:27 2020
$ ./temp/client 127.0.0.1
Sun Jun 14 10:45:29 2020
$ ./temp/client 127.0.0.1
Sun Jun 14 10:45:31 2020
```

## 参考

- [linux 打开标准的 echo、discard 等 TCP 服务](https://sanyuesha.com/2018/02/28/open-linux-standard-tcp-service/)
