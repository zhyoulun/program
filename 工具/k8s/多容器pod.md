### 同一pod间的容器通信，同一pod内的容器共识存储卷

```
apiVersion: v1
kind: Pod
metadata:
  name: mc1
spec:
  volumes:
  - name: html
    emptyDir: {}
  containers:
  - name: 1st
    image: nginx
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  - name: 2nd
    image: debian
    volumeMounts:
    - name: html
      mountPath: /html
    command: ["/bin/sh", "-c"]
    args:
      - while true; do
          date >> /html/index.html;
          sleep 1;
        done
```

```
$ kubectl exec mc1 -c 1st -- /bin/cat /usr/share/nginx/html/index.html
...
Fri Aug 25 18:36:06 UTC 2017

$ kubectl exec mc1 -c 2nd -- /bin/cat /html/index.html
...
Fri Aug 25 18:36:06 UTC 2017
Fri Aug 25 18:36:07 UTC 2017
```

### 进程间通信(IPC)

```
apiVersion: v1
kind: Pod
metadata:
  name: mc2
spec:
  containers:
  - name: producer
    image: allingeek/ch6_ipc
    command: ["./ipc", "-producer"]
  - name: consumer
    image: allingeek/ch6_ipc
    command: ["./ipc", "-consumer"]
  restartPolicy: Never
```

```
$ kubectl logs mc2 -c producer
...
Produced: f4
Produced: 1d
Produced: 9e
Produced: 27
$ kubectl logs mc2 -c consumer
...
Consumed: f4
Consumed: 1d
Consumed: 9e
Consumed: 27
Consumed: done
```

### 容器的依赖关系和启动顺序

当前,同一个pod里的所有容器都是并行启动并且没有办法确定哪一个容器必须早于哪一个容器启动.就上面的IPC示例,我们不能总保证第一个容器早于第二个容器启动.这时候就需要使用到初始容器(init container)来保证启动顺序,关于初始容器,可以查看官方文档,本系列也对其进行了翻译,以便查看.


### 同一pod的容器间网络通信

同一pod下的容器使用相同的网络名称空间,这就意味着他们可以通过'localhost'来进行通信,它们共享同一个Ip和相同的端口空间

### 同一个pod暴露多个容器

通常pod里的容器监听不同的端口,想要被外部访问都需要暴露出去.你可以通过在一个服务里暴露多个端口或者使用不同的服务来暴露不同的端口来实现

## 参考

- [kubernetes之多容器pod以及通信](https://www.cnblogs.com/tylerzhou/p/11009412.html)