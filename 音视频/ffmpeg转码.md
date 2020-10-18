ffmpeg转码的主要原理如下图所示：

![](/static/images/2010/p016.jpeg)

如果转码涉及封装的改变，则可以通过设置AVCodec与AVFormat的操作进行封装与编码的改变

示例

```
./ffmpeg -i input.rmvb -vcodec mpeg4 -b:v 200k -r 15 -an output.mp4
```

从输出的信息可以看出：

- 转封装格式从rmvb格式转换为mp4
- 视频编码从RV40转码为mpeg4
- 视频码率从原来的377kbps转换为200kbps
- 视频帧率从原来的23.98fps转换为15fps
- 转码后的文件中不包含音频（-an参数）

