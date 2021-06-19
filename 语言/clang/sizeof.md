## 知识点

- sizeof isn't a function. it's an operator
- sizeof是C语言的内置运算符，以字节为单位给出指定类型的大小

## 代码示例

```c
#include <stdio.h>

int main() {
    printf("sizeof('a')=%lu\n", sizeof('a'));//sizeof('a')=4
    printf("sizeof((char)'a')=%lu\n", sizeof((char) 'a'));//sizeof((char)'a')=1
    printf("sizeof(123)=%lu\n", sizeof(123));//等价于sizeof(int),sizeof(123)=4
    printf("sizeof(int)=%lu\n", sizeof(int));//sizeof(int)=4

    char ch = 'a';
    printf("sizeof(ch)=%lu\n", sizeof(ch));//sizeof(ch)=1

    char *str1 = "abcdefghijklmn";
    //The first case has the type char*
    printf("sizeof(*str1)=%lu\n", sizeof(*str1));//sizeof(*str1)=1
    printf("sizeof(str1)=%lu\n", sizeof(str1));//sizeof(str1)=8

    char str2[] = "abcdefghijklmn";
    //aggregate type char[]
    printf("sizeof(str2[])=%lu\n", sizeof(str2));//sizeof(str2)=15

    char str3[] = "abcd\0efg";
    printf("sizeof(str3[])=%lu\n", sizeof(str3));//sizeof(str3[])=9

    return 0;
}
```


## 参考

- [Where's the man page for the sizeof C function?](https://superuser.com/questions/753163/wheres-the-man-page-for-the-sizeof-c-function)
- C primer plus
- [bugprone-sizeof-expression](https://clang.llvm.org/extra/clang-tidy/checks/bugprone-sizeof-expression.html)