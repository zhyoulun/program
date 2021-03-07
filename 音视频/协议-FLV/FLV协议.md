- flv文件存储多字节integer，用的是大端序，例如300（0x12C），flv中的ui16是0x01 0x2C

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