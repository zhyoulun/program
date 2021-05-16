如何能让client端实现对Server端证书的校验呢？

client端校验证书的原理是什么呢？回想前面我们提到的浏览器内置了知名CA的相关信息，用来校验服务端发送过来的数字证书。那么浏览器 存储的到底是CA的什么信息呢？其实是CA自身的数字证书(包含CA自己的公钥)。而且为了保证CA证书的真实性，浏览器是在出厂时就内置了 这些CA证书的，而不是后期通过通信的方式获取的。CA证书就是用来校验由该CA颁发的数字证书的。

那么如何使用CA证书校验Server证书的呢？这就涉及到数字证书到底是什么了！

我们可以通过浏览器中的"https/ssl证书管理"来查看证书的内容，一般服务器证书都会包含诸如站点的名称和主机名、公钥、签发机构 (CA)名称和来自签发机构的签名等。我们重点关注这个来自签发机构的签名，因为对于证书的校验，就是使用客户端CA证书来验证服务端证书的签名是否这 个CA签的。

通过签名验证我们可以来确认两件事：

1. 服务端传来的数字证书是由某个特定CA签发的（如果是self-signed，也无妨），数字证书中的签名类似于日常生活中的签名，首先 验证这个签名签的是Tony Bai，而不是Tom Bai， Tony Blair等。
2. 服务端传来的数字证书没有被中途篡改过。这类似于"Tony Bai"有无数种写法，这里验证必须是我自己的那种写法，而不是张三、李四写的"Tony Bai"。

一旦签名验证通过，我们因为信任这个CA，从而信任这个服务端证书。由此也可以看出，CA机构的最大资本就是其信用度。

CA在为客户签发数字证书时是这样在证书上签名的：

数字证书由两部分组成：
1. C：证书相关信息（对象名称+过期时间+证书发布者+证书签名算法….）
2. S：证书的数字签名

其中的数字签名是通过公式S = F(Digest(C))得到的。

Digest为摘要函数，也就是 md5、sha-1或sha256等单向散列算法，用于将无限输入值转换为一个有限长度的“浓缩”输出值。比如我们常用md5值来验证下载的大文件是否完 整。大文件的内容就是一个无限输入。大文件被放在网站上用于下载时，网站会对大文件做一次md5计算，得出一个128bit的值作为大文件的 摘要一同放在网站上。用户在下载文件后，对下载后的文件再进行一次本地的md5计算，用得出的值与网站上的md5值进行比较，如果一致，则大 文件下载完好，否则下载过程大文件内容有损坏或源文件被篡改。

F为签名函数。CA自己的私钥是唯一标识CA签名的，因此CA用于生成数字证书的签名函数一定要以自己的私钥作为一个输入参数。在RSA加密 系统中，发送端的解密函数就是一个以私钥作 为参数的函数，因此常常被用作签名函数使用。签名算法是与证书一并发送给接收 端的，比如apple的一个服务的证书中关于签名算法的描述是“带 RSA 加密的 SHA-256 ( 1.2.840.113549.1.1.11 )”。因此CA用私钥解密函数作为F，对C的摘要进行运算得到了客户数字证书的签名，好比大学毕业证上的校长签名，所有毕业证都是校长签发的。

接收端接收服务端数字证书后，如何验证数字证书上携带的签名是这个CA的签名呢？接收端会运用下面算法对数字证书的签名进行校验：
F'(S) ?= Digest(C)

接收端进行两个计算，并将计算结果进行比对：
1、首先通过Digest(C)，接收端计算出证书内容（除签名之外）的摘要。
2、数字证书携带的签名是CA通过CA密钥加密摘要后的结果，因此接收端通过一个解密函数F'对S进行“解密”。RSA系统中，接收端使用 CA公钥对S进行“解密”，这恰是CA用私钥对S进行“加密”的逆过程。

将上述两个运算的结果进行比较，如果一致，说明签名的确属于该CA，该证书有效，否则要么证书不是该CA的，要么就是中途被人篡改了。

但对于self-signed(自签发)证书来说，接收端并没有你这个self-CA的数字证书，也就是没有CA公钥，也就没有办法对数字证 书的签名进行验证。因此如果要编写一个可以对self-signed证书进行校验的接收端程序的话，首先我们要做的就是建立一个属于自己的 CA，用该CA签发我们的server端证书，并将该CA自身的数字证书随客户端一并发布。

```
(1)openssl genrsa -out rootCA.key 2048
(2)openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=*.tunnel.tonybai.com" -days 5000 -out rootCA.pem

(3)openssl genrsa -out device.key 2048
(4)openssl req -new -key device.key -subj "/CN=*.tunnel.tonybai.com" -out device.csr
(5)openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

(6)cp rootCA.pem assets/client/tls/ngrokroot.crt
(7)cp device.crt assets/server/tls/snakeoil.crt
(8)cp device.key assets/server/tls/snakeoil.key
```

```
客户端要验证服务端证书，我们需要自己做CA，因此步骤(1)和步骤(2)就是生成CA自己的相关信息。
步骤(1) ，生成CA自己的私钥 rootCA.key
步骤(2)，根据CA自己的私钥生成自签发的数字证书，该证书里包含CA自己的公钥。

步骤(3)~(5)是用来生成ngrok服务端的私钥和数字证书（由自CA签发）。
步骤(3)，生成ngrok服务端私钥。
步骤(4)，生成Certificate Sign Request，CSR，证书签名请求。
步骤(5)，自CA用自己的CA私钥对服务端提交的csr进行签名处理，得到服务端的数字证书device.crt。

步骤(6)，将自CA的数字证书同客户端一并发布，用于客户端对服务端的数字证书进行校验。
步骤(7)和步骤(8)，将服务端的数字证书和私钥同服务端一并发布。
```


示例：

```bash
$ openssl genrsa -out ca.key 2048
Generating RSA private key, 2048 bit long modulus
.............................................+++
.............................................................................+++
e is 65537 (0x10001)


$ openssl req -x509 -new -nodes -key ca.key -days 365 -out ca.crt 
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



$ ls
ca.crt ca.key
```


```bash
$ openssl genrsa -out server.key 2048
Generating RSA private key, 2048 bit long modulus
.................................................+++
...+++
e is 65537 (0x10001)


$ openssl req -new -key server.key -out server.csr
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

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:


$ ls
ca.crt     ca.key     server.csr server.key


$ openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 
Signature ok
subject=/CN=www.example.com
Getting CA Private Key

$ ls
ca.crt     ca.key     ca.srl     server.crt server.csr server.key
```

## 参考

- [Go和HTTPS](https://tonybai.com/2015/04/30/go-and-https/)
