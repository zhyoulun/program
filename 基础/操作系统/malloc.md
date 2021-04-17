## 基础用法

### int *

```c
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int len = 10;
    int *arr = (int *) malloc(sizeof(int) * len);
    for (int i = 0; i < len; i++) {
        arr[i] = i * i;
    }
    for (int i = 0; i < len; i++) {
        printf("%d ", arr[i]);
    }
    return 0;
}
```

运行结果

```
0 1 4 9 16 25 36 49 64 81 
```

### struct *

```c
#include <stdio.h>
#include <stdlib.h>

struct student {
    int age;
    char *name;
};

int main(void) {
    int len = 5;
    struct student *arr = (struct student *) malloc(sizeof(struct student) * len);
    for (int i = 0; i < len; i++) {
        arr[i].name = malloc(sizeof(char) * 10);
        snprintf(arr[i].name, 5, "%c", 'a' + i);
        arr[i].age = 10 + i;
    }
    for (int i = 0; i < len; i++) {
        printf("name=%s, age=%d\n", arr[i].name, arr[i].age);
    }
    return 0;
}
```

运行结果

```
name=a, age=10
name=b, age=11
name=c, age=12
name=d, age=13
name=e, age=14
```