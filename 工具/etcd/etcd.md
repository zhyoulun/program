- 主页：https://github.com/etcd-io/etcd
- 下载安装包：https://github.com/etcd-io/etcd/releases
- 基于grpc提供服务

启动

```bash
./etcd
```

测试

```bash
➜  ~/temp ./etcdctl set hello world
world
➜  ~/temp ./etcdctl get hello
world
➜  ~/temp ./etcdctl ls /
/hello
➜  ~/temp ./etcdctl get /hello
world
```
