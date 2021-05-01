# kubectl用法

## rc(ReplicationController)

### 获取rc列表

```bash
➜  ~ kubectl get rc
NAME    DESIRED   CURRENT   READY   AGE
mysql   1         1         1       87m
nginx   1         1         1       5m57s
redis   1         1         1       3m9s
```

### 获取指定的rc

```bash
➜  ~ kubectl get rc redis
NAME    DESIRED   CURRENT   READY   AGE
redis   1         1         1       3m12s
```

### 查看指定的rc信息

```bash
➜  ~ kubectl describe rc mysql
Name:         mysql
Namespace:    default
Selector:     app=mysql
Labels:       app=mysql
Annotations:  <none>
Replicas:     1 current / 1 desired
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=mysql
  Containers:
   mysql:
    Image:      1jdlp79a.mirror.aliyuncs.com/library/mysql:latest
    Port:       3306/TCP
    Host Port:  0/TCP
    Environment:
      MYSQL_ROOT_PASSWORD:  123456
    Mounts:                 <none>
  Volumes:                  <none>
Events:                     <none>
```

### 创建一个rc

```bash
kubectl create -f redis-rc.yaml
```

### 删除一个rc

```bash
➜  ~ kubectl delete rc mysql
replicationcontroller "mysql" deleted
```

## pod

### 获取pod列表

```bash
➜  ~ kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-xnwtk   1/1     Running   0          90m
mysql-dnvpp                   1/1     Running   0          87m
nginx-2dnmv                   1/1     Running   0          6m51s
redis-zqkgn                   1/1     Running   0          4m3s
```

### 获取指定的pod

```bash
➜  ~ kubectl get pod mysql-dnvpp
NAME          READY   STATUS    RESTARTS   AGE
mysql-dnvpp   1/1     Running   0          87m
```

### 查询指定的pod信息

```bash
➜  ~ kubectl describe pod redis-zqkgn
Name:         redis-zqkgn
Namespace:    default
Priority:     0
Node:         minikube/192.168.64.2
Start Time:   Sat, 30 Jan 2021 18:02:07 +0800
Labels:       app=redis
Annotations:  <none>
Status:       Running
IP:           172.17.0.8
IPs:
  IP:           172.17.0.8
Controlled By:  ReplicationController/redis
Containers:
  redis:
    Container ID:   docker://88d20b979cd2e121549a422714e1e4a809f806287f2e8308ab831b084ae14e50
    Image:          xxx.mirror.aliyuncs.com/library/redis:latest
    Image ID:       docker-pullable://xxx.mirror.aliyuncs.com/library/redis@sha256:0f97c1c9daf5b69b93390ccbe8d3e2971617ec4801fd0882c72bf7cad3a13494
    Port:           6379/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 30 Jan 2021 18:02:11 +0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-wb7mb (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-wb7mb:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-wb7mb
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m32s  default-scheduler  Successfully assigned default/redis-zqkgn to minikube
  Normal  Pulling    6m31s  kubelet            Pulling image "xxx.mirror.aliyuncs.com/library/redis:latest"
  Normal  Pulled     6m28s  kubelet            Successfully pulled image "xxx.mirror.aliyuncs.com/library/redis:latest" in 3.170436956s
  Normal  Created    6m28s  kubelet            Created container redis
  Normal  Started    6m28s  kubelet            Started container redis
```

### 删除一个pod

因为rc的存在，删除pod后，还会重新再创建一个

```bash
➜  ~ kubectl delete pod redis-zqkgn
pod "redis-zqkgn" deleted
```

### 登录pod

```bash
kubectl exec -it shell-demo -- /bin/bash
```

## svc(service)

### 创建service

```bash
kubectl create -f myweb-svc.yaml
```

### 获取service列表

```bash
➜  ~ kubectl get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.105.184.14    <pending>     8080:32505/TCP   19d
kubernetes   ClusterIP      10.96.0.1        <none>        443/TCP          19d
mysql        ClusterIP      10.99.16.3       <none>        3306/TCP         10m
myweb        NodePort       10.111.207.113   <none>        8080:30001/TCP   10m
```

### 获取指定的service信息

```bash
➜  ~ kubectl get svc mysql
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
mysql   ClusterIP   10.99.16.3   <none>        3306/TCP   10m
```

### 查询service信息

```bash
➜  ~ kubectl describe svc mysql
Name:              mysql
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=mysql
Type:              ClusterIP
IP:                10.99.16.3
Port:              <unset>  3306/TCP
TargetPort:        3306/TCP
Endpoints:         172.17.0.8:3306
Session Affinity:  None
Events:            <none>
```

## deployment

缩写是deploy

### 更新deployment

```
kubectl edit deployment/nginx-deployment
```

保存之后就会触发



## 参考

- [获取正在运行容器的 Shell](https://kubernetes.io/zh/docs/tasks/debug-application-cluster/get-shell-running-container/)
- https://kubernetes.io/zh/docs/concepts/workloads/controllers/deployment/
