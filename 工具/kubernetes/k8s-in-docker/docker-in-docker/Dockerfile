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

# 安装docker，https://docs.docker.com/engine/install/ubuntu/
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

CMD ["/sbin/init"]