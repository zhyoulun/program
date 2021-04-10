```c
#include <apue.h>

static void sig_usr(int);

int main(void) {
    if (signal(SIGUSR1, sig_usr) == SIG_ERR) {
        err_sys("can't catch SIGUSR1");
    }
    if (signal(SIGUSR2, sig_usr) == SIG_ERR) {
        err_sys("can't catch SIGUSR2");
    }
    for (;;) {
        pause();
    }
}

static void sig_usr(int signo) {
    if (signo == SIGUSR1) {
        printf("received SIGUSR1\n");
    } else if (signo == SIGUSR2) {
        printf("received SIGUSR2\n");
    } else {
        err_dump("received signal %d\n", signo);
    }
}
```

```
➜  apue001 git:(master) ✗ ./cmake-build-debug/apue001 &
[1] 54850
➜  apue001 git:(master) ✗ kill -USR1 54850
received SIGUSR1    
➜  apue001 git:(master) ✗ kill -USR2 54850  
received SIGUSR2
➜  apue001 git:(master) ✗ kill 54850      
[1]  + 54850 terminated  ./cmake-build-debug/apue001
```

## 参考

- apue.3e