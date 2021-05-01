## 代码

- https://github.com/zhyoulun/clib/blob/master/src/core/queue.c
- https://github.com/zhyoulun/clib/blob/master/src/core/queue.h

### header

```c
//
// Created by zhangyoulun on 2021/4/11.
//

#ifndef CLIB_QUEUE_H
#define CLIB_QUEUE_H

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>

#define QUEUE_INIT_SIZE 8

struct queue {
    void *arr;
    int front;//队头指针
    int rear;//队尾指针
    int size;//存储数据的个数
    int cap;//队列容量
    int type_size;//元素类型大小，如果是int，则为sizeof(int)
};

typedef struct queue queue;

queue *queue_create(int type_size);

void queue_enqueue(queue *q, void *x);

void *queue_dequeue(queue *q);

int queue_empty(queue *q);

void *queue_head(queue *q);

void queue_print(queue *q);


#endif //CLIB_QUEUE_H
```

### source

```c
//
// Created by zhangyoulun on 2021/4/11.
//

#include "queue.h"

queue *queue_create(int type_size) {
    queue *q = (queue *) malloc(sizeof(queue));
    q->size = 0;
    q->front = -1;
    q->rear = -1;
    q->cap = QUEUE_INIT_SIZE;
    q->type_size = type_size;
    q->arr = (void *) malloc(q->type_size * q->cap);
    return q;
}

void queue_copy_element(void *src, void *dst, int type_size) {
    for (int i = 0; i < type_size; i++) {
        *(((uint8_t *) dst) + i) = *(((uint8_t *) src) + i);
    }
}

void *queue_arr_pos(void *arr, int index, int type_size) {
    return (void *) (((uint8_t *) arr) + index * type_size);
}

void queue_resize(queue *q, int new_cap) {
    void *new_arr = (void *) malloc(q->type_size * new_cap);
    int index = q->front;
    for (int i = 0; i < q->size; i++) {
        index++;
        index %= q->cap;
//        new_arr[i] = q->arr[index];
        queue_copy_element(queue_arr_pos(q->arr, index, q->type_size), queue_arr_pos(new_arr, i, q->type_size),
                           q->type_size);
    }
    q->front = -1;
    q->rear = q->size - 1;
    q->cap = new_cap;
    void *old_arr = q->arr;
    q->arr = new_arr;
    free(old_arr);
}

void queue_enqueue(queue *q, void *x) {
    if (q->size == q->cap) {
        queue_resize(q, q->cap * 2);
    }
    q->rear++;
    q->rear %= q->cap;
    q->size++;
//    q->arr[q->rear] = x;
    queue_copy_element(x, queue_arr_pos(q->arr, q->rear, q->type_size), q->type_size);
}

void *queue_dequeue(queue *q) {
    assert(q->size > 0);
    q->front++;
    q->front %= q->cap;
    q->size--;
//    int res = q->arr[q->front];
    void *res = (void *) malloc(q->type_size);
    queue_copy_element(queue_arr_pos(q->arr, q->front, q->type_size), res, q->type_size);
    if (q->cap > QUEUE_INIT_SIZE && q->size < q->cap / 2) {
        queue_resize(q, q->cap / 2);
    }
    return res;
}

int queue_empty(queue *q) {
    return q->size == 0;
}

void *queue_head(queue *q) {
    assert(q->size > 0);
    int index = (q->front + 1) % q->cap;
//    return q->arr[index];
    void *res = (void *) malloc(q->type_size);
    queue_copy_element(queue_arr_pos(q->arr, index, q->type_size), res, q->type_size);
    return res;
}

void queue_print(queue *q) {
    //todo 补充一个通用的print方法
//    int index = q->front;
//    printf("queue: ");
//    for (int i = 0; i < q->size; i++) {
//        index++;
//        index %= q->cap;
//        printf("%d ", q->arr[index]);
//    }
//    printf("\n");
}
```

### test

```cpp
TEST(QueueTest2, BasicAssertions) {
    struct people {
        char name;
        int age;
    };

    queue *q = queue_create(sizeof(struct people));
    queue_print(q);
    struct people a = {.name = 'a', .age = 1};
    queue_enqueue(q, &a);
    queue_print(q);
    struct people *got = (struct people *) queue_head(q);
    EXPECT_EQ((*got).name, a.name);
    EXPECT_EQ((*got).age, a.age);
    EXPECT_EQ(queue_empty(q), 0);
    got = (struct people *) queue_dequeue(q);
    EXPECT_EQ((*got).name, a.name);
    EXPECT_EQ((*got).age, a.age);
    for (int i = 0; i < 10; i++) {
        struct people aa = {.name = 'a', .age = i};
        queue_enqueue(q, &aa);
    }
    queue_print(q);
    EXPECT_EQ(q->cap, 16);
    for (int i = 0; i < 10; i++) {
        struct people aa = {.name = 'a', .age = i};
        got = (struct people *) queue_dequeue(q);
        EXPECT_EQ((*got).name, 'a');
        EXPECT_EQ((*got).age, i);
    }
    EXPECT_EQ(q->cap, 8);
}
```

## 参考

- [队列-C语言实现-适用各种数据类型](https://blog.csdn.net/inintrovert/article/details/77676710)
