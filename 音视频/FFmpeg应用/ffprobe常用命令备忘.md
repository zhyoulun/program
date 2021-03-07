### 打印格式

`-of`等价于`-json`

```
-of csv
-of json
```

### 查看aac文件的格式信息

```
ffprobe -show_format -of json input.aac
```

> -show_format：查看文件格式信息
> -of json：以json格式输出结果

输出结果

```
{
    "format": {
        "filename": "input.aac",
        "nb_streams": 1,
        "nb_programs": 0,
        "format_name": "aac",
        "format_long_name": "raw ADTS AAC (Advanced Audio Coding)",
        "duration": "221.020531",
        "size": "4140571",
        "bit_rate": "149870",
        "probe_score": 51
    }
}
```

> nb_streams: Number of elements in AVFormatContext.streams
> nb_programs: 暂不清楚
> probe_score：暂不清楚




- `-show_packets`：解码前的
- `-show_frames`：解码后的

