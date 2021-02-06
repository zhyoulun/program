代码库https://github.com/zhyoulun/FFmpeg

## 分支：study-4.0

支持插件

- fdk-aac 0.1.6
- x265 3.4
- libmp3lame[todo]

```
./configure --prefix=/Users/zhangyoulun/software/ffmpeg-study \
--enable-libx265 --enable-gpl \
--enable-libfdk-aac \
--extra-cflags="-I/Users/zhangyoulun/software/fdk-aac-0.1.6/include" \
--extra-ldflags="-L/Users/zhangyoulun/software/fdk-aac-0.1.6/lib"
```

如果需要支持调试，configure时需要加上

```
--enable-debug \
--disable-asm \
--disable-optimizations
```

```
--enable-shared
```

> 可以编译出.dylib

## 分支：study-3.4

```
./configure --prefix=/Users/zhangyoulun/software/ffmpeg-versions/ffmpeg-3.4-study
```



## 参考

- [ffmpeg调试相关知识点](https://www.cnblogs.com/shakin/p/3963345.html)
- [Xcode 调试（debug） ffmpeg with ffmpeg_g](https://blog.csdn.net/lipeiran1987/article/details/89553022)
- [Linux下编译ffmpeg并用GDB调试](https://www.cnblogs.com/HongyunL/p/5243096.html)
- [使用gdb和core dump迅速定位段错误（完）](https://my.oschina.net/michaelyuanyuan/blog/68618)



