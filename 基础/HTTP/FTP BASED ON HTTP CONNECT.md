## 启动ftp server

安装pyftpdlib

```
pip install pyftpdlib
```

启动ftp server，`python ftp_server.py`，`ftp_server.py`内容如下：

- server: 127.0.0.1
- port: 2121
- 用户名:user
- 密码:12345

```python
import os

from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer


def main():
    # Instantiate a dummy authorizer for managing 'virtual' users
    authorizer = DummyAuthorizer()

    # Define a new user having full r/w permissions and a read-only
    # anonymous user
    authorizer.add_user('user', '12345', '/Users/zhangyoulun/temp', perm='elradfmwMT')
    authorizer.add_anonymous(os.getcwd())

    # Instantiate FTP handler class
    handler = FTPHandler
    handler.authorizer = authorizer

    # Define a customized banner (string returned when client connects)
    handler.banner = "pyftpdlib based ftpd ready."

    # Specify a masquerade address and the range of ports to use for
    # passive connections.  Decomment in case you're behind a NAT.
    #handler.masquerade_address = '151.25.42.11'
    #handler.passive_ports = range(60000, 65535)

    # Instantiate FTP server class and listen on 0.0.0.0:2121
    address = ('', 2121)
    server = FTPServer(address, handler)

    # set a limit for connections
    server.max_cons = 256
    server.max_cons_per_ip = 5

    # start ftp server
    server.serve_forever()


if __name__ == '__main__':
    main()
```

使用FileZilla测试

![](/static/images/2102/p003.png)

![](/static/images/2102/p004.png)

## go程序

- ftp client sdk: [https://github.com/jlaffaye/ftp](https://github.com/jlaffaye/ftp)

直接访问





## 参考

- [https://github.com/giampaolo/pyftpdlib](https://github.com/giampaolo/pyftpdlib)
- [https://filezilla-project.org/](https://filezilla-project.org/)
- [https://github.com/jlaffaye/ftp](https://github.com/jlaffaye/ftp)
- [HTTP 代理原理及实现（一）](https://imququ.com/post/web-proxy.html)
- 《HTTP 权威指南》一书中第六章「代理」；第二种代理，对应第八章「集成点：网关、隧道及中继」中的 8.5 小节「隧道」。