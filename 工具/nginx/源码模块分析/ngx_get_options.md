```bash
$ ./objs/nginx -h
nginx version: nginx/1.14.2
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/local/nginx/)
  -c filename   : set configuration file (default: conf/nginx.conf)
  -g directives : set global directives out of configuration file
```

```bash
$ ./objs/nginx -V
nginx version: nginx/1.14.2
built by gcc 7.5.0 (Ubuntu 7.5.0-3ubuntu1~18.04)
configure arguments: --with-debug --add-module=./custom_module/mytest
```

```bash
$ /nginx -g "pid /var/run/nginx.pid; worker_processes `sysctl -n hw.ncpu`;"
```


```c
static ngx_uint_t   ngx_show_help;//查看帮助信息
static ngx_uint_t   ngx_show_version;//查看版本信息
static ngx_uint_t   ngx_show_configure;//查看configure的配置信息
static u_char      *ngx_prefix;//prefix信息
static u_char      *ngx_conf_file;//conf文件信息
static u_char      *ngx_conf_params;//在配置文件之外，再设置一些全局指令(directives)
static char        *ngx_signal;//给进程发信号：stop/quit/reopen/reload
```

```c
ngx_uint_t             ngx_test_config;//检查配置是否合法
ngx_uint_t             ngx_dump_config;//dump 配置
ngx_uint_t             ngx_quiet_mode;//安静模式，用来少打几条日志，不是很关键
```

## 参考

- [Nginx命令行参数](https://www.hxstrive.com/article/711.htm)