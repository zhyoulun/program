## 从视频文件中提取视频音频文件

**提取视频文件**

```
ffmpeg -i input.mp4 -an -vcodec copy output.mp4
```

> -an: 取消音频轨

**提取音频文件**

```
ffmpeg -i input.mp4 -vn -acodec copy output.m4a
```

> -vn: 取消视频的输出

**导出裸H264数据**

```
ffmpeg -i input.mp4 -an -vcodec copy -bsf:v h264_mp4toannexb output.h264
```

> 使用mp4toannexb这个bitstream filter来转换为原始的h264数据

## 音频格式转换

**aac转wav**

```
ffmpeg -i input.m4a output.wav      
```

**wav转mp3**

```
ffmpeg -i input.wav -acodec libmp3lame output.mp3
```

**wav转aac**

```
ffmpeg -i input.wav output.aac
```

> 坑：转出来的音频，时间长度和输入文件不一致。【原因和避免方法待确认】

**从wav音频文件中导出PCM裸数据**

```

```

## 剪辑

**截取视频文件片段**

从40s开始，持续20s

```
ffmpeg -i input.mp4 -ss 00:00:40.0 -t 20 -c copy output.mp4
```

> -ss time_off：从指定的时间开始，单位为秒，也支持[-]hh:mm:ss[.xxx]的格式
> -t duration：指定时长，单位为秒
> -c copy最好加上，否则执行速度很慢，应该是被转码了【待确认】

**分割较长的视频文件**

将视频文件分割成两段，第一段时长为40s，剩下的为第二段

```
ffmpeg -i input.mp4 -t 00:00:40.0 -c copy output1.mp4 -ss 00:00:40.0  -c copy output2.mp4
```

## 合并视频文件

**使用concat demuxer合并相同编码的文件**

要求

- 所有的编码格式相同
- 所有的文件有相同的streams（相同的codecs，相同的time base等等）
- container可以不一样

创建一个文件`mylist.txt`

```
# this is a comment
file '/path/to/file1.wav'
file '/path/to/file2.wav'
file '/path/to/file3.wav'
```

其中的文件路径可以是相对路径，也可以是绝对路径。然后你可以使用stream copy或者重新编码作用于你的文件列表：

```
ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.wav
```

> -safe 0：如果文件路径是相对的，该选项不是必须的

## 缩放视频

**普通缩放**

> width, w; height h: 设置输出视频宽高。默认值是输入视频宽高。
> 如果w是0，则输入width会用于输出width
> 如果h是0，则输入height会用于输出height

将视频大小修改为640\*360

```
ffmpeg -i input.mp4 -vf scale=w=640:h=360 -y output.mp4
```

其它一些表达方式

```
# 设置绝对值
scale=w=200:h=100 # 宽高设置为200*100
scale=200:100 # 与上述方式等价
scale=200x100 # 与上述方式等价
# 根据输入宽高设置输出宽高
scale=w=2*iw:h=2*ih # 宽高分别放大一倍
scale=2*in_w:2*in_h # 与上述方式等价
scale=w=iw/2:h=ih/2 # 宽高分别缩小一半
```

## 网络播放

**快速播放mp4文件**

将moov挪到文件开头

```bash
ffmpeg -i input.mkv -c copy -movflags +faststart output.mp4
```

## 帮助

**列出支持的所有格式**

```bash
➜  ffmpeg-3.4-study ./bin/ffmpeg -formats 2>/dev/null | head
File formats:
 D. = Demuxing supported
 .E = Muxing supported
 --
 D  3dostr          3DO STR
  E 3g2             3GP2 (3GPP2 file format)
  E 3gp             3GP (3GPP file format)
 D  4xm             4X Technologies
  E a64             a64 - video for Commodore 64
 D  aa              Audible AA format files
```

- 第一列是多媒体文件封装格式的demuxing和muxing的支持
- 第二列是多媒体文件格式的支持
- 第三列是文件格式的详细说明

**列出所有的codecs**

