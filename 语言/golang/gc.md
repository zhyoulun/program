## SetGCPercent

```go
func SetGCPercent(percent int) int
```

Go垃圾回收为了保证使用的简洁性，只提供了一个参数GOGC。GOGC代表了占用中的内存增长比率，达到该比率时应当触发1次GC，该参数可以通过环境变量设置。

GOGC参数取值范围为0~100，默认值是100，单位是百分比。

假如当前heap占用内存为4MB，GOGC = 75，`4 * (1+75%) = 7MB`，等heap占用内存大小达到7MB时会触发1轮GC。

GOGC还有2个特殊值：

- “off”: 代表关闭GC（-1等价于off）
- 0 : 代表持续进行垃圾回收，只用于调试

```bash
func readgogc() int32 {
	p := gogetenv("GOGC")
	if p == "off" {
		return -1
	}
	if n, ok := atoi32(p); ok {
		return n
	}
	return 100
}
```

代码示例

```go
package main

import (
	"fmt"
	"os"
	"runtime/debug"
)

func main() {
	fmt.Println(os.Getenv("GOGC"))
	fmt.Println(debug.SetGCPercent(25))
}
```

运行

```bash
$ GOGC=50 go run study/gc/gc001/gc001.go
50
50
```

## 控制gc

- SetGCPercent(-1)：关闭GC，返回关闭GC前的GOGC参数
- defer debug.SetGCPercent(debug.SetGCPercent(-1))：函数运行完毕后，恢复GOGC参数
- Runtime_procPin, Runtime_procUnpin：保证本协程在运行期间，不移动到其它P(processor)上
- runtime.GC()：手动运行一次gc

```go
func TestPool(t *testing.T) {
	// disable GC so we can control when it happens.
	defer debug.SetGCPercent(debug.SetGCPercent(-1))
	var p Pool
	if p.Get() != nil {
		t.Fatal("expected empty")
	}

	// Make sure that the goroutine doesn't migrate to another P
	// between Put and Get calls.
	Runtime_procPin()
	p.Put("a")
	p.Put("b")
	if g := p.Get(); g != "a" {
		t.Fatalf("got %#v; want a", g)
	}
	if g := p.Get(); g != "b" {
		t.Fatalf("got %#v; want b", g)
	}
	if g := p.Get(); g != nil {
		t.Fatalf("got %#v; want nil", g)
	}
	Runtime_procUnpin()

	// Put in a large number of objects so they spill into
	// stealable space.
	for i := 0; i < 100; i++ {
		p.Put("c")
	}
	// After one GC, the victim cache should keep them alive.
	runtime.GC()
	if g := p.Get(); g != "c" {
		t.Fatalf("got %#v; want c after GC", g)
	}
	// A second GC should drop the victim cache.
	runtime.GC()
	if g := p.Get(); g != nil {
		t.Fatalf("got %#v; want nil after second GC", g)
	}
}
```

### victim cache

Pool GC策略：

为了优化 GC 后 Pool 为空导致的冷启动性能抖动，相比较于go1.12版本，go1.13版本中增加了victim cache。具体作法是：

- GC处理过程直接回收oldPools的对象
- GC处理并不直接将allPools的object直接进行GC处理，而是保存到oldPools，等到下一个GC周期到了再处理

增加了 victim cache, 用来保存上一次 GC 本应被销毁的对象，也就是说，对象至少存活两次 GC 间隔。

这样可导致Pool.Get的实现有变化，原来的实现是

1. 先从本P绑定的poolLocal获取对象：先从本poolLocal的private池获取对象，再从本poolLocal的shared池获取对象
2. 上一步没有成功获取对象，再从其他P的shared池获取对象
3. 上一步没有成功获取对象，则从Heap申请对象

引入victim cache，Get实现变成如下：

1. 先从本P绑定的poolLocal获取对象：先从本poolLocal的private池获取对象，再从本poolLocal的shared池获取对象
2. 上一步没有成功获取对象，再从其他P的shared池获取对象
3. **上一步没有成功，则从victim cache获取对象**
4. 上一步没有成功获取对象，则从Heap申请对象

好处

1. 空间上通过引入victim cache增加了Get获取内存的选项，增加了对象复用的概率
2. 时间上通过延迟GC，增加了对象复用的时间长度
3. 上面这个两个方面降低了GC开销，增加了对象使用效率

## 参考

- [https://golang.org/pkg/runtime/debug/#SetGCPercent](https://golang.org/pkg/runtime/debug/#SetGCPercent)
- [GC调节参数](https://www.bookstack.cn/read/For-learning-Go-Tutorial/spilt.10.src-spec-02.0.md)
- [深入分析Golang sync.pool优化](https://zhuanlan.zhihu.com/p/91604275)
- [GO: sync.Pool 的实现与演进](https://www.jianshu.com/p/2e08332481c5)