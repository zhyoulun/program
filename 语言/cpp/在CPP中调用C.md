## 解决在CPP调用C的问题

### add.h, add.c

add.h

```c
//
// Created by zhangyoulun on 2021/4/20.
//

#ifndef CPP001_ADD_H
#define CPP001_ADD_H

int add(int a, int b);

#endif //CPP001_ADD_H
```

add.c

```c
//
// Created by zhangyoulun on 2021/4/20.
//

#include "add.h"

int add(int a, int b) {
    return a + b;
}
```

### main.cpp

```cpp
#include <iostream>
#include "add.h"

int main() {
    std::cout << add(1, 2) << std::endl;
    return 0;
}
```

如果直接运行，会有如下报错

```
Undefined symbols for architecture x86_64:
  "add(int, int)", referenced from:
      _main in main.cpp.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[3]: *** [cpp001] Error 1
make[2]: *** [CMakeFiles/cpp001.dir/all] Error 2
make[1]: *** [CMakeFiles/cpp001.dir/rule] Error 2
make: *** [cpp001] Error 2
```

调整include add.h的位置

```
#include <iostream>

extern "C" {
#include "add.h"
}

int main() {
    std::cout << add(1, 2) << std::endl;
    return 0;
}
```

可以正常运行

其中`extern "C"`表示需要编译器进行C方式编译的部分。

## 通用化，实现同一段代可以使用C、C++编译器编译

- `__cplusplus`关键字是C++编译器内置的标准宏定义
- 使用__cplusplus来判定是否需要将  extern "C"{}加入到编译中来

修改add.h文件

```c
//
// Created by zhangyoulun on 2021/4/20.
//

#ifndef CPP001_ADD_H
#define CPP001_ADD_H

#ifdef __cplusplus
extern "C" {
#endif

int add(int a, int b);

#ifdef __cplusplus
}
#endif

#endif //CPP001_ADD_H
```

## 参考

- [C++ 调用C语言、extern "C"、__cplusplus关键字](https://www.cnblogs.com/hjxzjp/p/11605258.html)
