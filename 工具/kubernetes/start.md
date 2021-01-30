中文文档：https://kubernetes.io/zh/docs/home/
英文文档：https://kubernetes.io/docs/home/


单机版测试工具minikube：https://minikube.sigs.k8s.io/docs/start/

## 问题

Get https://registry-1.docker.io/v2/: net/http: TLS handshake timeout

解决方法：

```
image: ustc-edu-cn.mirror.aliyuncs.com/library/mysql:latest
```

好像是不能开全局代理

