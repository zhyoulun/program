## 函数open和openat

参数oflag

- O_RDONLY：只读打开
- O_WRONLY：只写打开
- O_RDWR：读写打开
- O_EXEC：只执行打开

这4个常量中必须制定一个且只只能指定一个，下述常量是可选的：

- O_APPEND：追加到文件末端
  - 这样做使得内核在每次写操作前，都将进程偏移量设置到该文件的尾端处。于是在写之前就不再需要调用lseek
- O_CLOEXEC：？？
- O_CREAT：若此文件不存在，则创建它
  - 使用此选项时，需要指定mode参数，指定新文件的访问权限
- O_DIRECTORY：如果参数path引用的不是目录，则出错
- O_EXCL：如果同时指定了O_CREAT，而文件已经存在，则出错。用此可以测试一个文件是否存在，如果不存在，则创建此文件。这使测试和创建两者成为一个原子操作
- O_NOCTTY：？？？
- O_NOFOLLOW：如果path引用的是一个符号链接，则出错
- O_NONBLOCK：如果path引用的是一个FIFO，一个块特殊文件或者一个字符特殊文件，则此选项为文件的本次打开操作和后续的IO操作设置为非阻塞方式
- O_NDELAY：废弃
- O_SYNC：???
- O_TRUNC：如果文件存在，而且为只写或者读写成功打开，则将长度截断为0
- O_TTY_INIT：???
- O_DSYNC：???
- O_RSYNC：???

## 函数create

函数create可以创建一个新文件，此函数等效于

```
open(path, O_WRONLY|O_CREAT|O_TRUNC, mode);
```

create函数的不足之处是它以只写方式打开所创建的文件。

在提供open的新版本之前，如果要创建一个临时文件，并要先写该文件，然后又读该文件，则必须先调用creat, close，然后再调用open。

## 函数close

关闭一个打开的文件

关闭一个文件时，还会释放该进程加在该文件上的所有记录锁。

当一个进程终止时，内核自动关闭它所有的打开文件。很多程序都利用这一功能，而不先是地用close关闭打开文件。

## 函数seek？？？

## 函数read

调用read函数，从打开的文件中读数据

如果read成功，则返回读到的字节数。如果已经达到文件的尾端，则返回0

有多种情况可使实际读到的字节数少于要求读的字节数：

- 读普通文件时，在读到要求字节数之前已经达到了文件尾端
- 当从中断设备读时，通常一次最多只读一行
- 当从网络读时，网络中的缓冲机器可能造成返回值小于所要求读的字节数
- 当从管道或者FIFO读时，如果管道包含的字节数少于所需的字节量，那么read只返回实际可用的字节数
- 当从某些面向记录的设备读时，一次最多返回一个记录
- 当一信号造成中断，而已经读了部分数据量时

## 函数write

向打开的文件写数据

在一次成功写之后，该文件的偏移量增加实际写的字节数

## 文件共享

内核使用3中数据结构表示打开文件，他们之间的关系决定了在文件共享方面一个进程对另外一个进程可能产生的影响。

1. 每个进程在进程表中都有一个记录项，记录项中包含一张打开的文件描述符表，可将其视为一个矢量，每个描述符占用一项。与文件描述符相关联的是：
   1. 文件描述符标志
   2. 指向一个文件表项的指针
2. 内核为所有打开文件维持一张文件表，每个文件表项包含：
   1. 当前文件偏移量
   2. 指向该文件v节点表项的指针
3. 每个打开文件（或者设备）都有一个v节点结构。v节点包含了文件类型和对此文件进行各种操作函数的指针。

![](/static/images/2006/p036.png)

![](/static/images/2006/p037.png)

## 函数dup和dup2

复制一个现有的文件描述符

这些函数返回的新文件描述符与参数fd共享同一个文件表项

![](/static/images/2006/p038.png)

dup(fd)等效于fcntl(fd, F_DUPFD, 0)

dup2(fd,fd2)等效于

```
close(fd2)
fcntl(fd, F_DUPFD, fd2)
```

## 函数sync, fsync, fdatasync？？？

## 函数fcntl

fcntl可以改变已打开文件的属性

fcntl函数有以下五种功能：

1. 复制一个已有的描述符（cmd=F_DUPFD，F_DUPFD_CLOEXEC）
2. 获取/设置文件描述符标志（cmd=F_GETFD，F_SETFD）
3. 获取/设置文件状态标志（cmd=F_GETFL，F_SETFL）
4. 获取/设置异步I/O所有权（cmd=F_GETOWN，F_SETOWN）
5. 获取/设置记录锁（cmd=F_GETLK，F_SETLK，F_SETLKW）

### F_DUPFD

```c
#include <stdio.h>
#include <fcntl.h>


int main(int argc, char *argv[]) {
    char *fileName = "/tmp/1.txt";
    int fd = open(fileName, O_RDONLY);
    if (fd < 0) {
        perror("open error");
        return 0;
    }
    printf("open, fd=%d\n", fd);

    int fd2 = fcntl(fd, F_DUPFD);
    printf("F_DUPFD, fd2=%d\n", fd2);

    int fd3 = fcntl(fd, F_DUPFD, 10);
    printf("F_DUPFD, fd3=%d\n", fd3);

    return 0;
}
```

运行输出

```
open, fd=3
F_DUPFD, fd2=4
F_DUPFD, fd3=10
```

### F_GETFL

```c
#include <stdio.h>
#include <fcntl.h>


int main(int argc, char *argv[]) {
    char *fileName = "/tmp/1.txt";
    int fd = open(fileName, O_WRONLY | O_APPEND);
    if (fd < 0) {
        perror("open error");
        return 0;
    }
    printf("open, fd=%d\n", fd);

    int flags = fcntl(fd, F_GETFL);
    if (flags < 0) {
        perror("fcntl F_GETFL error");
        return 0;
    }

    switch (flags & O_ACCMODE) {
        case O_WRONLY:
            printf("O_ACCMODE: O_WRONLY\n");
            break;
        default:
            printf("O_ACCMODE: other\n");
    }

    if (flags & O_APPEND) {
        printf("O_APPEND: yes\n");
    } else {
        printf("O_APPEND: no\n");
    }

    if (flags & O_NONBLOCK) {
        printf("O_NONBLOCK: yes\n");
    } else {
        printf("O_NONBLOCK: no\n");
    }

    return 0;
}
```

运行输出

```
open, fd=3
O_ACCMODE: O_WRONLY
O_APPEND: yes
O_NONBLOCK: no
```