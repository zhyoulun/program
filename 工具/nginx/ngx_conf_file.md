由于Nginx的配置基本就是对模块的配置，因此，在讨论配置功能之前，需要先分析Nginx的模块功能。

Nginx本身由多个基本的模块构成，其中，核心的部分是一个叫ngx_core_module的模块。当然，对于一个web服务器，仅仅有一个核心是不够的，还需要大量的“辅助模块”。这有点像Linux的设计，一堆外围设施作为模块与Linux内核构成整个Linux系统。

很自然的会想到，Nginx的这种模块化设计是支持第三方插件的。这种设计也大大增加了Nginx的弹性和能力。

既然Nginx是由许多模块构成的，那么，如何组织和管理这些模块是首先要关注的问题。在Nginx中，使用全局数组ngx_modules保存和管理所有Nginx的模块。

首先，Nginx的众多模块被分成两类：必须安装的模块和可以安装的模块。

- 必须安装的模块是保证Nginx正常功能的模块，没得选择，这些模块会出现在ngx_modules里。比如ngx_core_module
- 可以安装的模块通过configure的配置和系统环境，被有选择的安装，这些模块里，被选择安装的模块会出现在ngx_modules数组中。

使用extern ngx_module_t ngx_core_module;使编译器在编译的时候不去处理ngx_core_module，在链接阶段，再将ngx_core_module链接到正确的地址中。



## 参考

- [Nginx 源码分析：从模块到配置（上）](https://segmentfault.com/a/1190000002778510)
- [Nginx 源码分析：从模块到配置（下）](https://segmentfault.com/a/1190000002780254)