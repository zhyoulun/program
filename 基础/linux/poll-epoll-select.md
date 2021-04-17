select，poll，epoll都是IO多路复用的机制。I/O多路复用就是通过一种机制，一个进程可以监视多个描述符，一旦某个描述符就绪（一般是读就绪或者写就绪），能够通知程序进行相应的读写操作。

但select，poll，epoll本质上都是同步I/O，因为他们都需要在读写事件就绪后自己负责进行读写，也就是说这个读写过程是阻塞的。

select和poll都需要在返回后，通过遍历文件描述符来获取已经就绪的socket。

epoll是在2.6内核中提出的，是之前的select和poll的增强版本。

### epoll

epoll事先通过epoll_ctl()来注册一 个文件描述符，一旦基于某个文件描述符就绪时，内核会采用类似callback的回调机制，迅速激活这个文件描述符，当进程调用epoll_wait() 时便得到通知。

此处去掉了遍历文件描述符，而是通过监听回调的的机制。这正是epoll的魅力所在。

如果没有大量的idle -connection或者dead-connection，epoll的效率并不会比select/poll高很多，但是当遇到大量的idle- connection，就会发现epoll的效率大大高于select/poll。

#### epoll_create

```
int epoll_create(int size)；//创建一个epoll的句柄，size用来告诉内核这个监听的数目一共有多大
```

参数size并不是限制了epoll所能监听的描述符最大个数，只是对内核初始分配内部数据结构的一个建议。

当创建好epoll句柄后，它就会占用一个fd值，在linux下如果查看/proc/进程id/fd/，是能够看到这个fd的，所以在使用完epoll后，必须调用close()关闭，否则可能导致fd被耗尽。

#### epoll_ctl

```
int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event)
```

## 代码

### select 

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <assert.h>

#define IPADDR      "127.0.0.1"
#define PORT        8787
#define MAXLINE     1024
#define LISTENQ     5
#define SIZE        10

typedef struct server_context_st
{
    int cli_cnt;        /*客户端个数*/
    int clifds[SIZE];   /*客户端的个数*/
    fd_set allfds;      /*句柄集合*/
    int maxfd;          /*句柄最大值*/
} server_context_st;
static server_context_st *s_srv_ctx = NULL;
/*===========================================================================
 * ==========================================================================*/
static int create_server_proc(const char* ip,int port)
{
    int  fd;
    struct sockaddr_in servaddr;
    fd = socket(AF_INET, SOCK_STREAM,0);
    if (fd == -1) {
        fprintf(stderr, "create socket fail,erron:%d,reason:%s\n",
                errno, strerror(errno));
        return -1;
    }

    /*一个端口释放后会等待两分钟之后才能再被使用，SO_REUSEADDR是让端口释放后立即就可以被再次使用。*/
    int reuse = 1;
    if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        return -1;
    }

    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET,ip,&servaddr.sin_addr);
    servaddr.sin_port = htons(port);

    if (bind(fd,(struct sockaddr*)&servaddr,sizeof(servaddr)) == -1) {
        perror("bind error: ");
        return -1;
    }

    listen(fd,LISTENQ);

    return fd;
}

static int accept_client_proc(int srvfd)
{
    struct sockaddr_in cliaddr;
    socklen_t cliaddrlen;
    cliaddrlen = sizeof(cliaddr);
    int clifd = -1;

    printf("accpet clint proc is called.\n");

ACCEPT:
    clifd = accept(srvfd,(struct sockaddr*)&cliaddr,&cliaddrlen);

    if (clifd == -1) {
        if (errno == EINTR) {
            goto ACCEPT;
        } else {
            fprintf(stderr, "accept fail,error:%s\n", strerror(errno));
            return -1;
        }
    }

    fprintf(stdout, "accept a new client: %s:%d\n",
            inet_ntoa(cliaddr.sin_addr),cliaddr.sin_port);

    //将新的连接描述符添加到数组中
    int i = 0;
    for (i = 0; i < SIZE; i++) {
        if (s_srv_ctx->clifds[i] < 0) {
            s_srv_ctx->clifds[i] = clifd;
            s_srv_ctx->cli_cnt++;
            break;
        }
    }

    if (i == SIZE) {
        fprintf(stderr,"too many clients.\n");
        return -1;
    }

}

static int handle_client_msg(int fd, char *buf)
{
    assert(buf);
    printf("recv buf is :%s\n", buf);
    write(fd, buf, strlen(buf) +1);
    return 0;
}

