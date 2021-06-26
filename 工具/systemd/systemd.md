## 知识点

systemd默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，会指向别的目录。

## 常用命令

**查看单个Unit的状态**

命令

```
systemctl status nginx
```

示例

```
 $ systemctl status nginx
● nginx.service - The NGINX HTTP and reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2020-03-21 11:55:02 CST; 58s ago
  Process: 1173 ExecStart=/dataz/software/nginx/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 1172 ExecStartPre=/dataz/software/nginx/sbin/nginx -t (code=exited, status=0/SUCCESS)
 Main PID: 1174 (nginx)
    Tasks: 2 (limit: 4915)
   CGroup: /system.slice/nginx.service
           ├─1174 nginx: master process /dataz/software/nginx/sbin/nginx
           └─1175 nginx: worker process

3月 21 11:55:02 zyl-PC systemd[1]: Starting The NGINX HTTP and reverse proxy server...
3月 21 11:55:02 zyl-PC nginx[1172]: nginx: the configuration file /dataz/software/nginx-1.16.1/conf/nginx.conf syntax is ok
3月 21 11:55:02 zyl-PC nginx[1172]: nginx: configuration file /dataz/software/nginx-1.16.1/conf/nginx.conf test is successful
3月 21 11:55:02 zyl-PC systemd[1]: Started The NGINX HTTP and reverse proxy server.
```

**查看配置文件内容**

```
systemctl cat nginx
```

```
 $ systemctl cat nginx
# /lib/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/dataz/software/nginx/sbin/nginx -t
ExecStart=/dataz/software/nginx/sbin/nginx
ExecReload=/dataz/software/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

**启用/禁用配置文件**

```
systemctl enable/disable nginx
```

systemd 默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/usr/lib/systemd/system/`，真正的配置文件存放在那个目录。

该命令用于在上面两个目录之间，建立符号链接关系

```bash
$ sudo systemctl enable clamd@scan.service
# 等同于
$ sudo ln -s '/usr/lib/systemd/system/clamd@scan.service' '/etc/systemd/system/multi-user.target.wants/clamd@scan.service'
```

如果配置文件里面设置了开机启动，`systemctl enable`命令相当于激活开机启动。

与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。

**重载所有修改过的配置文件**

```
systemctl daemon-reload
```

**查看配置文件内容**

```
systemctl cat nginx.service
```

**查看service的stdout/stderr日志**

```
journalctl -u http8081.service
```



```
zyl@mydev:~/systemd$ journalctl --help
journalctl [OPTIONS...] [MATCHES...]

Query the journal.

Options:
     --system                Show the system journal
     --user                  Show the user journal for the current user
  -u --unit=UNIT             Show logs from the specified unit
     --user-unit=UNIT        Show logs from the specified user unit
```

### 一个例子

```bash
zyl@mydev:~$ systemctl status
● mydev
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Sat 2021-06-26 02:56:40 UTC; 2min 22s ago
   CGroup: /
           ├─user.slice
           │ └─user-1000.slice
           │   ├─user@1000.service
           │   │ └─init.scope
           │   │   ├─1399 /lib/systemd/systemd --user
           │   │   └─1410 (sd-pam)
           │   ├─session-3.scope
           │   │ ├─1892 sshd: zyl [priv]
           │   │ ├─1958 sshd: zyl@pts/0
           │   │ ├─1959 -bash
           │   │ ├─2082 systemctl status
           │   │ └─2083 pager
           │   └─session-1.scope
           │     ├─1531 -bash
           │     ├─1537 bash
           │     ├─1582 sh /home/zyl/.vscode-server/bin/054a9295330880ed74ceaedda236253b4f39a335/server.sh --start-server --host
           │     ├─1590 /home/zyl/.vscode-server/bin/054a9295330880ed74ceaedda236253b4f39a335/node /home/zyl/.vscode-server/bin/
           │     ├─1658 sleep 180
           │     └─1663 /home/zyl/.vscode-server/bin/054a9295330880ed74ceaedda236253b4f39a335/node /home/zyl/.vscode-server/bin/
           ├─init.scope
           │ └─1 /sbin/init maybe-ubiquity
           └─system.slice
             ├─irqbalance.service
             │ └─948 /usr/sbin/irqbalance --foreground
             ├─systemd-networkd.service
             │ └─829 /lib/systemd/systemd-networkd
             ├─systemd-udevd.service
             │ └─446 /lib/systemd/systemd-udevd
             ├─cron.service
             │ └─951 /usr/sbin/cron -f
             ├─polkit.service
             │ └─1119 /usr/lib/policykit-1/polkitd --no-debug
             ├─networkd-dispatcher.service
             │ └─985 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
             ├─accounts-daemon.service
             │ └─952 /usr/lib/accountsservice/accounts-daemon
             ├─systemd-journald.service
             │ └─423 /lib/systemd/systemd-journald
             ├─atd.service
             │ └─950 /usr/sbin/atd -f
             ├─unattended-upgrades.service
             │ └─1066 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
             ├─ssh.service
             │ └─1084 /usr/sbin/sshd -D
             ├─rsyslog.service
             │ └─954 /usr/sbin/rsyslogd -n
             ├─lxcfs.service
             │ └─955 /usr/bin/lxcfs /var/lib/lxcfs/
             ├─lvm2-lvmetad.service
             │ └─431 /sbin/lvmetad -f
             ├─systemd-resolved.service
             │ └─852 /lib/systemd/systemd-resolved
             ├─dbus.service
             │ └─988 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
             ├─systemd-timesyncd.service
             │ └─643 /lib/systemd/systemd-timesyncd
             ├─system-getty.slice
             │ └─getty@tty1.service
             │   └─1105 /sbin/agetty -o -p -- \u --noclear tty1 linux
             └─systemd-logind.service
               └─949 /lib/systemd/systemd-logind
```

## 参考

- [man systemctl](https://man7.org/linux/man-pages//man1/systemctl.1.html)
- [man systemd](https://man7.org/linux/man-pages//man1/systemd.1.html)
- [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
- [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)