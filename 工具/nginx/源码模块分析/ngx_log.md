## 日志级别

```c
#define NGX_LOG_STDERR            0
#define NGX_LOG_EMERG             1
#define NGX_LOG_ALERT             2
#define NGX_LOG_CRIT              3
#define NGX_LOG_ERR               4
#define NGX_LOG_WARN              5
#define NGX_LOG_NOTICE            6
#define NGX_LOG_INFO              7
#define NGX_LOG_DEBUG             8
```

## DEBUG日志

- 日志级别为`NGX_LOG_DEBUG`
- 依次为支持传递0~8个args变量

- ngx_log_debug0
- ngx_log_debug1
- ngx_log_debug2
- ngx_log_debug3
- ngx_log_debug4
- ngx_log_debug5
- ngx_log_debug6
- ngx_log_debug7
- ngx_log_debug8

支持分模块选择性输出，可以选择的模块有：

```c
#define NGX_LOG_DEBUG_CORE        0x010
#define NGX_LOG_DEBUG_ALLOC       0x020
#define NGX_LOG_DEBUG_MUTEX       0x040
#define NGX_LOG_DEBUG_EVENT       0x080
#define NGX_LOG_DEBUG_HTTP        0x100
#define NGX_LOG_DEBUG_MAIL        0x200
#define NGX_LOG_DEBUG_STREAM      0x400
```



```c
#define ngx_log_debug0(level, log, err, fmt)                                  \
        ngx_log_debug(level, log, err, fmt)

#define ngx_log_debug1(level, log, err, fmt, arg1)                            \
        ngx_log_debug(level, log, err, fmt, arg1)

#define ngx_log_debug2(level, log, err, fmt, arg1, arg2)                      \
        ngx_log_debug(level, log, err, fmt, arg1, arg2)

#define ngx_log_debug3(level, log, err, fmt, arg1, arg2, arg3)                \
        ngx_log_debug(level, log, err, fmt, arg1, arg2, arg3)

#define ngx_log_debug4(level, log, err, fmt, arg1, arg2, arg3, arg4)          \
        ngx_log_debug(level, log, err, fmt, arg1, arg2, arg3, arg4)

#define ngx_log_debug5(level, log, err, fmt, arg1, arg2, arg3, arg4, arg5)    \
        ngx_log_debug(level, log, err, fmt, arg1, arg2, arg3, arg4, arg5)

#define ngx_log_debug6(level, log, err, fmt,                                  \
                       arg1, arg2, arg3, arg4, arg5, arg6)                    \
        ngx_log_debug(level, log, err, fmt,                                   \
                       arg1, arg2, arg3, arg4, arg5, arg6)

#define ngx_log_debug7(level, log, err, fmt,                                  \
                       arg1, arg2, arg3, arg4, arg5, arg6, arg7)              \
        ngx_log_debug(level, log, err, fmt,                                   \
                       arg1, arg2, arg3, arg4, arg5, arg6, arg7)

#define ngx_log_debug8(level, log, err, fmt,                                  \
                       arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)        \
        ngx_log_debug(level, log, err, fmt,                                   \
                       arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
```

调用者不直接使用ngx_log_debug函数

## ERROR日志

使用者调用`ngx_log_error`函数输出日志

```c
#define ngx_log_error(level, log, ...)                                        \
    if ((log)->log_level >= level) ngx_log_error_core(level, log, __VA_ARGS__)
```

可以传递的level有

```
#define NGX_LOG_STDERR            0
#define NGX_LOG_EMERG             1
#define NGX_LOG_ALERT             2
#define NGX_LOG_CRIT              3
#define NGX_LOG_ERR               4
#define NGX_LOG_WARN              5
#define NGX_LOG_NOTICE            6
#define NGX_LOG_INFO              7
#define NGX_LOG_DEBUG             8
```

## 看看缓存到的错误日志内容

```c
void print_ngx_sys_errlist(ngx_log_t *log){
    for (int i = 0; i < NGX_SYS_NERR; i++){
        ngx_log_debug2(NGX_LOG_DEBUG_CORE, log, 0, "ngx_sys_errlist[%d]=%s",i, ngx_sys_errlist[i].data);
    }
}
```

