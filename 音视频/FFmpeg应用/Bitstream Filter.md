### bitstream filter

- Bitstream Filter的主要目的是对数据进行格式转换，使它能够被解码器处理（比如HEVC QSV的解码器）。
- Bitstream Filter对已编码的码流进行操作，不涉及解码过程。

### list bitstream filters

```
$ ./ffmpeg -bsfs
Bitstream filters:
aac_adtstoasc
chomp
dump_extra
dca_core
eac3_core
extract_extradata
filter_units
h264_metadata
h264_mp4toannexb
h264_redundant_pps
hapqa_extract
hevc_metadata
hevc_mp4toannexb
imxdump
mjpeg2jpeg
mjpegadump
mp3decomp
mpeg2_metadata
mpeg4_unpack_bframes
mov2textsub
noise
null
remove_extra
text2movsub
trace_headers
vp9_raw_reorder
vp9_superframe
vp9_superframe_split
```

### h264_mp4toannexb

H.264码流分Annex-B和AVCC两种格式。

- AVCC以长度信息分割NALU，在mp4和flv等封装格式中使用。
- Annex-B以start code(0x000001或0x00000001)分割NALU，在mpegts流媒体文件中使用。

很多场景需要进行这两种格式之间的转换，FFmpeg提供了名称为h264_mp4toannexb 的Bitstream Filter(bsf)来实现这个功能。例如，将AVCC格式的H.264流的转换为Annex-B格式，可以使用以下命令[1]：

```
ffmpeg -i INPUT.mp4 -codec copy -bsf:v h264_mp4toannexb OUTPUT.ts
```

注意，使用ffmpeg时如果指定输出格式为mpegts或h264，会自动加入这个filter。


## 参考

- [FFmpeg 的Bitstream Filter如h264_mp4toannexb](https://www.jianshu.com/p/1bff2869b47d)