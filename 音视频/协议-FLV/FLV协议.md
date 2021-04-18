## flv知识

### 结构

- FLV
  - flv header
  - flv body(flv body由很多flv tag组成)
    - flv tag
      - 组成
        - tag header
        - tag data
      - 分类
        - audio
        - video
        - script

![](/static/images/2104/p002.webp)

### flv header

- 总长9B
- 前三个是文件类型，总是"FLV"（0x46, 0x4c, 0x56）
- 第四个是版本号，目前一般是0x01
- 第五个B是流信息，倒数第一个bit是1表示有视频(0x01)，倒数第三个bit有1表示有音频(0x04)，有视频又有音频就是(0x01|0x04=0x05)，其它都是0
- 最后4B表示FLV头的长度，值为9

![](/static/images/2104/p001.webp)

### tag header

- tag header长度为11B
- 第1个Byte记录着tag的类型：音频(0x08)，视频（0x09），脚本（0x12）
- 第2个到第4个Byte记录着数据区的长度，也就是tag data的长度
- 再后边3个Byte是视角戳，单位是毫秒，类型为0x12则时间戳为0，时间戳控制着播放速度
- 时间戳后边一个byte是扩展时间戳，时间戳长度不够长的时候使用
- 最后三个Byte是streamID，值为0

再后边就是数据区了，也就是h264裸流

![](/static/images/2104/p003.webp)

### audio tag data

![](/static/images/2104/p004.webp)

![](/static/images/2104/p005.webp)

### video tag data

![](/static/images/2104/p006.webp)

### script tag data

Script Tag通常被称为Metadata Tag，会放一些关于FLV视频和音频的元数据信息如：duration、width、height等。通常此类型Tag会跟在File Header后面作为第一个Tag出现，而且只有一个。

![](/static/images/2104/p007.webp)

第一个AMF包：

第1个字节表示AMF包类型，一般总是0x02，表示字符串。第2-3个字节为UI16类型值，标识字符串的长度，一般总是 0x000A（“onMetaData”长度）。后面字节为具体的字符串，一般   为“onMetaData”（6F,6E,4D,65,74,61,44,61,74,61）。

所以第一个AMF包总共占13字节。

第二个AMF包结构图：

![](/static/images/2104/p008.webp)

第1个字节表示AMF包类型，一般总是0x08，表示数组。第2-5个字节为UI32类型值，表示数组元素的个数，后面即为各数组元素的封装。数组元素为元素名称和值组成的对。“数组元素结构”部分是推测，已经确认适用于duration、width、height等常见元素，但并不确认适用于所有元素。常见的数组元素如下表所示。

![](/static/images/2104/p009.webp)
### 其它

flv文件存储多字节integer，用的是大端序，例如300（0x12C），flv中的ui16是0x01 0x2C

## flv文档

### flv header

![](/static/images/2103/p001.png)

示例

![](/static/images/2103/p002.png)

### flv body

![](/static/images/2103/p003.png)

![](/static/images/2103/p004.png)

### flv tags

![](/static/images/2103/p005.png)

示例

![](/static/images/2103/p006.png)

### audio tags

AUDIODATA & AACAUDIODATA

![](/static/images/2103/p007.png)

![](/static/images/2103/p008.png)

![](/static/images/2103/p009.png)

示例

![](/static/images/2103/p006.png)

### video tags

VIDEODATA & AVCVIDEODATA

![](/static/images/2103/p010.png)

![](/static/images/2103/p011.png)

示例

![](/static/images/2103/p012.png)

### data tags

示例：

![](/static/images/2103/p020.png)

![](/static/images/2103/p021.png)

script_data

![](/static/images/2103/p013.png)

script_data_object

script_data_object_end

![](/static/images/2103/p014.png)

script_data_string

script_data_long_string

![](/static/images/2103/p015.png)

script_data_value

![](/static/images/2103/p016.png)

![](/static/images/2103/p017.png)

script_data_variable

script_data_variable_end

![](/static/images/2103/p018.png)

script_data_date

![](/static/images/2103/p019.png)


## 参考

- [https://www.adobe.com/content/dam/acom/en/devnet/flv/video_file_format_spec_v10.pdf](https://www.adobe.com/content/dam/acom/en/devnet/flv/video_file_format_spec_v10.pdf)
- [https://github.com/imagora/FlvParser](https://github.com/imagora/FlvParser)
- [FLV格式解析](https://www.jianshu.com/p/9a3459dc7b9a)