static void recv_client_msg(fd_set *readfds)
{
    int i = 0, n = 0;
    int clifd;
    char buf[MAXLINE] = {0};
    for (i = 0;i <= s_srv_ctx->cli_cnt;i++) {
        clifd = s_srv_ctx->clifds[i];
        if (clifd < 0) {
            continue;
        }
        /*判断客户端套接字是否有数据*/
        if (FD_ISSET(clifd, readfds)) {
            //接收客户端发送的信息
            n = read(clifd, buf, MAXLINE);
            if (n <= 0) {
                /*n==0表示读取完成，客户都关闭套接字*/
                FD_CLR(clifd, &s_srv_ctx->allfds);
                close(clifd);
                s_srv_ctx->clifds[i] = -1;
                continue;
            }
            handle_client_msg(clifd, buf);
        }
    }
}
static void handle_client_proc(int srvfd)
{
    int  clifd = -1;
    int  retval = 0;
    fd_set *readfds = &s_srv_ctx->allfds;
    struct timeval tv;
    int i = 0;

    while (1) {
        /*每次调用select前都要重新设置文件描述符和时间，因为事件发生后，文件描述符和时间都被内核修改啦*/
        FD_ZERO(readfds);
        /*添加监听套接字*/
        FD_SET(srvfd, readfds);
        s_srv_ctx->maxfd = srvfd;

        tv.tv_sec = 30;
        tv.tv_usec = 0;
        /*添加客户端套接字*/
        for (i = 0; i < s_srv_ctx->cli_cnt; i++) {
            clifd = s_srv_ctx->clifds[i];
            /*去除无效的客户端句柄*/
            if (clifd != -1) {
                FD_SET(clifd, readfds);
            }
            s_srv_ctx->maxfd = (clifd > s_srv_ctx->maxfd ? clifd : s_srv_ctx->maxfd);
        }

        /*开始轮询接收处理服务端和客户端套接字*/
        retval = select(s_srv_ctx->maxfd + 1, readfds, NULL, NULL, &tv);
        if (retval == -1) {
            fprintf(stderr, "select error:%s.\n", strerror(errno));
            return;
        }
        if (retval == 0) {
            fprintf(stdout, "select is timeout.\n");
            continue;
        }
        if (FD_ISSET(srvfd, readfds)) {
            /*监听客户端请求*/
            accept_client_proc(srvfd);
        } else {
            /*接受处理客户端消息*/
            recv_client_msg(readfds);
        }
    }
}

static void server_uninit()
{
    if (s_srv_ctx) {
        free(s_srv_ctx);
        s_srv_ctx = NULL;
    }
}

static int server_init()
{
    s_srv_ctx = (server_context_st *)malloc(sizeof(server_context_st));
    if (s_srv_ctx == NULL) {
        return -1;
    }

    memset(s_srv_ctx, 0, sizeof(server_context_st));

    int i = 0;
    for (;i < SIZE; i++) {
        s_srv_ctx->clifds[i] = -1;
    }

    return 0;
}

