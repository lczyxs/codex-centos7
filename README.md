# codex-centos7

适配 codex 使得在 centos 7 等老旧系统上可正常运行

## Patchelf 原理与生效机制

本项目使用 `patchelf` 工具来修补 codex 二进制文件，使其能够在 CentOS 7 等老旧 Linux 系统上正常运行。以下是其工作原理和为什么能够生效的详细说明。

### Patchelf 简介
`patchelf` 是一个开源工具，用于修改 ELF (Executable and Linkable Format) 二进制文件的动态链接信息。它可以改变可执行文件或共享库的：
- 动态链接器 (interpreter)
- RPATH (Run-time search path)
- RUNPATH
- 以及其他 ELF 头部信息

### 脚本中的使用
在 `patch-codex.sh` 脚本中，我们执行了以下两个关键操作：

1. **设置 RPATH**:
   ```bash
   $PREFIX/bin/patchelf --set-rpath $PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/:$PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64 $PREFIX/bin/codex
   ```
   这将 codex 二进制文件的 RPATH 设置为指向 conda 环境中的 sysroot 库路径。

2. **设置动态链接器**:
   ```bash
   $PREFIX/bin/patchelf --set-interpreter $PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/ld-linux-x86-64.so.2 $PREFIX/bin/codex
   ```
   这将动态链接器设置为 conda sysroot 中的 ld-linux-x86-64.so.2。

### 为什么能够生效

#### 1. 解决库版本兼容性问题
- **问题**: CentOS 7 使用较旧的 glibc 版本 (2.17)，而现代软件如 codex 可能需要更新的 glibc 功能。
- **解决方案**: 通过设置 RPATH，程序会优先从 conda 提供的 sysroot 中查找共享库，这些库版本与 codex 兼容。

#### 2. 绕过系统动态链接器限制
- **问题**: 系统默认的动态链接器可能不支持某些新特性或与旧系统不兼容。
- **解决方案**: 使用 conda sysroot 中的动态链接器，它与 sysroot 库协调工作，确保正确的链接和加载。

#### 3. 隔离环境
- **优势**: RPATH 机制允许程序使用特定的库版本，而不依赖于系统全局安装的库版本。这提供了更好的可移植性和兼容性。

#### 4. 构建时的集成
- 在 `construct.yaml` 中，`post_install` 指定了 `patch-codex.sh`，确保在 conda 包构建完成后自动应用这些修补。
- sysroot-conda_2_28-x86_64 提供了必要的库和链接器文件。

### 技术细节
- **ELF RPATH**: RPATH 是嵌入在 ELF 文件中的搜索路径列表，动态链接器使用它来定位共享库。
- **动态链接器**: ld-linux.so.2 是 Linux 上的标准动态链接器，负责加载和链接共享库。
- **sysroot**: conda 提供的 sysroot 是一个自包含的根文件系统，包含了构建和运行所需的所有库和工具。

通过这些修补，codex 能够在 CentOS 7 等老系统上运行，而无需修改系统库或升级操作系统。

## 版本历史 (Changelog)

### v0.142.5 (当前版本)
- 初始版本发布
- 支持 codex  0.142.5 在 CentOS 7 上的兼容性适配
- 使用 patchelf 修补二进制文件以解决库依赖问题
- 添加 GitHub Actions workflow 用于自动化 release 构建和发布
- 支持 linux-64 和 linux-aarch64 架构的包构建

## 未来计划

- 扩展支持更多老旧 Linux 发行版
- 优化构建流程和文档

## 参考项目

https://github.com/FSSlc/opencode-centos7

## 改进点
- 使用 conda constructor 打包，普通用户可用
- 增加 linux-aarch64 支持
- 无需手动编译 gcc glibc 等
- 使用 github action 发布制品