## ngx_module_t

```c
struct ngx_module_s {
    //----------------------
    //start: 使用NGX_MODULE_V1初始化
    //----------------------
    ngx_uint_t            ctx_index;//ctx_index是指，在ngx_modules数组中，该模块在相同类型的模块中的次序。
    ngx_uint_t            index;//初始值为-1；index变量是指，该模块在ngx_modules数组中的次序，或者说下标。该变量在Nginx执行初始化的时候被初始化，初始化代码位于core\nginx.c的main函数中；初始化的函数是ngx_preinit_modules

    char                 *name;//初始值为NULL，模块名称，在ngx_preinit_modules函数中进行初始化

    ngx_uint_t            spare0;//=0
    ngx_uint_t            spare1;//=0

    ngx_uint_t            version;//nginx版本号
    const char           *signature;
    //----------------------
    //end
    //---------------------- 

    void                 *ctx;
    ngx_command_t        *commands;
    ngx_uint_t            type;//Nginx共有5中模块类型CORF、CONF、EVNT、HTTP、MAIL

    // ngx_int_t           (*init_master)(ngx_log_t *log);//没有用；A hook into the initialisation of the master process；This hook has currently not been implemented

    ngx_int_t           (*init_module)(ngx_cycle_t *cycle);//A hook into the module initiliasation phase. This happens prior to the master process forking.

    ngx_int_t           (*init_process)(ngx_cycle_t *cycle);//A hook into the module initilisation in new process phase. This happens as the worker processes are forked.
    // ngx_int_t           (*init_thread)(ngx_cycle_t *cycle);//没有用；A hook into the initialisation of threads;This hook has currently not been implemented

    // void                (*exit_thread)(ngx_cycle_t *cycle);//没有用；A hook into the termination of a thread;This hook has currently not been implemented
    void                (*exit_process)(ngx_cycle_t *cycle);//A hook into the termination of a child process (such as a worker process)

    void                (*exit_master)(ngx_cycle_t *cycle);//A hook into the termination of the master process

    //----------------------
    //start: 使用NGX_MODULE_V1_PADDING初始化
    //----------------------
    //保留字段，没有用
    uintptr_t             spare_hook0;
    uintptr_t             spare_hook1;
    uintptr_t             spare_hook2;
    uintptr_t             spare_hook3;
    uintptr_t             spare_hook4;
    uintptr_t             spare_hook5;
    uintptr_t             spare_hook6;
    uintptr_t             spare_hook7;
    //----------------------
    //end
    //----------------------
};
```

ngx_module_t是整个nginx的关键，它提供了整个nginx的模块化的基础。因此，看懂ngx_module_t结构体才能开始入门nginx源码阅读。

1. init_module
2. init_process
3. exit_process, exit_master

### ngx_core_module

ngx_core_module是ngx_module_t类型的一个变量

```c
static ngx_core_module_t  ngx_core_module_ctx = {
    ngx_string("core"),
    ngx_core_module_create_conf,
    ngx_core_module_init_conf
};

ngx_module_t  ngx_core_module = {
    NGX_MODULE_V1,
    &ngx_core_module_ctx,                  /* module context */
    ngx_core_commands,                     /* module directives */
    NGX_CORE_MODULE,                       /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};
```

## ngx_core_module_t

```c
typedef struct {
    ngx_str_t             name;//A string containing the name for the module
    void               *(*create_conf)(ngx_cycle_t *cycle);//A callback for allocations and initilization of configuration
    char               *(*init_conf)(ngx_cycle_t *cycle, void *conf);//A callback to set the configurtion based on directives supplied in the configuration files
} ngx_core_module_t;
```

1. create_conf
2. init_conf

## 参考

- [分析Nginx 源码 - ngx_module_t接口总结](https://segmentfault.com/a/1190000011335585)