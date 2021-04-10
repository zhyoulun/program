### 使用context.WithCanel()

子函数work()所在的协程先执行完

```go
package main

import (
	"context"
	"log"
	"time"
)

func work(ctx context.Context) {
	select {
	case <-ctx.Done():
		log.Printf("work func, ctx.Done, err: %+v\n", ctx.Err())
	case <-time.After(1 * time.Second):
		log.Printf("work success\n")
	}
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	go work(ctx)

	time.Sleep(2 * time.Second)
	cancel()

	log.Printf("main func, ctx err: %+v\n", ctx.Err())
	time.Sleep(time.Second)
}
```

```
2021/04/04 20:55:23 work success
2021/04/04 20:55:24 main func, ctx err: context canceled
```

main()函数所在的协程先执行完

```go
package main

import (
	"context"
	"log"
	"time"
)

func work(ctx context.Context) {
	select {
	case <-ctx.Done():
		log.Printf("work func, ctx.Done, err: %+v\n", ctx.Err())
	case <-time.After(3 * time.Second):
		log.Printf("work success\n")
	}
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	go work(ctx)

	time.Sleep(2 * time.Second)
	cancel()

	log.Printf("main func, ctx err: %+v\n", ctx.Err())
	time.Sleep(time.Second)
}
```

```
2021/04/04 20:56:34 main func, ctx err: context canceled
2021/04/04 20:56:34 work func, ctx.Done, err: context canceled
```

### context.WithTimeout && context.WithDeadline

两个函数的关系

```go
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc) {
	return WithDeadline(parent, time.Now().Add(timeout))
}
```

子函数work()所在的协程先执行完

```go
package main

import (
	"context"
	"log"
	"time"
)

func work(ctx context.Context) {
	select {
	case <-ctx.Done():
		log.Printf("work func, ctx.Done, err: %+v\n", ctx.Err())
	case <-time.After(1 * time.Second):
		log.Printf("work success\n")
	}
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	go work(ctx)

	select {
	case <-ctx.Done():
		log.Printf("main func, ctx Done, err: %+v\n", ctx.Err())
	}

	time.Sleep(time.Second)
}
```

```
2021/04/04 20:59:26 work success
2021/04/04 20:59:27 main func, ctx Done, err: context deadline exceeded
```

main()函数所在的协程先执行完

```go
package main

import (
	"context"
	"log"
	"time"
)

func work(ctx context.Context) {
	select {
	case <-ctx.Done():
		log.Printf("work func, ctx.Done, err: %+v\n", ctx.Err())
	case <-time.After(3 * time.Second):
		log.Printf("work success\n")
	}
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	go work(ctx)

	select {
	case <-ctx.Done():
		log.Printf("main func, ctx Done, err: %+v\n", ctx.Err())
	}

	time.Sleep(time.Second)
}
```

```
2021/04/04 21:00:18 main func, ctx Done, err: context deadline exceeded
2021/04/04 21:00:18 work func, ctx.Done, err: context deadline exceeded
```

### context.WithValue

```go
package main

import (
	"context"
	"fmt"
)

func main() {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "a", 1)
	fmt.Println(ctx.Value("a"))
}
```

运行内容为1

## 参考

- [6.1 上下文 Context](https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-context/)