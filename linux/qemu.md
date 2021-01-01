## 使用qemu启动虚拟机

安装qemu

```
brew install qemu
```

创建磁盘

```
qemu-img create -f qcow2 ubuntu.img 10G
```

启动虚拟机安装操作系统

```
qemu-system-x86_64 -m 2G -machine accel=hvf ubuntu.img -cdrom ~/Documents/软件备份/iso/ubuntu-16.04.7-server-amd64.iso
```

启动虚拟机

```
qemu-system-x86_64 -m 2G -machine accel=hvf ubuntu.img
```

参数：

- `-m`:Amount of memory to use
- `-machine`: The emulated machine and the accelerator. q35 is the newest machine type and HVF is the macOS native hypervisor.


## 问题

### QEMU hvf support for Mac OS X Bug Sur: HV_ERROR

> 不使用`-machine accel=hvf`，会特别慢

```
codesign -s - --entitlements app.entitlements --force /usr/local/bin/qemu-system-x86_64
```

文件`app.entitlements`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>com.apple.security.hypervisor</key>
        <true/>
    </dict>
</plist>
```

## 参考

- [QEMU 1: 使用QEMU创建虚拟机](https://my.oschina.net/kelvinxupt/blog/265108)
- [QEMU hvf support for Mac OS X Bug Sur: HV_ERROR](https://www.reddit.com/r/VFIO/comments/kdhgni/qemu_hvf_support_for_mac_os_x_bug_sur_hv_error/)
- [Using QEMU to create a Ubuntu 20.04 Desktop VM on macOS](https://www.arthurkoziel.com/qemu-ubuntu-20-04/)
- https://gist.github.com/aserhat/91c1d5633d395d45dc8e5ab12c6b4767