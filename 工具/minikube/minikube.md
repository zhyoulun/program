启动

```
minikube start
```

访问dashboard

```
minikube dashboard
```

### 示例

yaml文件在hello文件夹中

```
kubectl create -f mysql-rc.yaml
kubectl create -f mysql-svc.yaml

kubectl create -f myweb-rc.yaml
kubectl create -f myweb-svc.yaml
```

在tomcat容器中测试

```
root@myweb-wd7m8:/usr/local/tomcat# curl -i 'http://127.0.0.1:8080'
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
...
```

## 参考

- [minikube quick start](https://minikube.sigs.k8s.io/docs/start/)
