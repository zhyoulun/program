## 为什么需要反射

```go
package main

import (
	"fmt"
	"strconv"
)

func Sprint(x interface{}) string {
	type stringer interface {
		String() string
	}
	switch x := x.(type) {
	case stringer:
		return x.String()
	case string:
		return x
	case int:
		return strconv.Itoa(x)
	case bool:
		if x {
			return "true"
		} else {
			return "false"
		}
	default:
		return "???"
	}
}

func main() {
	fmt.Println(Sprint("abc"))
	fmt.Println(Sprint(123))
	fmt.Println(Sprint(true))
	fmt.Println(Sprint([]string{"abc"}))
}
```

运行结果

```
abc
123
true
???
```

使用switch类型分支来测试输入参数：

- 只能涵盖基本类型，无法进一步涵盖符合类型，例如[]float64等
- 无法区分url.Values和map[string][]string

## reflect.Type和reflect.Value

- reflect.Type表示一个Go类型，它是一个接口
  - 唯一能反应reflect.Type实现的是接口的类型描述信息，也正是这个实体标识了接口值的动态类型
  - 函数reflect.TypeOf接收任意的interfare{}类型，并以reflect.Type形式返回其动态类型
  - `reflect.TypeOf(3)`，将一个具体的值3传递给interface{}参数，即将一个具体的值转换给接口类型，会有一个隐式接口转换操作，它会创建一个包含两个信息的接口值：操作数的动态类型（这里是int），以及动态值（这里是3）
  - reflect.TypeOf返回的是一个动态类型的接口值，它总是返回具体的类型。`var w io.Writer=os.Stdout;reflect.TypeOf(w)`这里返回的是`*os.File`而不是`io.Writer`
  - `fmt.Printf("%T", 3)`会调用reflect.TypeOf输出`int`
- reflect.Value可以装载任意类型的值
  - 函数reflect.ValueOf接受任意类型的interface{}类型，并返回一个装载着其动态值的reflect.Value
  - `fmt.Printf("%v", v)`？？
  - reflect.ValueOf的逆操作是reflect.Value.Interface{}，它返回一个interface{}类型，装载着与reflect.Value相同的具体值
  - reflect.Value和interface{}都能装载任意的值；所不同的是，一个空的接口隐藏了值内部的表示方式和所有方法，因此只有我们知道具体的动态类型才能使用类型断言来访问内部的值；相比之下，一个Value则有很多方法来检测其内容，无论它的具体内容是什么

```go
package main

import "fmt"

func main() {
	var a interface{}
	switch a1 := a.(type) {
	case string:
		fmt.Println("a1 is string,", a1)
	default:
		fmt.Println("a1 is not string,", a1)
	}

	var b = "abc"
	a = b
	switch a2 := a.(type) {
	case string:
		fmt.Println("a2 is string,", a2)
	default:
		fmt.Println("a2 is not string,", a2)
	}

	a = nil
	switch a3 := a.(type) {
	case string:
		fmt.Println("a3 is string,", a3)
	default:
		fmt.Println("a3 is not string,", a3)
	}
}
```

运行结果

```
//一个空的接口隐藏了值内部的表示方式和所有方法，因此只有我们知道具体的动态类型才能使用类型断言来访问内部的值
a1 is not string, <nil>
a2 is string, abc
a3 is not string, <nil>
```

```go
package main

import (
	"fmt"
	"net/http"
	"net/url"
	"reflect"
)

func main() {
	var a = 1
	fmt.Println(reflect.ValueOf(a).Kind()) //int
	var b interface{}
	fmt.Println(reflect.ValueOf(b).Kind()) //invalid
	var c url.Values
	fmt.Println(reflect.ValueOf(c).Kind()) //map
	var d *http.Client
	fmt.Println(reflect.ValueOf(d).Kind()) //ptr
}
```

## 参考

- [4.3 反射](https://draveness.me/golang/docs/part2-foundation/ch04-basic/golang-reflect/)
- Go程序设计语言，Alan