# EOF in clang

## 定义

EOF的值通常定义为-1，EOF是end of file的缩写。

```
#define	EOF	(-1)
```

所以不能用unsigned char（range: 0\~255）来存储，signed char（range: -128\~127）也基本能满足需求，但最好是更大范围的类型，例如int。

在类unix系统中，可以使用ctrl+D触发EOF，在windows系统中，可以使用ctrl+Z触发。

## fgetc用法

```c
#include <stdio.h>
int fgetc(FILE *stream);
```

fgetc() reads the next character from stream, and returns it as an **unsigned char** cast to an **int**, or **EOF** on end of file or error.

示例

```c
#include <stdio.h>

int main() {
    int a;
    while ((a = fgetc(stdin)) != EOF) {
        printf("%d:%c\n", a, a);
    }
    printf("%d\n", a);
    return 0;
}
```

运行

```bash
➜  c-study ./cmake-build-debug/c_study
abcdef  //输入abcdef，并回车
97:a
98:b
99:c
100:d
101:e
102:f
10:

-1  //输入ctrl+D
```

## fgets用法

```c
#include <stdio.h>
char *fgets(char *s, int size, FILE *stream);
```

fgets() reads in at most one less than size characters from stream and stores them into the buffer pointed to by s. Reading stops after an **EOF** or a newline. If a newline is read, it is stored into the buffer. A terminating null byte (aq\0aq) is stored after the last character in the buffer.

fgets() return s on success, and NULL on error or when end of file occurs while no characters have been read.

示例：

```c
#include <stdio.h>
#include <errno.h>
#include <string.h>

#define SIZE 100

int main() {
    char buf[SIZE];
    char *r;
    while (1) {
        r = fgets(buf, SIZE, stdin);
        if (r == NULL) {
            if (ferror(stdin)) {
                printf("null on error: %s\n", strerror(errno));
            } else {
                printf("null when end of file, buf: %s, length: %lu\n", buf, strlen(buf));
            }
            break;
        } else {
            printf("buf: %s, length: %lu\n", buf, strlen(buf));
        }
    };
    return 0;
}
```

运行

```bash
➜  c-study ./cmake-build-debug/c_study < in.txt
buf: abcde, length: 5
null when end of file, buf: abcde, length: 5
```

遗留问题：如何构造`null on error`?

## 参考

- [man getchar](https://linux.die.net/man/3/getchar)
- [What's wrong with this code?](http://www.c-faq.com/stdio/getcharc.html)
- [man fgets](https://linux.die.net/man/3/fgets)