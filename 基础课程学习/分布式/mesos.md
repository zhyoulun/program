## 概述

Apache Mesos诞生于UC Berkeley的一个研究项目，现已成为Apache Incubator中的项目。Apache Mesos把自己定位成一个数据中心操作系统，它能管理上万台的从机。Framework相当于这个操作系统的应用程序，每当应用程序需要执行，Framework就会在Mesos中选择一台有合适资源(cpu、内存等)的从机来运行。

Apache Mesos使用ZooKeeper实现容错复制，使用Linux Containers来隔离任务，支持多种资源计划分配。Apache Mesos应用场景非常广泛。

## Apache Mesos中的基本术语解释

- Mesos-Master：主要负责管理各个Framework和Slave，并将Slave上的资源分配给各个Framework。
- Mesos-Slave：负责管理本节点上的各个Mesos-Task，比如：为各个executor分配资源。
- Framework：计算框架，如：Hadoop、Spark、Kafaka、ElasticSerach等，通过MesosSchedulerDiver接入Mesos。
- Executor：执行器，就是安装到每个机器节点的软件。用于启动计算框架中的Task。这里就是利用Docker的容器来担任执行器的角色。具有启动销毁快，隔离性高，环境一致等特点。

## Apache Mesos总体架构

![](/static/images/2011/p002.jpg)

Apache Mesos由四个组件组成，分别是Mesos-Master，Mesos-Slave，Framework和Executor。

- Mesos-Master是整个系统的核心，负责管理接入Mesos的各个framework(由frameworks_manager管理)和Slave(由slaves_manager管理)，并将slave上的资源按照某种策略分配给framework(由独立插拔模块Allocator管理)。
- Mesos-Slave负责接受并执行来自Mesos-master的命令、管理节点上的mesos-task，并为各个task分配资源。Mesos-Slave将自己的资源量发送给Mesos-Master，由Mesos-Master中的Allocator模块决定将资源分配给哪个framework，当前考虑的资源有CPU和内存两种，也就是说，Mesos-Slave会将CPU个数的内存量发送给Mesos-Master，而用户提交作业时需要指定每个任务需要的CPU个数和内存。这样当任务运行时，Mesos-Slave会将任务放到包含固定资源Linux container中运行，以达到资源隔离的效果。很明显，Master存在单点故障问题，为此Mesos采用了Zookeeper解决该问题。
- Framework是指外部的计算框架，如果Hadoop、Mesos、Marathon等，这些计算框架可通过注册的方式接入Mesos，以便Mesos进行统一管理和资源分配。Mesos要求可接入的框架必须有一个调度模块，该调度器负责框架内部的任务调度。当一个Framework想要接入Mesos时，需要修改自己的调度器，以便向Mesos注册，并获取Mesos分配给自己的资源，这样再由自己的调度器将这些资源分配给框架中的任务。也就是说，整个Mesos系统采用了双层调度框架：第一层,由Mesos将资源分配给框架。第二层,框架自己的调度器将资源分配给自己内部的任务。当前Mesos支持三中语言编写的调度器，分别是C++、Java、Python。为了向各种调度器提供统一的接入方式，Mesos内部采用C++实现了一个MesosSchedulerDriver(调度驱动器)，Framework的调度器可调用该driver中的接口与Mesos-Master交互，完成一系列功能(如注册，资源分配等。)
- Executor主要用于启动框架内部的Task。由于不同的框架，启动Task的接口或者方式不同，当一个新的框架要接入Mesos时，需要编写一个Executor，告诉Mesos如何启动该框架中的task。为了向各种框架提供统一的执行器编写方式，Mesos内部采用C++实现了一个MesosExecutorDiver(执行器驱动器)，Framework可通过该驱动器的相关接口告诉Mesos启动Task的方式。

官方提供的一个资源分配的例子

![](/static/images/2011/p003.jpg)

- Slave1向Master报告，有4个CPU和4GB内存可用。
- Master发送一个Resource Offer给Framework1来描述Slave1有多少可用资源。
- FrameWork1中的FW Scheduler会答复Master，我有两个Task需要运行在Slave1，一个Task需要2个CPU，1GB内存，另外一个Task需要1个CPU，2GB内存。
- 最后，Master发送这些Tasks给Slave1。然后Slave1还有1个CPU和1GB内存没有使用，所以分配模块可以把这些资源提供给Framework2。

这个例子可以看出来，Mesos的核心工作其实很少，资源管理和分配以及Task转发。调度由Framework实现，Task的定义以及具体执行也由Framework实现，Mesos的资源分配粒度是按Task的，但由于Executor执行Task可能在同一个进程中实现，所以资源限制只是一种流控的机制，并不能实际的控制到Task这个粒度。

## Mesos和Kubernetes比较

Mesos和Kubernetes虽然都借鉴了Borg的思想，终极目标类似，但解决方案是不同的。

- Mesos有点像联邦制，承认各邦(Framework)的主权，但各邦让渡一部分公用的机制出来由Mesos来实现，最大化的共享资源，提高资源利用率，Framework和Mesos是相对独立的关系。
- Kubernetes有点像单一制，搭建一个通用的平台，尽量提供全面的能力(网络，磁盘，内存，cpu)，制定一个集群应用的定义标准。任何复杂的应用都可以按照该标准定义并以最小的变更成本在上面部署运行，主要的变更需求也是因为想享受Kubernetes的动态伸缩能力带来的。
- Mesos是基于两阶段调度的集群管理器。基于其两阶段调度特性，用户需要能够使用Mesos的Mesos框架(比如Marathon，Aurora，Singularity)，才能够像Kubernetes调度器那样工作。高度简化来说，Mesos用来管理集群资源，并且向其提供高层级的能接受这些资源来启动任务的框架。Mesos作为数据中心管理系统，适用于任何开发框架和应用。
- Kubernetes是基于Borg理念而设计的容器集群管理器。Google的集群管理器没有两阶段调度的概念，而针对容器的集群管理具有轻量化、模块化、便捷等特点；除了两阶段调度，Mesos和Kubernetes还有很多区别，比如它们的依赖（Zookeeper、Etcd等等）以及使用方式等等。

值得一提的是，Mesos正在接受Kubernetes的理念，你可以在Mesos集群上搭建Kubernetes并部署Kubernets应用。Kubernetes on Mesos正是这样一个项目：https://kubernetes.io/docs/getting-started-guides/mesos/

## 参考

- [Mesos - 优秀的集群资源调度平台](https://yeasy.gitbook.io/docker_practice/archive/mesos)
- [使用 Mesos 和 Marathon 管理 Docker 集群](https://www.hi-linux.com/posts/8141.html)
- [Apache Mesos 入门](https://www.hi-linux.com/posts/54145.html)