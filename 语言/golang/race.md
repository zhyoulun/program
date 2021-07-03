Go 1.1引入竞态探测器，一个用于在Go代码中查找 Race conditions 的新工具。 它基于 C/C++ ThreadSanitizer运行库 ，此库被用于检测Google内部代码库和Chromium中的许多错误。 该技术于2012年9月与Go集成; 此后，它已经应用到了标准库中。 它现在已经成为持续建设过程的一部分，在这些过程中，它们会随着时间的推移而捕捉到产生的 Race conditions 。

## 工作原理

竞态探测器集成在go工具链中。 当设置了-race命令行标志时，编译器将使用访问内存的时间和方式的代码记录下来,用于设置所有内存访问， 而运行时库会监视对共享变量的不同步访问。 当检测到这种“racy”行为时，会打印一个警告。

由于其设计，竞态探测器只能在运行代码实际触发时才能检测到竞争条件，这意味着需要在真实的工作负载下运行启用探测器。 然而，启用竞态探测的可执行文件可能使用十倍的CPU和内存，因此始终启用探测器是不切实际的。 出于这个困境的一个办法是在启用竞态探测的情况下运行一些测试。 负载测试和集成测试是很好的候选者，因为它们往往会执行代码的并发部分。 另外的可选途径：生产工作负载环境中, 在运行的服务器池中, 部署单个启用竞态探测的实例。

## 使用方法

竞态探测器与Go工具链完全集成。 要启用竞态检测器的情况下,构建代码，只需将 -race 标志添加到命令行：

```
go test -race mypkg    // test the package
go run -race mysrc.go  // compile and run the program
go build -race mycmd   // build the command
go install -race mypkg // install the package
```

## 示例

`race001.go`

```go
package main

import (
	"fmt"
	"sync"
)

var a = 1

func main() {
	wg := &sync.WaitGroup{}
	for i := 0; i < 1e5; i++ {
		wg.Add(1)
		go add(wg)
	}
	wg.Wait()
	fmt.Println(a)
}

func add(wg *sync.WaitGroup) {
	a += 1
	wg.Done()
}
```

```bash
go run -race study/race/race001/race001.go
==================
WARNING: DATA RACE
Read at 0x0000011e55b0 by goroutine 8:
  main.add()
      /Users/zhangyoulun/codes/github/go/study/race/race001/race001.go:21 +0x3e

Previous write at 0x0000011e55b0 by goroutine 7:
  main.add()
      /Users/zhangyoulun/codes/github/go/study/race/race001/race001.go:21 +0x5a

Goroutine 8 (running) created at:
  main.main()
      /Users/zhangyoulun/codes/github/go/study/race/race001/race001.go:14 +0xab

Goroutine 7 (finished) created at:
  main.main()
      /Users/zhangyoulun/codes/github/go/study/race/race001/race001.go:14 +0xab
==================
99936
Found 1 data race(s)
exit status 66
```


## 参考

- [Go的竞态探测器](https://brantou.github.io/2017/05/23/go-race-detector/)