sudo visudo

给`Defaults        env_reset`追加参数`timestamp_timeout=xxxxx`

即

```
Defaults        env_reset,timestamp_timeout=xxxx
```

- 如果timestamp_timeout=0，则每次使用 sudo 均要求输入密码
- 如果timestamp_timeout=-1，永久禁用密码提示，这样当你在注销或退出 terminal 之前，都会记住密码


## 参考

- [Linux设置sudo会话密码的超时时长](https://blog.csdn.net/gatieme/article/details/71056020)