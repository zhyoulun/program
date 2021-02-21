## 安装

获取代码

git clone git@github.com:zhyoulun/srs.git

编译
```
cd srs/truck
./configure --osx
make -j 4
```

启动

./objs/srs -c conf/srs.conf

遇到的问题
```
cat objs/srs.log 
[2018-02-07 17:07:43.307][trace][23319][0] srs checking config...
[2018-02-07 17:07:43.307][error][23319][0][2] invalid max_connections=1000, required=1008, system limit to 256, total=1007(max_connections=1000, nb_consumed_fds=7), ret=1023. you can change max_connections from 1000 to 248, or you can login as root and set the limit: ulimit -HSn 1008(No such file or directory)
```

修改srs.conf

max_connections     200;

推流

ffmpeg -stream_loop -1 -re -i zhou.mp4 -vcodec h264 -acodec aac -f flv "rtmp://localhost/live/test1"

拉流

ffplay rtmp://localhost/live/test1

管理web界面

http://localhost:8080/

## 配置

### SampleRTMP

https://github.com/ossrs/srs/wiki/v1_CN_SampleRTMP

```
./objs/srs -c conf/rtmp.conf

推流
ffmpeg -stream_loop -1 -re -i zhou.mp4 -vcodec h264 -acodec aac -f flv "rtmp://localhost/live/test1"

拉流
ffplay rtmp://localhost/live/test1
```

### SampleRTMPCluster

https://github.com/ossrs/srs/wiki/v1_CN_SampleRTMPCluster

```
./objs/srs -c conf/origin.conf
./objs/srs -c conf/edge.conf

源站rtmp流
rtmp://localhost:19350/live/test1

边缘rtmp流
rtmp://localhost:1935/live/test1
```

### http-flv

https://github.com/ossrs/srs/wiki/v2_CN_SampleHttpFlv

```
./objs/srs -c conf/http.flv.live.conf

推流
ffmpeg -stream_loop -1 -re -i zhou.mp4 -vcodec h264 -acodec aac -f flv "rtmp://localhost/live/test1"

拉流
ffplay rtmp://localhost/live/test1
ffplay http://localhost:8080/live/test1.flv
```

### http-flv集群模式

https://github.com/ossrs/srs/wiki/v2_CN_SampleHttpFlvCluster

## hls(+nginx)

https://github.com/ossrs/srs/wiki/v2_CN_SampleHLS

## hls

https://github.com/ossrs/srs/wiki/v2_CN_SampleHTTP

```
./objs/srs -c conf/http.hls.conf

推流
ffmpeg -stream_loop -1 -re -i zhou.mp4 -vcodec h264 -acodec aac -f flv "rtmp://localhost/live/test1"

拉流
ffplay rtmp://localhost/live/test1
ffplay http://localhost:8080/live/test1.m3u8
```
