- 4.0中的`av_register_all()`已经废弃了，不需要调用
- 使用gcc测试：gcc -I /Users/zhangyoulun/codes/github/build/ffmpeg/output/install/include -L /Users/zhangyoulun/codes/github/build/ffmpeg/output/install/lib -lavformat main.c

如下代码可以解析mp4文件，但是无法解析http-flv，需要增加avformat_find_stream_info函数的调用后，可以拿到metadata信息

```c
#include <stdio.h>

#include <libavformat/avformat.h>
#include <libavutil/dict.h>

int main (int argc, char **argv)
{
    AVFormatContext *fmt_ctx = NULL;
    AVDictionaryEntry *tag = NULL;
    int ret;

    if (argc != 2) {
        printf("usage: %s <input_file>\n"
               "example program to demonstrate the use of the libavformat metadata API.\n"
               "\n", argv[0]);
        return 1;
    }

    if ((ret = avformat_open_input(&fmt_ctx, argv[1], NULL, NULL)))
        return ret;

    while ((tag = av_dict_get(fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
        printf("%s=%s\n", tag->key, tag->value);

    avformat_close_input(&fmt_ctx);
    return 0;
}
```

测试

```
➜  HelloFFmpegV2 ./a.out /Users/zhangyoulun/codes/video/gee.mp4
major_brand=isom
minor_version=512
compatible_brands=isomiso2avc1mp41
encoder=Lavf55.19.104
➜  HelloFFmpegV2 ./a.out http://127.0.0.1:8080/app1/stream1.flv\?vhost\=vhost1
➜  HelloFFmpegV2
```

```c
#include <stdio.h>

#include <libavformat/avformat.h>
#include <libavutil/dict.h>

int main (int argc, char **argv)
{
    AVFormatContext *fmt_ctx = NULL;
    AVDictionaryEntry *tag = NULL;
    int ret;
    
    if (argc != 2) {
        printf("usage: %s <input_file>\n"
               "example program to demonstrate the use of the libavformat metadata API.\n"
               "\n", argv[0]);
        return 1;
    }
    
    if ((ret = avformat_open_input(&fmt_ctx, argv[1], NULL, NULL)))
        return ret;
    
    if((ret =avformat_find_stream_info(fmt_ctx, NULL))<0){
        return ret;
    }
    
    while ((tag = av_dict_get(fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
        printf("%s=%s\n", tag->key, tag->value);
    
    avformat_close_input(&fmt_ctx);
    return 0;
}
```

测试

```
➜  HelloFFmpegV2 ./a.out http://127.0.0.1:8080/app1/stream1.flv\?vhost\=vhost1
link_info=x_28193
stream_id=vhost1:app1:stream1
compatible_brands=isomiso2avc1mp41
encoder=Lavf58.45.100
minor_version=512
major_brand=isom
➜  HelloFFmpegV2
➜  HelloFFmpegV2 ./a.out /Users/zhangyoulun/codes/video/gee.mp4
major_brand=isom
minor_version=512
compatible_brands=isomiso2avc1mp41
encoder=Lavf55.19.104
```



## 参考

- [av_register_all() has been deprecated in ffmpeg 4.0](https://github.com/leandromoreira/ffmpeg-libav-tutorial/issues/29)
- [https://github.com/zhyoulun/FFmpeg/blob/study-4.0/doc/examples/metadata.c](https://github.com/zhyoulun/FFmpeg/blob/study-4.0/doc/examples/metadata.c)