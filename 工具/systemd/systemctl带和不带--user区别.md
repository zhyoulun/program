systemd 支持普通用户定义的 unit[s] 开机启动

systemctl --user enable/disable/start/stop/daemon-reload... xxx.service

--user 不可省略，因为默认是执行 systemctl [--system]，对于系统级 unit[s] 来说，不必显式添加 --system 选项

## 参考

- [拾遗：systemctl --user](https://www.cnblogs.com/hadex/p/6571278.html)