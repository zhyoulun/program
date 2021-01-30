## Modules, packages, and versions

A module is a collection of packages that are released, versioned, and distributed together. Modules may be downloaded directly from version control repositories or from module proxy servers.

A module is identified by a module path, which is declared in a go.mod file, together with information about the module's dependencies. The module root directory is the directory that contains the go.mod file. The main module is the module containing the directory where the go command is invoked.

Each package within a module is a collection of source files in the same directory that are compiled together. A package path is the module path joined with the subdirectory containing the package (relative to the module root). For example, the module "golang.org/x/net" contains a package in the directory "html". That package's path is "golang.org/x/net/html".




## 参考

- [https://golang.org/ref/mod](https://golang.org/ref/mod)