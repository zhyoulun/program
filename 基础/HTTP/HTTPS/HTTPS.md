## 一个简单的http服务

```go
package main

import "net/http"

type myHandler struct {
}

func (h *myHandler) ServeHTTP(r http.ResponseWriter, w *http.Request) {
	r.Write([]byte("hello"))
}

func main() {
	server := &http.Server{
		Addr:    ":12345",
		Handler: &myHandler{},
	}
	server.ListenAndServe()
}
```

运行

```bash
➜  ~ curl "http://127.0.0.1:12345/"
hello
```

## 区分传输层和应用层

```go
package main

import (
	"net"
	"net/http"
)

type myHandler struct {
}

func (h *myHandler) ServeHTTP(r http.ResponseWriter, w *http.Request) {
	r.Write([]byte("hello"))
}

func main() {
	//启动tcp server
	ln, err := net.Listen("tcp", ":12345")
	if err != nil {
		panic(err)
	}

	//启动http server
	server := &http.Server{
		Handler: &myHandler{},
	}
	err = server.Serve(ln)
	if err != nil {
		panic(err)
	}
}
```

## 一个简单的https服务

### 生成一个自签名x509认证

> self-signed X.509 certificate

使用golang tls工具`https://golang.org/src/crypto/tls/generate_cert.go`

```bash
$ go run generate_cert.go --host www.example.com
2020/07/05 14:16:35 wrote cert.pem
2020/07/05 14:16:35 wrote key.pem
```

或者使用openssl

```bash
$ openssl genrsa -out key.pem 2048   
Generating RSA private key, 2048 bit long modulus
...........+++
........................................................+++
e is 65537 (0x10001)

$ openssl req -new -x509 -key key.pem -out cert.pem -days 365
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:
State or Province Name (full name) []:
Locality Name (eg, city) []:
Organization Name (eg, company) []:
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:www.example.com
Email Address []:
```

配置`/etc/hosts`

```
127.0.0.1 www.example.com
```

```go
package main

import "net/http"

type myHandler struct {
}

func (h *myHandler) ServeHTTP(r http.ResponseWriter, w *http.Request) {
	r.Write([]byte("hello"))
}

func main() {
	server := &http.Server{
		Addr:    ":12345",
		Handler: &myHandler{},
	}
	server.ListenAndServeTLS("/tmp/server/cert.pem", "/tmp/server/key.pem")
}
```

运行程序并使用浏览器访问`https://www.example.com:12345/`

```bash
$ go run https001.go                            
2020/07/05 14:40:14 http: TLS handshake error from 127.0.0.1:51878: remote error: tls: unknown certificate
2020/07/05 14:40:14 http: TLS handshake error from 127.0.0.1:51877: remote error: tls: unknown certificate
2020/07/05 14:40:14 http: TLS handshake error from 127.0.0.1:51879: remote error: tls: unknown certificate
```

![](/static/images/2007/p005.jpg)

使用`curl`访问

```bash
➜  ~ curl "https://www.example.com:12345/"
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

# 忽略证书校验
➜  ~ curl -k "https://www.example.com:12345/"
hello
```

## 区分传输层、会话层、应用层

```go
package main

import (
	"crypto/tls"
	"net"
	"net/http"
)

type myHandler struct {
}

func (h *myHandler) ServeHTTP(r http.ResponseWriter, w *http.Request) {
	r.Write([]byte("hello"))
}

func InitTLSConfig() (*tls.Config, error) {
	var err error

	certificates := make([]tls.Certificate, 1)
	certificates[0], err = tls.LoadX509KeyPair("/tmp/server/cert.pem", "/tmp/server/key.pem")
	if err != nil {
		return nil, err
	}

	nextProtos := make([]string, 1)
	nextProtos[0] = "http/1.1"

	return &tls.Config{
		Certificates: certificates,
		NextProtos:   nextProtos,
	}, nil
}

func main() {
	//启动tcp server
	ln, err := net.Listen("tcp", ":12345")
	if err != nil {
		panic(err)
	}

	//启动tls server
	tlsConfig, err := InitTLSConfig()
	if err != nil {
		panic(err)
	}
	tlsListener := tls.NewListener(ln, tlsConfig)

	//启动http server
	server := &http.Server{
		Handler: &myHandler{},
	}
	err = server.Serve(tlsListener)
	if err != nil {
		panic(err)
	}
}
```

## 客户端使用ca.crt校验服务端

- 服务端得使用443端口，原因待确定

客户端代码

```go
package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	caCrt, err := ioutil.ReadFile("/tmp/server/ca.crt")
	if err != nil {
		panic(err)
	}

	pool := x509.NewCertPool()
	pool.AppendCertsFromPEM(caCrt)

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs: pool,
			},
		},
	}

	//req, err := http.NewRequest("GET", "https://127.0.0.1", nil)
	//if err != nil {
	//	panic(err)
	//}
	//req.Header.Set("Host", "www.example.com")
	//resp, err := client.Do(req)
	resp, err := client.Get("https://www.example.com")
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	s, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(s))
}
```

运行

```bash
$ go run https002.go
hello
```

## 使用curl访问

> 不太理解这里生成的cacrt.pem和上边用到的ca.crt是什么关系

```bash
echo quit | openssl s_client -showcerts -servername www.example.com -connect www.example.com:443 > cacrt.pem
```

```
$ curl -i --cacert cacrt.pem "https://www.example.com"
HTTP/1.1 200 OK
Date: Sun, 05 Jul 2020 09:43:07 GMT
Content-Length: 5
Content-Type: text/plain; charset=utf-8

hello




$ curl -i "https://www.example.com"
curl: (60) SSL certificate problem: self signed certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```



## 参考

- [Go和HTTPS](https://tonybai.com/2015/04/30/go-and-https/)
- [使用Go实现TLS 服务器和客户端](https://colobu.com/2016/06/07/simple-golang-tls-examples/)
- [Use self signed certificate with cURL?](https://stackoverflow.com/questions/27611193/use-self-signed-certificate-with-curl)