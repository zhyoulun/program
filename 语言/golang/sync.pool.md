## 基本概念

- GC 的问题：项目中大量重复地创建许多对象，造成 GC 的工作量巨大，CPU 频繁掉底。
- 使用 sync.Pool 来缓存对象，减轻 GC 的消耗
- sync.Pool 是 sync 包下的一个组件，可以作为保存临时取还对象的一个“池子”。
- sync.Pool 是协程安全的，这对于使用者来说是极其方便的。
- 使用前，设置好对象的 New 函数，用于在 Pool 里没有缓存的对象时，创建一个
- 之后，在程序的任何地方、任何时候仅通过 Get()、Put() 方法就可以取、还对象了
- 因此关键思想就是对象的复用，避免重复创建、销毁

## 例子

```go
package main

import (
	"fmt"
	"sync"
)

var pool *sync.Pool

type Person struct {
	Name string
}

func main() {
	pool = &sync.Pool{
		New: func() interface{} {
			fmt.Println("申请一个新的对象")
			return new(Person)
		},
	}

	p := pool.Get().(*Person)
	fmt.Println("首次从 pool 里获取：", p)

	p.Name = "xxx"
	fmt.Printf("设置 p.Name = %s\n", p.Name)

	pool.Put(p)

	fmt.Println("Pool 里已有一个对象：&{xxx}，调用 Get: ", pool.Get().(*Person))
	fmt.Println("Pool 没有对象了，调用 Get: ", pool.Get().(*Person))
}
```

```
申请一个新的对象
首次从 pool 里获取： &{}
设置 p.Name = xxx
Pool 里已有一个对象：&{xxx}，调用 Get:  &{xxx}
申请一个新的对象
Pool 没有对象了，调用 Get:  &{}
```




## 参考

- [深度解密 Go 语言之 sync.Pool](https://www.cnblogs.com/qcrao-2018/p/12736031.html)