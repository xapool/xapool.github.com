---
title: OpenWrt-x86 笔记
date: 2015-03-09
tags:
    - Openwrt-x86
categories:
    - Openwrt
---

此乃 OpenWrt-x86 编译时的笔记，很乱、不够系统，但以后完善

## 目标硬件
* Intel NUC D34010WYK
* 4g 内存
* 60g SSD
* Intel N2230无线网卡

## x86 编译注意事项
* 大内存支持
* 多核心，多线程支持
* sata drive 支持
* 网卡、wifi 驱动的集成
* 对 usb，例如鼠标、键盘的支持
* 编译所有文件系统支持，包括 ext2/ext3/ext4，还有 NTFS，甚至是 LVM；
* 加入一个文本编辑器，例如 vim 或者 nano，因为日常使用中需要用文本编辑器修改各种配置文件；
* 加入所有关于无线网卡的驱动，模块，各种支持程序，
* 一些其他常见应用--蓝牙、加密、PGP、SSL、SSH、VPN、USB支持、3G上网卡

<!--more-->

## Convert OpenWrt raw image
1. `gunzip openwrt.img.gz` 
2. `VBoxManage convertfromraw --format VDI openwrt.img openwrt.vdi`

## Compile
    make menuconfig
    make kernel_menuconfig

## 真机使用注意事项
* 在 bios 中对 ide、sata 的修改  

## 编译流程

### 流程
1. `./scripts/feeds update -a`
2. `./scripts/feeds install -a`
3. 检查编译环境，若可进行编译则生成默认配置 `make defconfig`
4. `make menuconfig` 若有需求，则可以 `make kernel_menuconfig`
5. `make -j32 V=99`，编译过程中会联网下载一些 package  

编译完成的文件，在 bin/x86 目录下，可以烧写到U盘中测试。 

* [how to build](http://wiki.openwrt.org/doc/howto/build)

### 单独编译某个包
```
    make packages/xxx/clean
    make packages/xxx/compile
    make packages/xxx/install
```

## 未完成的工作
* 配置 wifi 热点的自动开启
* 音频、视频的支持
* 电源键的支持
* U盘的自动挂载
* 3g/4g 上网卡的支持
* 对 sata 的支持

* [编译过程和后期的一些配置参考](http://lotors.me/2014/08/16/opcompilepro/)

## Gargoyle 的编译

### 如果有目标硬件
`make FULL_BUILD=ture brcm47xx`  
`make brcm47xx` 是rebuild

### 自由定制
`make custom`，上述命令会自动调用 `make menuconfig`配置菜单，但是第二次执行时就会跳过配置界面，所以要` make FULL_BUILD=true custom`

## 首次配置的方法
设备成功启动后，连接到该 AP 上，telnet 到 `192.168.1.1`,输入 `passwd`，设置密码后，才能使用 ssh 登陆，然后配置网络即可。如果设备启动失败，只有连接显示器查看原因了。 

---------------------------------------------------

## 一些软件的安装

### 安装 luci
```
opkg update
opkg intsall luci
安装完毕记得启动luci
./etc/init.d/uhttpd enable
./etc/init.d/uhttpd start
```

```
opkg install kmod-usb-core
opkg install kmod-usb-ohci          #安装usb ohci控制器驱动
opkg install kmod-usb-uhci     　#UHCI　USB控制器
opkg install kmod-usb2                #安装usb2.0
opkg install kmod-usb-storage     #安装usb存储设备驱动
opkg install kmod-fs-ext3              #安装ext3分区格式支持组件
opkg install mount-utils                #挂载卸载工具
opkg install ntfs-3g                      #挂载NTFS
opkg install kmod-fs-vfat              #挂载FAT
opkg install block-mount
opkg install fdisk    
opkg install usbutils #安装了这个后可以用 lsusb
opkg install pciutils
```

## 具体配置
```
Target System (x86)    #目标平台选择,这里选择X86，如果非x86系统下面需要选择
TargetImages  --->
ext4    #生成.EXT4.IMG文件
[0] seconds to wait befor booting the default entry  #启动不等待5秒
Base system  --->
<*> block-mount  #以后挂载USB用
kernel modules  --->
    Block Devices --->       这项用于支持磁盘
        <*> kmod-ata-core    #支持SATA硬盘
        <*>   kmod-ata-ahci  
        <*> kmod-loop
    Filesystems  --->
        <*> kmod-fs-ext4   
    NativeLanguage Support  --->   #语言支持
        <*> kmod-nls-iso8859-1
        <*> kmod-nls-utf8
    Network Devices  --->   #网卡驱动，必须添加自己需要的网卡驱动
        <*> kmod-macvlan  
    Wireless Drivers  ---> #wifi卡驱动，添加自己需要的
Luci-----
Collection----luci
Translation---luci-i18n-chinese
```

```
Input modules  --->#键盘
         -*- kmod-hid
         <*> kmod-hid-generic
         -*- kmod-input-core
         -*- kmod-input-evdev
```

```
Kernel modules:
    USB Support:
        <*> Kmod-usb-storage
    Filesystems:
        <*> Kmod-fs-ext3
Base system:
    <*> Block-extroot
Utilities:
    Filesystem:
        <*> E2fsprogs
    Disc:
        <*> Fdisk > 
```

```
Processor type and features  --->
    [*] Symmetric multi-processing support
    Processor family (Core 2/newer Xeon)  --->#自行选择处理器平台
    [*] Supported processor vendors  --->#自行选择处理器平台
    (2) Maximum number of CPUs #自行编辑
    [*] SMT (Hyperthreading) scheduler support#超线程支持
    [*] Multi-core scheduler support 
    High Memory Support (4GB)  --->
```

若使用U盘测试，还需配置  

```
Target Images  ---> 
    (/dev/sda2) Root partition on target device (NEW) #修改 /dev/sda2 为 /dev/sdb2
```

------------------------------------------------------------------------------

## 对 freeswitch 的集成
目前的两种方法  

1. 直接把 freeswitch 的源码目录放到 openwrt 的 package 目录中，
2. 做为一个单独的 git 项目，使用该 package 时修改 `feeds.conf` 添加订阅，然后在 `make menuconfig ` 时选择 freeswitch 模块。  

无论这两种方法，都需要在 freeswith 中增加  

* package/Makefile [必备]
* package/patches/ [可选]
* package/files/ [可选]  

patches 目录和files 目录都是可选的，patches 目录通常包括 bug 修复和对可执行文件体积的优化，files 目录通常包括配置文件。  

### Makefile文件
* PKG_NAME -软件包的名字, 在 menuconfig 和 ipkg 显示
* PKG_VERSION -软件包的版本，主干分支的版本正是我们要下载的
* PKG_RELEASE -这个 makefile 的版本
* PKG_BUILD_DIR -编译软件包的目录
* PKG_SOURCE -要下载的软件包的名字，一般是由 PKG_NAME 和 PKG_VERSION 组成
* PKG_SOURCE_URL -下载这个软件包的链接
* PKG_MD5SUM -软件包的 MD5 值
* PKG_CAT -解压软件包的方法 (zcat, bzcat, unzip)
* PKG_BUILD_DEPENDS -需要预先构建的软件包，但只是在构建本软件包时，而不是运行的的语法和下面的 DEPENDS 一样。

### 参考
* [创建软件包](http://wiki.openwrt.org/zh-cn/doc/devel/packages)
* [configure FreeSWITCH to run on their OpenWrt](http://wiki.freeswitch.org/wiki/OpenWrt)
