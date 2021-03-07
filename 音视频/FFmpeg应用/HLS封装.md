```bash
ffmpeg -i ~/codes/video/hu_1min.mp4 \
-c:v libx264 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v 5M -maxrate:v 5M -minrate:v 5M -bufsize:v 10M -preset slow -g 48 -sc_threshold 0 -keyint_min 48 \
-f hls \
-hls_time 2 \
-hls_playlist_type vod \
-hls_flags independent_segments \
-hls_segment_type mpegts \
-hls_segment_filename stream_%v/data%02d.ts \
stream_%v.m3u8
```

```bash
ffmpeg -i ~/codes/video/hu_1min.mp4 \
-c:v libx264 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v 5M -maxrate:v 5M -minrate:v 5M -bufsize:v 10M -preset slow -g 48 -sc_threshold 0 -keyint_min 48 \
-f hls \
-hls_time 2 \
-hls_list_size 2 \
-hls_flags independent_segments \
-hls_segment_type mpegts \
-hls_segment_filename data%02d.ts \
stream_%v.m3u8
```


## 参考

- [HLS Packaging using FFmpeg – Easy Step-by-Step Tutorial](https://ottverse.com/hls-packaging-using-ffmpeg-live-vod/)