## echo server

```go
package main

import (
	"log"
	"net"
)

func main() {
	addr := ":12345"
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("net Listen err: %+v", err)
	}
	log.Printf("start listen %s", addr)
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatalf("listen Accept err: %+v", err)
		}
		go handleConn(conn)
	}
}

func handleConn(conn net.Conn) {
	log.Printf("a new conn, local addr: %s,remote addr: %s", conn.LocalAddr(), conn.RemoteAddr())
	defer func() {
		if err := conn.Close(); err != nil {
			log.Printf("net Close err: %+v", err)
		}
	}()

	buf := make([]byte, 1024)
	var data []byte
	for {
		n1, err := conn.Read(buf)
		if err != nil {
			log.Printf("conn Read err: %+v", err)
			return
		}
		data = buf[:n1]
		log.Printf("read: %+v, len: %d", data, n1)
		for {
			n2, err := conn.Write(data)
			if err != nil {
				log.Printf("conn Read err: %+v", err)
				return
			}
			log.Printf("write: %+v, len: %d", data[:n2], n2)
			if n2 == len(data) {
				break
			} else {
				log.Printf("write slow, n1: %d, n2: %d", n1, n2)
			}
			data = data[n2:]
		}
	}
}
```

## echo client 1

写完就关闭，会导致read报错：`use of closed network connection`

详细信息：

```bash
$ go run client.go
2021/02/06 22:31:26 write total: 102400000
2021/02/06 22:31:26 conn Read err: read tcp 127.0.0.1:59918->127.0.0.1:12345: use of closed network connection
2021/02/06 22:31:26 read total: 100532224
```

```go
package main

import (
	"log"
	"math/rand"
	"net"
	"sync"
)

func main() {
	conn, err := net.Dial("tcp", ":12345")
	if err != nil {
		log.Fatalf("net Dial err: %+v", err)
	}
	wg := &sync.WaitGroup{}
	wg.Add(2)
	go write(wg, conn)
	go read(wg, conn)
	wg.Wait()
}

func write(wg *sync.WaitGroup, conn net.Conn) {
	defer wg.Done()
	buf := make([]byte, 10240)
	var data []byte
	total := 0
	for i := 0; i < 1e4; i++ {
		n1, err := rand.Read(buf)
		if err != nil {
			log.Fatalf("rand Rand err: %+v", err)
		}
		data = buf[:n1]
		for {
			n2, err := conn.Write(data)
			if err != nil {
				log.Fatalf("conn Write err: %+v", err)
			}
			total += n2
			if n2 == len(data) {
				break
			}
			data = data[:n2]
		}
	}
	log.Printf("write total: %d", total)
	//写完毕之后，强行close
	conn.Close()
}

func read(wg *sync.WaitGroup, conn net.Conn) {
	defer wg.Done()
	buf := make([]byte, 1024)
	total := 0
	for {
		n, err := conn.Read(buf)
		if err != nil {
			log.Printf("conn Read err: %+v", err)
			break
		}
		total += n
	}
	log.Printf("read total: %d", total)
}
```

## echo client 2

半关闭，使用了TCP协议相关的net.TCPConn，使用writeTotal字节数，来判断read何时停止

```bash
$ go run client.go
2021/02/06 22:53:32 write total: 10240
2021/02/06 22:53:32 read total: 10240
```

```golang
package main

import (
	"go.uber.org/atomic"
	"log"
	"math/rand"
	"net"
	"sync"
)

var writeTotal atomic.Int64

func main() {
	conn, err := net.DialTCP("tcp", nil, &net.TCPAddr{IP: net.ParseIP("127.0.0.1"), Port: 12345})
	if err != nil {
		log.Fatalf("net Dial err: %+v", err)
	}
	wg := &sync.WaitGroup{}
	wg.Add(2)
	go write(wg, conn)
	go read(wg, conn)
	wg.Wait()
}

func write(wg *sync.WaitGroup, conn *net.TCPConn) {
	defer wg.Done()
	buf := make([]byte, 10240)
	var data []byte
	writeTotal.Store(0)
	for i := 0; i < 1; i++ {
		n1, err := rand.Read(buf)
		if err != nil {
			log.Fatalf("rand Rand err: %+v", err)
		}
		data = buf[:n1]
		for {
			n2, err := conn.Write(data)
			if err != nil {
				log.Fatalf("conn Write err: %+v", err)
			}
			writeTotal.Add(int64(n2))
			if n2 == len(data) {
				break
			}
			data = data[:n2]
		}
	}
	log.Printf("write total: %d", writeTotal.Load())
	//写完毕之后单向关闭
	conn.CloseWrite()
}

func read(wg *sync.WaitGroup, conn *net.TCPConn) {
	defer wg.Done()
	buf := make([]byte, 1024)
	var total int64 = 0
	for {
		n, err := conn.Read(buf)
		if err != nil {
			log.Printf("conn Read err: %+v", err)
			break
		}
		total += int64(n)
		if total == writeTotal.Load() {
			break
		}
	}
	log.Printf("read total: %d", total)
	conn.CloseRead()
}
```

## 参考

- [Go语言TCP Socket编程](https://tonybai.com/2015/11/17/tcp-programming-in-golang/)