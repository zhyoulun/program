## 二进制文件查看

**使用vim**

打开文件，使用如下命令可以转换成友好的查看方式

```
:%!xxd
```

还原查看方式

```
:%!xxd -r
```

**使用hexfiend**

http://ridiculousfish.com/hexfiend/

**使用xcode**

* Open file with Xcode and press Command + Shift + J
* Right click file name in left pane
* Open as -> Hex

## 参考

- [What's a good hex editor/viewer for the Mac? [closed]](https://stackoverflow.com/questions/827326/whats-a-good-hex-editor-viewer-for-the-mac)