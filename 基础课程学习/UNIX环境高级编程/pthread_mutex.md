保证total的累加结果是符合预期的

```c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>

int total = 0;
pthread_mutex_t mutex;

void *worker(void *data){
    pthread_mutex_lock(&mutex);//加锁
    for(int i=0;i<1e6;i++){
        total++;
    }
    pthread_mutex_unlock(&mutex);//解锁
}

void init(void){
    int err;
    err = pthread_mutex_init(&mutex, NULL);
    if(err){
        printf("pthread_mutex_init fail\n");
        exit(1);
    }
}

void main(void){
    init();

    pthread_t tid1, tid2;
    int err;
    err = pthread_create(&tid1, NULL, worker, NULL);
    if(err){
        printf("pthread_create fail\n");
        exit(1);
    }
    err = pthread_create(&tid2, NULL, worker, NULL);
    if(err){
        printf("pthread_create fail\n");
        exit(1);
    }
    sleep(1);
    printf("total: %d\n", total);
}
```

使用trylock，非阻塞加锁

```c
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>

int total = 0;
pthread_mutex_t mutex;

void *worker(void *data){
    int err;
    for(;;){
        err = pthread_mutex_trylock(&mutex);
        if (err!=0){
            printf("trylock fail, wait retry\n");
        }else{
            break;
        }
    }
    // pthread_mutex_lock(&mutex);

    for(int i=0;i<1e6;i++){
        total++;
    }
    pthread_mutex_unlock(&mutex);
}

void init(void){
    int err;
    err = pthread_mutex_init(&mutex, NULL);
    if(err){
        printf("pthread_mutex_init fail\n");
        exit(1);
    }
}

void main(void){
    init();

    pthread_t tid1, tid2;
    int err;
    err = pthread_create(&tid1, NULL, worker, NULL);
    if(err){
        printf("pthread_create fail\n");
        exit(1);
    }
    err = pthread_create(&tid2, NULL, worker, NULL);
    if(err){
        printf("pthread_create fail\n");
        exit(1);
    }
    sleep(1);
    printf("total: %d\n", total);
}
```

运行

```
zyl@mydev:~/codes/clang$ gcc -o pthread1 -pthread pthread1.c && time ./pthread1
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
trylock fail, wait retry
total: 2000000

real	0m1.002s
user	0m0.007s
sys	0m0.000s
```


## 参考

- Unix环境高级编程
