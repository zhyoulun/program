FROM ubuntu:16.04

# 更换apt源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

# 安装基础软件
RUN apt-get update && \
    apt install -y net-tools \
    vim \
    wget \
    git \
    curl \
    telnet \
    golang \
    openjdk-8-jdk \
    lsof \
    ffmpeg

CMD ["/sbin/init"]