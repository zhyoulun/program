RTTI是Runtime Type Information的缩写，运行时类型信息

## typeid使用方法

```cpp
#include <iostream>

using namespace std;

class Student {
private:
    char name[20];
    int age;
};

int main() {
    int a = 1;
    short b = 2;
    unsigned c = 3;
    Student d{};
    Student *e = new Student;
    char f;
    double g;
    float h;
    cout << typeid(a).name() << endl;
    cout << typeid(b).name() << endl;
    cout << typeid(c).name() << endl;
    cout << typeid(d).name() << endl;
    cout << typeid(e).name() << endl;
    cout << typeid(f).name() << endl;
    cout << typeid(g).name() << endl;
    cout << typeid(h).name() << endl;
}
```

运行输出

```
i
s
j
7Student
P7Student
c
d
f
```

```cpp
#include <iostream>

using namespace std;

class People {
public:
    void print() {
        cout << "people print" << endl;
    }
};

class Student : public People {
public:
    void print() {
        cout << "student print" << endl;
    }
};

int main() {
    People *p = new Student;
    cout << typeid(*p).name() << endl;
    cout << typeid(p).name() << endl;
}
```

运行输出

```
6People
P6People
```

增加virtual

```cpp
#include <iostream>

using namespace std;

class People {
public:
    virtual void print() {
        cout << "people print" << endl;
    }
};

class Student : public People {
public:
    void print() {
        cout << "student print" << endl;
    }
};

int main() {
    People *p = new Student;
    cout << typeid(*p).name() << endl;
    cout << typeid(p).name() << endl;
}
```

运行

```
7Student
P6People
```

1. 这就是RTTI在捣鬼了，当类中不存在虚函数时，typeid是编译时期的事情，也就是静态类型，就如上面的`cout<<typeid(*p).name()<<endl;`输出`6People`一样；
2. 当类中存在虚函数时，typeid是运行时期的事情，也就是动态类型，就如上面的`cout<<typeid(*p).name()<<endl;`输出`7Student`一样，关于这一点，我们在实际编程中，经常会出错，一定要谨记。
3. 这个真的很重要 一定要多看看 一个类里面有virutal 和没有virtual 对于编译器来说，做的事完全不同的事情，所有一定要看清楚这个类有没有virtual



## 参考

- [C++中的RTTI机制](https://www.jianshu.com/p/3b4a80adffa7)