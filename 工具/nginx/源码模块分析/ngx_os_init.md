- ngx_os_specific_init(log)
  - ngx_linux_kern_ostype = uname.sysname
  - ngx_linux_kern_osrelease = uname.release
  - ngx_os_io = ngx_linux_io
- ngx_init_setproctitle(log)
  - ngx_os_argv_last ？？这个是干啥的
- ngx_pagesize = getpagesize()
- ngx_cacheline_size = NGX_CPU_CACHE_LINE;
  - ngx_cacheline_size = sysconf(_SC_LEVEL1_DCACHE_LINESIZE);
- ngx_pagesize_shift
- ngx_ncpu = sysconf(_SC_NPROCESSORS_ONLN);
- ngx_cpuinfo()
  - ngx_cacheline_size = 64;
- getrlimit(RLIMIT_NOFILE, &rlmt)
- ngx_max_sockets = (ngx_int_t) rlmt.rlim_cur
- ngx_inherited_nonblocking = 1;
- srandom(((unsigned) ngx_pid << 16) ^ tp->sec ^ tp->msec);