```bash
➜  ffmpeg-3.4-study ./bin/ffmpeg -codecs 2>/dev/null | head -n 12
Codecs:
 D..... = Decoding supported
 .E.... = Encoding supported
 ..V... = Video codec
 ..A... = Audio codec
 ..S... = Subtitle codec
 ...I.. = Intra frame-only codec
 ....L. = Lossy compression
 .....S = Lossless compression
 -------
 D.VI.S 012v                 Uncompressed 4:2:2 10-bit
 D.V.L. 4xm                  4X Movie
```

**列出所有的decoders**

```bash
➜  ffmpeg-3.4-study ./bin/ffmpeg -decoders 2>/dev/null | head -n 12
Decoders:
 V..... = Video
 A..... = Audio
 S..... = Subtitle
 .F.... = Frame-level multithreading
 ..S... = Slice-level multithreading
 ...X.. = Codec is experimental
 ....B. = Supports draw_horiz_band
 .....D = Supports direct rendering method 1
 ------
 V....D 012v                 Uncompressed 4:2:2 10-bit
 V....D 4xm                  4X Movie
```

- 第一列包含6个字段
  - 第一个字段用来表示此编码器为音频、视频还是字幕
  - 第二个字段用来表示帧级别的多线程支持
  - 第三个字段用来表示分片级别的多线程
  - 第四个字段表示该编码为实验版本
  - 第五个字段表示draw horiz band模式支持
  - 第六个字段表示直接渲染模式支持
- 第二列是编码格式
- 第三列是编码格式的详细说明



**列出所有的encoders**

```bash
➜  ffmpeg-3.4-study ./bin/ffmpeg -encoders 2>/dev/null | head -n 12
Encoders:
 V..... = Video
 A..... = Audio
 S..... = Subtitle
 .F.... = Frame-level multithreading
 ..S... = Slice-level multithreading
 ...X.. = Codec is experimental
 ....B. = Supports draw_horiz_band
 .....D = Supports direct rendering method 1
 ------
 V..... a64multi             Multicolor charset for Commodore 64 (codec a64_multi)
 V..... a64multi5            Multicolor charset for Commodore 64, extended with 5th color (colram) (codec a64_multi5)
```

- 第一列包含6个字段
  - 第一个字段表示此编码器为音频、视频还是字幕
  - 第二个字段表示帧级别的多线程支持
  - 第三个字段表示分片级别的多线程
  - 第四个字段表示该编码为实验版本
  - 第五个字段表示draw horiz band模式支持
  - 第六个字段表示直接渲染模式支持
- 第二列是编码格式
- 第三列是编码格式的详细说明

**列出支持的滤镜**

```bash
➜  ffmpeg-3.4-study ./bin/ffmpeg -filters 2>/dev/null | head -n 12
Filters:
  T.. = Timeline support
  .S. = Slice threading
  ..C = Command support
  A = Audio input/output
  V = Video input/output
  N = Dynamic number and/or type of input/output
  | = Source or sink filter
 ... abench            A->A       Benchmark part of a filtergraph.
 ... acompressor       A->A       Audio compressor.
 ... acopy             A->A       Copy the input audio unchanged to the output.
 ... acrossfade        AA->A      Cross fade two input audio streams.
```

- 第一列总共有3个字段
  - 第一个是时间轴的支持
  - 第二个是分片线程处理的支持
  - 第三个字段是命令支持
- 第二列是滤镜名
- 第三列是转换方式，例如音频转音频、视频转视频、创建视频等操作
- 第四列是滤镜作用说明



## 参考

- [ffmpeg之常用音频转换](https://dangger.github.io/2015/10/30/index.html)
- [Concatenating media files](https://trac.ffmpeg.org/wiki/Concatenate)
- [ffmpeg合并视频文件 官方文档](https://moejj.com/ffmpeghe-bing-shi-pin-wen-jian-guan-fang-wen-dang/)
- [Any downsides to always using the -movflags faststart parameter?](https://superuser.com/questions/856025/any-downsides-to-always-using-the-movflags-faststart-parameter)
- [和-movflags +faststart一起咬文嚼字](https://blog.csdn.net/liuzehn/article/details/105639620)
- [MP4文件结构解析](https://blog.csdn.net/qq_25333681/article/details/93144167)