int main(int argc,char *argv[])
{
    int  srvfd;
    /*初始化服务端context*/
    if (server_init() < 0) {
        return -1;
    }
    /*创建服务,开始监听客户端请求*/
    srvfd = create_server_proc(IPADDR, PORT);
    if (srvfd < 0) {
        fprintf(stderr, "socket create or bind fail.\n");
        goto err;
    }
    /*开始接收并处理客户端请求*/
    handle_client_proc(srvfd);
    server_uninit();
    return 0;
err:
    server_uninit();
    return -1;
}
```

### poll

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <netinet/in.h>
#include <sys/socket.h>
#include <poll.h>
#include <unistd.h>
#include <sys/types.h>

#define IPADDRESS   "127.0.0.1"
#define PORT        8787
#define MAXLINE     1024
#define LISTENQ     5
#define OPEN_MAX    1000
#define INFTIM      -1

//函数声明
//创建套接字并进行绑定
static int socket_bind(const char* ip,int port);
//IO多路复用poll
static void do_poll(int listenfd);
//处理多个连接
static void handle_connection(struct pollfd *connfds,int num);

int main(int argc,char *argv[])
{
    int  listenfd,connfd,sockfd;
    struct sockaddr_in cliaddr;
    socklen_t cliaddrlen;
    listenfd = socket_bind(IPADDRESS,PORT);
    listen(listenfd,LISTENQ);
    do_poll(listenfd);
    return 0;
}

static int socket_bind(const char* ip,int port)
{
    int  listenfd;
    struct sockaddr_in servaddr;
    listenfd = socket(AF_INET,SOCK_STREAM,0);
    if (listenfd == -1)
    {
        perror("socket error:");
        exit(1);
    }
    bzero(&servaddr,sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET,ip,&servaddr.sin_addr);
    servaddr.sin_port = htons(port);
    if (bind(listenfd,(struct sockaddr*)&servaddr,sizeof(servaddr)) == -1)
    {
        perror("bind error: ");
        exit(1);
    }
    return listenfd;
}

static void do_poll(int listenfd)
{
    int  connfd,sockfd;
    struct sockaddr_in cliaddr;
    socklen_t cliaddrlen;
    struct pollfd clientfds[OPEN_MAX];
    int maxi;
    int i;
    int nready;
    //添加监听描述符
    clientfds[0].fd = listenfd;
    clientfds[0].events = POLLIN;
    //初始化客户连接描述符
    for (i = 1;i < OPEN_MAX;i++)
        clientfds[i].fd = -1;
    maxi = 0;
    //循环处理
    for ( ; ; )
    {
        //获取可用描述符的个数
        nready = poll(clientfds,maxi+1,INFTIM);
        if (nready == -1)
        {
            perror("poll error:");
            exit(1);
        }
        //测试监听描述符是否准备好
        if (clientfds[0].revents & POLLIN)
        {
            cliaddrlen = sizeof(cliaddr);
            //接受新的连接
            if ((connfd = accept(listenfd,(struct sockaddr*)&cliaddr,&cliaddrlen)) == -1)
            {
                if (errno == EINTR)
                    continue;
                else
                {
                   perror("accept error:");
                   exit(1);
                }
            }
            fprintf(stdout,"accept a new client: %s:%d\n", inet_ntoa(cliaddr.sin_addr),cliaddr.sin_port);
            //将新的连接描述符添加到数组中
            for (i = 1;i < OPEN_MAX;i++)
            {
                if (clientfds[i].fd < 0)
                {
                    clientfds[i].fd = connfd;
                    break;
                }
            }
            if (i == OPEN_MAX)
            {
                fprintf(stderr,"too many clients.\n");
                exit(1);
            }
            //将新的描述符添加到读描述符集合中
            clientfds[i].events = POLLIN;
            //记录客户连接套接字的个数
            maxi = (i > maxi ? i : maxi);
            if (--nready <= 0)
                continue;
        }
        //处理客户连接
        handle_connection(clientfds,maxi);
    }
}

static void handle_connection(struct pollfd *connfds,int num)
{
    int i,n;
    char buf[MAXLINE];
    memset(buf,0,MAXLINE);
    for (i = 1;i <= num;i++)
    {
        if (connfds[i].fd < 0)
            continue;
        //测试客户描述符是否准备好
        if (connfds[i].revents & POLLIN)
        {
            //接收客户端发送的信息
            n = read(connfds[i].fd,buf,MAXLINE);
            if (n == 0)
            {
                close(connfds[i].fd);
                connfds[i].fd = -1;
                continue;
            }
           // printf("read msg is: ");
            write(STDOUT_FILENO,buf,n);
            //向客户端发送buf
            write(connfds[i].fd,buf,n);
        }
    }
}
```

### epoll

```c
#define MAX_EVENTS 10
struct epoll_event ev, events[MAX_EVENTS];
int listen_sock, conn_sock, nfds, epollfd;

/* Set up listening socket, 'listen_sock' (socket(),
  bind(), listen()) */

epollfd = epoll_create(10);
if(epollfd == -1) {
   perror("epoll_create");
   exit(EXIT_FAILURE);
}

ev.events = EPOLLIN;
ev.data.fd = listen_sock;
if(epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev) == -1) {
   perror("epoll_ctl: listen_sock");
   exit(EXIT_FAILURE);
}

for(;;) {
   nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1);
   if (nfds == -1) {
       perror("epoll_pwait");
       exit(EXIT_FAILURE);
   }

   for (n = 0; n < nfds; ++n) {
       if (events[n].data.fd == listen_sock) {
           //主监听socket有新连接
           conn_sock = accept(listen_sock,
                           (struct sockaddr *) &local, &addrlen);
           if (conn_sock == -1) {
               perror("accept");
               exit(EXIT_FAILURE);
           }
           setnonblocking(conn_sock);
           ev.events = EPOLLIN | EPOLLET;
           ev.data.fd = conn_sock;
           if (epoll_ctl(epollfd, EPOLL_CTL_ADD, conn_sock,
                       &ev) == -1) {
               perror("epoll_ctl: conn_sock");
               exit(EXIT_FAILURE);
           }
       } else {
           //已建立连接的可读写句柄
           do_use_fd(events[n].data.fd);
       }
   }
}
```

## 参考

- [Linux IO模式及 select、poll、epoll详解](https://segmentfault.com/a/1190000003063859)
- [IO多路复用之select总结](https://www.cnblogs.com/anker/p/3258674.html)
- [IO多路复用之poll总结](https://www.cnblogs.com/anker/p/3261006.html)
- [深入理解IO复用之epoll](https://zhuanlan.zhihu.com/p/87843750)