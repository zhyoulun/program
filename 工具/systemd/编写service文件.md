## 一个基本的service文件

`http8081.service`

```
[Unit]
Description=http 8081 service
After=network.target

[Service]
ExecStart=/usr/bin/go run /home/zyl/systemd/http.go -port 8081
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

介绍

- `[Unit]` 区块
  - Description：当前服务的简单描述
  - Documentation：文档位置
  - After：表示如果network.target需要启动，那么http8081.service应该在它们之后启动
    - After&Before：只涉及启动顺序，不涉及依赖关系
    - 设置依赖关系，需要使用Wants字段和Requires字段。
  - Before：应该在哪些服务之前启动
  - Wants：表示sshd.service与sshd-keygen.service之间存在"弱依赖"关系，即如果"sshd-keygen.service"启动失败或停止运行，不影响sshd.service继续执行
  - Requires：表示"强依赖"关系，即如果该服务启动失败或异常退出，那么sshd.service也必须退出。
- `[Service]`区块
  - ExecStart：定义启动进程时执行的命令
  - ExecReload：重启服务时执行的命令
  - ExecStop：停止服务时执行的命令
  - ExecStartPre：启动服务之前执行的命令
  - ExecStartPost：启动服务之后执行的命令
  - ExecStopPost：停止服务之后执行的命令
  - Restart：定义了 sshd 退出后，systemd 的重启方式
    - 可以设置的值如下：
      - no（默认值）：退出后不会重启
      - on-success：只有正常退出时（退出状态码为0），才会重启
      - on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
      - on-abnormal：只有被信号终止和超时，才会重启
      - on-abort：只有在收到没有捕捉到的信号终止时，才会重启
      - on-watchdog：超时退出，才会重启
      - always：不管是什么退出原因，总是重启
  - RestartSec：表示 systemd 重启服务之前，需要等待的秒数。
- `[Install]`区块
  - WantedBy：表示该服务所在的 Target。
    - Target的含义是服务组，表示一组服务。WantedBy=multi-user.target指的是，sshd 所在的 Target 是multi-user.target。
    - 这个设置非常重要，因为执行systemctl enable sshd.service命令时，sshd.service的一个符号链接，就会放在/etc/systemd/system目录下面的multi-user.target.wants子目录之中。
    - 一般来说，常用的 Target 有两个：一个是multi-user.target，表示多用户命令行状态；另一个是graphical.target，表示图形用户状态，它依赖于multi-user.target。target依赖关系图：https://www.freedesktop.org/software/systemd/man/bootup.html#System%20Manager%20Bootup



## 参考

- [man systemctl](https://man7.org/linux/man-pages//man1/systemctl.1.html)
- [man systemd](https://man7.org/linux/man-pages//man1/systemd.1.html)
- [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)

