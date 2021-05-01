参考[https://rancher.com/docs/k3s/latest/en/quick-start/](https://rancher.com/docs/k3s/latest/en/quick-start/)

### k3s server安装

执行命令`curl -sfL https://get.k3s.io | sh -`

- 会配置开机自动启动，进程停止后自动启动
- 额外会安装kubectl, crictl, ctr, k3s-killall.sh, k3s-uninstalls.h
- `kubeconfig`文件会被写到`/etc/rancher/k3s/k3s.yaml`，k3s安装的kubectl会使用这个文件

### k3s agent安装
