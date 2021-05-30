> 这里演示的是2018年的6.828

### 安装包管理工具

brew 和 port

已经有brew了，需要安装下port

port的下载地址：https://www.macports.org/install.php

安装后的位置：/opt/local/bin/port

### 安装qemu

已经安装过qemu了

安装后的位置：/usr/local/bin/qemu-system-i386

### 安装i386-elf-gcc

```
sudo port install i386-elf-gcc
```

安装后的位置：/opt/local/bin/i386-elf-gcc

### 测试

下载源码

```
git clone https://pdos.csail.mit.edu/6.828/2018/jos.git
```

修改GNUmakefile文件，删除其中的两个`-jos`

![](/static/images/2105/p002.png)

编译运行

```
make
make qemu
```

## 调试

安装

```
```


## 参考

- [MIT6.828课程JOS在macOS下的环境配置](https://www.jianshu.com/p/2f1e75bd2c53)
