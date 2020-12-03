## 命令

**删除所有的container**

```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

**删除所有的image**

```
docker image rm $(docker image ls -a -q)
```

**进入容器**

```
docker exec -it container_name /bin/bash
```

**启动停止docker-compose**

```
docker-compose up
docker-compose down
```

`docker-compose up --build`：在启动container前先编译images，一般在调试Dockerfile时非常有用


```
docker-compose up && docker-compose rm -fsv
```

## 待整理

docker run -it --privileged -d --rm --name a2 -p 5050:5050 docker-mesos-1.11.0 /bin/bash




## 参考

- [Stop / remove all Docker containers](https://coderwall.com/p/ewk0mq/stop-remove-all-docker-containers)