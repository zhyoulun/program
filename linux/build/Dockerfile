FROM ubuntu:16.04

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get update && \
    apt install -y net-tools \
    vim \
    wget \
    curl \
    telnet \
    golang \
    openjdk-8-jdk \
    lsof \
    ffmpeg \
    git \
    fakeroot \
    build-essential \
    ncurses-dev \
    xz-utils \
    libssl-dev \
    bc \
    flex \
    libelf-dev \
    bison \
    gdb \
    qemu \
    cpio \
    unzip

CMD sleep 864000000