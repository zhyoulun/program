```
./auto/configure --add-module=./custom_module/mytest 
checking for OS
 + Darwin 20.4.0 x86_64
checking for C compiler ... found
 + using Clang C compiler
 + clang version: 12.0.5 (clang-1205.0.22.9)
checking for -Wl,-E switch ... not found
checking for gcc builtin atomic operations ... found
checking for C99 variadic macros ... found
checking for gcc variadic macros ... found
checking for gcc builtin 64 bit byteswap ... found
checking for unistd.h ... found
checking for inttypes.h ... found
checking for limits.h ... found
checking for sys/filio.h ... found
checking for sys/param.h ... found
checking for sys/mount.h ... found
checking for sys/statvfs.h ... found
checking for crypt.h ... not found
checking for Darwin specific features
 + kqueue found
checking for kqueue's EVFILT_TIMER ... found
checking for Darwin 64-bit kqueue millisecond timeout bug ... not found
checking for sendfile() ... found
checking for atomic(3) ... found
checking for nobody group ... found
checking for poll() ... found
checking for /dev/poll ... not found
checking for crypt() ... found
checking for F_READAHEAD ... not found
checking for posix_fadvise() ... not found
checking for O_DIRECT ... not found
checking for F_NOCACHE ... found
checking for directio() ... not found
checking for statfs() ... found
checking for statvfs() ... found
checking for dlopen() ... found
checking for sched_yield() ... found
checking for sched_setaffinity() ... not found
checking for SO_SETFIB ... not found
checking for SO_REUSEPORT ... found
checking for SO_ACCEPTFILTER ... not found
checking for SO_BINDANY ... not found
checking for IP_TRANSPARENT ... not found
checking for IP_BINDANY ... not found
checking for IP_BIND_ADDRESS_NO_PORT ... not found
checking for IP_RECVDSTADDR ... found
checking for IP_SENDSRCADDR ... not found
checking for IP_PKTINFO ... found
checking for IPV6_RECVPKTINFO ... found
checking for TCP_DEFER_ACCEPT ... not found
checking for TCP_KEEPIDLE ... not found
checking for TCP_FASTOPEN ... found
checking for TCP_INFO ... not found
checking for accept4() ... not found
checking for eventfd() ... not found
checking for eventfd() (SYS_eventfd) ... not found
checking for int size ... 4 bytes
checking for long size ... 8 bytes
checking for long long size ... 8 bytes
checking for void * size ... 8 bytes
checking for uint32_t ... found
checking for uint64_t ... found
checking for sig_atomic_t ... found
checking for sig_atomic_t size ... 4 bytes
checking for socklen_t ... found
checking for in_addr_t ... found
checking for in_port_t ... found
checking for rlim_t ... found
checking for uintptr_t ... uintptr_t found
checking for system byte ordering ... little endian
checking for size_t size ... 8 bytes
checking for off_t size ... 8 bytes
checking for time_t size ... 8 bytes
checking for AF_INET6 ... found
checking for setproctitle() ... not found
checking for pread() ... found
checking for pwrite() ... found
checking for pwritev() ... found
checking for sys_nerr ... found
checking for localtime_r() ... found
checking for clock_gettime(CLOCK_MONOTONIC) ... found
checking for posix_memalign() ... found
checking for memalign() ... not found
checking for mmap(MAP_ANON|MAP_SHARED) ... found
checking for mmap("/dev/zero", MAP_SHARED) ... found but is not working
checking for System V shared memory ... found
checking for POSIX semaphores ... found but is not working
checking for POSIX semaphores in libpthread ... found but is not working
checking for POSIX semaphores in librt ... not found
checking for struct msghdr.msg_control ... found
checking for ioctl(FIONBIO) ... found
checking for struct tm.tm_gmtoff ... found
checking for struct dirent.d_namlen ... found
checking for struct dirent.d_type ... found
checking for sysconf(_SC_NPROCESSORS_ONLN) ... found
checking for sysconf(_SC_LEVEL1_DCACHE_LINESIZE) ... not found
checking for openat(), fstatat() ... found
checking for getaddrinfo() ... found
configuring additional modules
adding module in ./custom_module/mytest
 + ngx_http_mytest_module was configured
checking for PCRE library ... found
checking for PCRE JIT support ... found
checking for zlib library ... found
creating objs/Makefile

Configuration summary
  + using system PCRE library
  + OpenSSL library is not used
  + using system zlib library

  nginx path prefix: "/usr/local/nginx"
  nginx binary file: "/usr/local/nginx/sbin/nginx"
  nginx modules path: "/usr/local/nginx/modules"
  nginx configuration prefix: "/usr/local/nginx/conf"
  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
  nginx error log file: "/usr/local/nginx/logs/error.log"
  nginx http access log file: "/usr/local/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"
```