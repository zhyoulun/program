## 环境

- linux
- 64位

## 配置

```
daemon off; # 关闭守护模式
master_process off; # 单进程模式，方便跟踪调试
```

## main()流程

- `ngx_int_t ngx_strerror_init(void);`：将所有的系统错误信息放到静态数组`static ngx_str_t  *ngx_sys_errlist`中
- `ngx_get_options(argc, argv)`：获取nginx进程的传参，-c/-p/-t/-s/-g等
- `ngx_show_version_info()`：打印版本信息，-h，-V相关信息
- `ngx_time_init()`：初始化时间字符串
- `ngx_regex_init()`：初始化PCRE
- `ngx_pid = ngx_getpid();`：获取进程号
- `ngx_parent = ngx_getppid();`：获取父进程号
- `log = ngx_log_init(ngx_prefix);`：打开error.log，`/usr/local/nginx/logs/error.log`
- `ngx_memzero(&init_cycle, sizeof(ngx_cycle_t));`：初始化init_cycle
- `init_cycle.log = log;`：设置init_cycle.log
- `ngx_cycle = &init_cycle;`：ngx_cycle指向init_cycle
- `init_cycle.pool = ngx_create_pool(1024, log);`：设置init_cycle.pool
- `ngx_save_argv(&init_cycle, argc, argv)`：保存argv,environ相关参数到静态变量中
- `ngx_process_options(&init_cycle)`：存储ngx_get_options()获取的相关参数到init_cycle上
- `ngx_os_init(log)`：获取若干个系统参数
- `ngx_crc32_table_init()`：初始化crc32 table
- `ngx_slab_sizes_init()`：初始化若干slab参数
- `ngx_add_inherited_sockets(&init_cycle)`：？？
- `ngx_preinit_modules()`：初始化ngx_modules数组
- `cycle = ngx_init_cycle(&init_cycle)`：很复杂。。
- `ngx_os_status(cycle->log)`：打印系统状态信息
- `ngx_cycle = cycle`：ngx_cycle指向cycle
- `ngx_init_signals(cycle->log)`：初始化signals
- `ngx_create_pidfile(&ccf->pid, cycle->log)`：创建pid文件
- `ngx_log_redirect_stderr(cycle)`：？？
- `ngx_single_process_cycle(cycle)`：？？

## ngx_single_process_cycle流程

- `ngx_set_environment(cycle, NULL)`：？？
- 遍历所有的cycle->modules，执行init_process方法
  - `cycle->modules[i]->init_process(cycle)`
- 无限循环`ngx_process_events_and_timers(cycle)`

## ngx_process_events_and_timers流程

