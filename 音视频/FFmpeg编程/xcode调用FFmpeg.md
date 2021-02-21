# xcode调用FFmpeg

## 正文

### 创建c项目

![](/static/images/2010/p001.png)

![](/static/images/2010/p002.png)

### 设置头文件和库文件的位置

需要配置include和lib

![](/static/images/2102/p001.png)

![](/static/images/2010/p003.png)

### 导入库文件

![](/static/images/2010/p004.png)

![](/static/images/2010/p005.png)

![](/static/images/2010/p006.png)

![](/static/images/2010/p007.png)

![](/static/images/2010/p008.png)

### 输出版本号

![](/static/images/2010/p009.png)

```c
#include <stdio.h>
#include <libavutil/avutil.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    printf("Hello, World!\n");
    printf("ffmpeg version = %s\n", av_version_info());
    return 0;
}
```

## 参考

- [Xcode安装配置ffmpeg开发环境](http://guidongyuan.cn/2018/08/18/Mac%20Xcode%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AEffmpeg%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83/)
- [Setting up SDL 2 on XCode 6.1](https://lazyfoo.net/tutorials/SDL/01_hello_SDL/mac/xcode/index.php)