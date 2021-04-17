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

![](/static/images/2104/p001.webp)

### flv header

- 总长9B
- 前三个是文件类型，总是"FLV"（0x46, 0x4c, 0x56）
- 第四个是版本号，目前一般是0x01
- 第五个B是流信息，倒数第一个bit是1表示有视频(0x01)，倒数第三个bit有1表示有音频(0x04)，有视频又有音频就是(0x01|0x04=0x05)，其它都是0
- 最后4B表示FLV头的长度，值为9



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
