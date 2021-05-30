### 安装 gitbook 工具

```
npm install -g gitbook-cli
```

### 安装 ebook-convert(mac用户)

下载地址：https://calibre-ebook.com/

配置环境变量

```
export EBOOK_PATH=/Applications/calibre.app/Contents/MacOS
export PATH=$PATH:$EBOOK_PATH
```

### 克隆gitbook仓库

```
git clone git@github.com:ranxian/xv6-chinese.git
```

### 生成电子书

```
gitbook epub
```

### 解决问题TypeError: cb.apply is not a function

修改文件/usr/local/lib/node_modules/gitbook-cli/node_modules/npm/node_modules/graceful-fs/polyfills.js

注释掉如下三行内容

```
fs.stat = statFix(fs.stat)
fs.fstat = statFix(fs.fstat)
fs.lstat = statFix(fs.lstat)
```

## 参考

- [自己动手制作电子书的最佳方式（支持PDF、ePub、mobi等格式）](https://zhuanlan.zhihu.com/p/245763905)
- [gitbook初探:TypeError: cb.apply is not a function](https://blog.csdn.net/yq_forever/article/details/112121742)
- [gitbook出现TypeError: cb.apply is not a function解决办法](https://www.cnblogs.com/cyxroot/p/13754475.html)
