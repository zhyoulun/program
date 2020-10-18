- 读取file，拿到pFormatCtx
- pFormatCtx中有多路流，找到video类型的流，拿到这路流的pCodeCtxOrig
- 从pCodeCtxOrig复制出pCodecCtx
- 初始化pFrameRGB，并根据pCodecCtx的信息申请一个buffer，赋予给pFrameRGB
- 从pFormatCtx读取数据到packet中
- 调用函数avcodec_decode_video2进行解码，将数据存放在pCodecCtx和pFrame中
- 调用sws_scale函数将pFrame转换为pFrameRGB
- 存储PCM文件

