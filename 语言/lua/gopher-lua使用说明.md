## 使用示例

### hello world

```go
package main

import lua "github.com/yuin/gopher-lua"

const luaScript = `
print("hello")
`

func main() {
	L := lua.NewState()
	defer L.Close()
	if err := L.DoString(luaScript); err != nil {
		panic(err)
	}
}
```

或者也可以使用文件的方式执行，`hello.lua`文件的内容是`print("hello")`

```go
package main

import lua "github.com/yuin/gopher-lua"

func main() {
	L := lua.NewState()
	defer L.Close()
	if err := L.DoFile("/Users/zhangyoulun/temp/hello.lua"); err != nil {
		panic(err)
	}
}
```

### 在lua中调用golang函数

```go
package main

import (
	lua "github.com/yuin/gopher-lua"
)

const luaScript = `
print(double(20))
print(add(1,2))
`

func Double(L *lua.LState) int {
	lv := L.ToInt(1)            //get argument
	L.Push(lua.LNumber(lv * 2)) //push result
	return 1                    //number of results
}

func Add(L *lua.LState) int {
	lv1 := L.ToInt(1)
	lv2 := L.ToInt(2)
	L.Push(lua.LNumber(lv1 + lv2))
	return 1
}

func main() {
	L := lua.NewState()
	defer L.Close()
	L.SetGlobal("double", L.NewFunction(Double))
	L.SetGlobal("add", L.NewFunction(Add))
	if err := L.DoString(luaScript); err != nil {
		panic(err)
	}
}
```

运行结果

```
40
3
```

### 在lua中调用golang的sleep

```go
package main

import (
	lua "github.com/yuin/gopher-lua"
	"time"
)

const luaScript = `
print(os.date("%Y-%m-%d %H:%M:%S"))
sleep_ms(1000)
print(os.date("%Y-%m-%d %H:%M:%S"))
`

func SleepMS(L *lua.LState) int {
	lv := L.ToInt64(1)
	time.Sleep(time.Duration(lv) * time.Millisecond)
	return 0
}

func main() {
	L := lua.NewState()
	defer L.Close()
	L.SetGlobal("sleep_ms", L.NewFunction(SleepMS))
	if err := L.DoString(luaScript); err != nil {
		panic(err)
	}
}
```

### lua+golang协程

```go
package main

import (
	lua "github.com/yuin/gopher-lua"
	"time"
)

func receiver(ch, quit chan lua.LValue) {
	L := lua.NewState()
	defer L.Close()
	L.SetGlobal("ch", lua.LChannel(ch))
	L.SetGlobal("quit", lua.LChannel(quit))
	if err := L.DoString(`
    local exit = false
    while not exit do
      channel.select(
        {"|<-", ch, function(ok, v)
          if not ok then
            print("channel closed")
            exit = true
          else
            print("received:", v)
          end
        end},
        {"|<-", quit, function(ok, v)
            print("quit")
            exit = true
        end}
      )
    end
  `); err != nil {
		panic(err)
	}
}

func sender(ch, quit chan lua.LValue) {
	L := lua.NewState()
	defer L.Close()
	L.SetGlobal("ch", lua.LChannel(ch))
	L.SetGlobal("quit", lua.LChannel(quit))
	if err := L.DoString(`
    ch:send("1")
    ch:send("2")
  `); err != nil {
		panic(err)
	}
	ch <- lua.LString("3")
	quit <- lua.LTrue
}

func main() {
	ch := make(chan lua.LValue)
	quit := make(chan lua.LValue)
	go receiver(ch, quit)
	go sender(ch, quit)
	time.Sleep(3 * time.Second)
}
```

运行

```
received:       1
received:       2
received:       3
quit
```

## 参考

- https://github.com/yuin/gopher-lua
- https://pkg.go.dev/github.com/yuin/gopher-lua
- [lua manual 5.1](http://www.lua.org/manual/5.1/)