```
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[0]=Success
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[1]=Operation not permitted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[2]=No such file or directory
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[3]=No such process
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[4]=Interrupted system call
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[5]=Input/output error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[6]=No such device or address
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[7]=Argument list too long
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[8]=Exec format error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[9]=Bad file descriptor
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[10]=No child processes
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[11]=Resource temporarily unavailable
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[12]=Cannot allocate memory
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[13]=Permission denied
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[14]=Bad address
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[15]=Block device required
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[16]=Device or resource busy
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[17]=File exists
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[18]=Invalid cross-device link
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[19]=No such device
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[20]=Not a directory
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[21]=Is a directory
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[22]=Invalid argument
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[23]=Too many open files in system
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[24]=Too many open files
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[25]=Inappropriate ioctl for device
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[26]=Text file busy
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[27]=File too large
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[28]=No space left on device
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[29]=Illegal seek
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[30]=Read-only file system
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[31]=Too many links
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[32]=Broken pipe
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[33]=Numerical argument out of domain
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[34]=Numerical result out of range
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[35]=Resource deadlock avoided
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[36]=File name too long
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[37]=No locks available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[38]=Function not implemented!
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[39]=Directory not empty
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[40]=Too many levels of symbolic links
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[41]=Unknown error 41
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[42]=No message of desired type
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[43]=Identifier removed
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[44]=Channel number out of range
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[45]=Level 2 not synchronized!
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[46]=Level 3 halted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[47]=Level 3 reset
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[48]=Link number out of range1
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[49]=Protocol driver not attached
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[50]=No CSI structure available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[51]=Level 2 halted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[52]=Invalid exchange
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[53]=Invalid request descriptor
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[54]=Exchange full
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[55]=No anode
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[56]=Invalid request code
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[57]=Invalid slot
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[58]=Unknown error 58
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[59]=Bad font file format
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[60]=Device not a stream
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[61]=No data available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[62]=Timer expired
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[63]=Out of streams resources1
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[64]=Machine is not on the network
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[65]=Package not installed
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[66]=Object is remote
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[67]=Link has been severed
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[68]=Advertise error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[69]=Srmount error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[70]=Communication error on send
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[71]=Protocol error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[72]=Multihop attempted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[73]=RFS specific error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[74]=Bad message
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[75]=Value too large for defined data type
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[76]=Name not unique on network
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[77]=File descriptor in bad state
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[78]=Remote address changed
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[79]=Can not access a needed shared library
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[80]=Accessing a corrupted shared library
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[81]=.lib section in a.out corrupted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[82]=Attempting to link in too many shared libraries
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[83]=Cannot exec a shared library directly
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[84]=Invalid or incomplete multibyte or wide character
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[85]=Interrupted system call should be restarted
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[86]=Streams pipe error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[87]=Too many users
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[88]=Socket operation on non-socket
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[89]=Destination address required
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[90]=Message too long
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[91]=Protocol wrong type for socket
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[92]=Protocol not available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[93]=Protocol not supported
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[94]=Socket type not supported
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[95]=Operation not supported
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[96]=Protocol family not supported
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[97]=Address family not supported by protocol!
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[98]=Address already in use
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[99]=Cannot assign requested address
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[100]=Network is down
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[101]=Network is unreachable
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[102]=Network dropped connection on reset
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[103]=Software caused connection abort
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[104]=Connection reset by peer1
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[105]=No buffer space available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[106]=Transport endpoint is already connected
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[107]=Transport endpoint is not connected
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[108]=Cannot send after transport endpoint shutdown
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[109]=Too many references: cannot splice
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[110]=Connection timed out
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[111]=Connection refused
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[112]=Host is down
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[113]=No route to host
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[114]=Operation already in progress
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[115]=Operation now in progress
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[116]=Stale file handle
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[117]=Structure needs cleaning1
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[118]=Not a XENIX named type file
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[119]=No XENIX semaphores available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[120]=Is a named type file
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[121]=Remote I/O error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[122]=Disk quota exceeded
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[123]=No medium found
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[124]=Wrong medium type
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[125]=Operation canceled
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[126]=Required key not available
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[127]=Key has expired
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[128]=Key has been revoked
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[129]=Key was rejected by service
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[130]=Owner died
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[131]=State not recoverable
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[132]=Operation not possible due to RF-kill
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[133]=Memory page has hardware error
2021/07/03 08:19:00 [debug] 19939#0: ngx_sys_errlist[134]=Unknown error 134
```