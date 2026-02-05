# 介绍

rsdk-docker 是 [rsdk](https://github.com/radxaos-sdk/rsdk) 项目 Docker 环境，原项目需要配合 Devcontainer 使用，需要 nix 环境再运行 Docker，并且 nix 环境配置如果没有代理配置时间相当长，并且一些 nix 包没有 arm64 架构的支持。这里配置一个 Docker 环境来使用。

# 构建 Docker 镜像

请先安装好 Docker 环境并将用户添加到 Docker 用户组中。

以 Debian 系统为例。

```bash
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker $USER

# 刷新用户组或者重启系统
newgrp docker
```

clone 当前项目。

```bash
git clone https://github.com/chenchongbiao/rsdk-docker.git
cd rsdk-docker
docker build -t rsdk-docker .
```

-t 后面参数为 镜像名，也可自行修改。

镜像基于 Debian 12，已将 apt 源修改为阿里云镜像源，可自行修改。

# 运行

安装运行辅助脚本

```bash
./rsdk-docker install
```

运行容器

```bash
rsdk-docker
```

该脚本默认运行的镜像和容器名均为 rsdk-docker，在容器没有创建时或者容器被停止时创建容器，如果已经存在容器会直接进入到创建好的容器，修改了 Dockerfile 后需要运行新容器，请删除旧容器。

```bash
docker rm -f rsdk-docker
```

容器运行后默认将用户 home 目录与容器内部 rsdk 用户的 home 目录做映射。

clone rsdk 源码。

```bash
git clone --recurse-submodules https://github.com/RadxaOS-SDK/rsdk.git
```

容器内运行

```bash
cd rsdk
rsdk-docker
```

# 构建 RadxaOS 镜像

rsdk 文档，https://radxaos-sdk.github.io/rsdk/cmd/rsdk-build.html

在 rsdk 源码目录下执行

## Dragon Q6A

```bash
rsdk build radxa-dragon-q6a noble gnome -T --debs debs --debug -m https://mirrors.aliyun.com -M https://mirrors.hust.edu.cn/radxa-deb/
```

位置参数 radxa-dragon-q6a 为产品名，对应 rsdk/src/share/rsdk/configs/products.json 文件，product 字段。

位置参数 noble 为发行版的代号，noble 对应 Ubuntu 24。

位置参数 gnome 对应安装的桌面，rsdk/src/share/rsdk/build/mod/packages 下有对应的安装桌面 Gnome Kde Xfce，窗口管理器 i3 Sway，如果需要使用命令行版本，指定为 cli 即可。

-T 指定测试源，对应 https://github.com/radxa-repo 添加了 -test 的仓库，部分仓库没有 release 源，需要指定 -T 参数。

-m 指定发行版的镜像源。

-M 指定RadxaOS 的镜像源。

--debs 指定额外添加的 deb 包所在的目录，如果有一些定制的 deb 包，在源里没有，可以将 deb 包，放入 debs 目录中，并用该参数指定。

在构建完成后查看 rsdk 目录下的 out 目录，根据构建的参数不同生成对应目录，上面参数对应的目录为

```bash
radxa-dragon-q6a_noble_gnome
```

```bash
rsdk@8e35f30468b0:~/radxa/rsdk$ ls out/radxa-dragon-q6a_noble_gnome/
build-image  config.yaml  debs  manifest  output.img  rootfs  seed.tar.xz
```

output.img 就是构建好的镜像。

有时候构建不顺利，我们需要删除缓存的目录重新构建。

```bash
sudo rm -rf out/radxa-dragon-q6a_noble_gnome
```

部分时候会产生错误。

例如：

```bash
rsdk@8e35f30468b0:~/radxa/rsdk$ sudo rm -rf out/radxa-dragon-q6a_noble_gnome
rm: cannot remove 'out/radxa-dragon-q6a_noble_gnome/rootfs/boot/efi': Device or resource busy
```

这里是 efi 目录被挂载在分区，需要手动卸载目录。

```bash
sudo umount -l out/radxa-dragon-q6a_noble_gnome/rootfs/boot/efi
```

此时再删除目录

```bash
rm -rf out/radxa-dragon-q6a_noble_gnome
```

默认情况下，rsdk假定运行在512字节扇区存储上，构建 512B 系统镜像。如果需要 UFS 启动的镜像需要添加 -s 参数。

删除前面构建的缓存，重新构建

```bash
rm -rf out/radxa-dragon-q6a_noble_gnome
```

```bash
rsdk build radxa-dragon-q6a noble gnome -T --debs debs --debug -m https://mirrors.aliyun.com -M https://mirrors.hust.edu.cn/radxa-deb/ -s 4096
```
