---
layout:     post
title:     编译极路由的OpenWRT固件
category:
    - Openwrt
tags:
    - Hiwifi
---

虽然被坑了，看习惯了塑料外壳的个子老大的路由器，看一下小巧金属外壳的hiwifi还是很养眼的。从来没有接触过路由器固件的相关信息，现在有机会了，了解一下还是很好的，弄个下载机什么的。 

## 吐槽一下
极路由真是太坑爹了，照着小米学，学得不到家。最后真正成了欺骗用户了，虽然自己也是受害者。 
知乎上有很好的回答，可惜近日已经删除了，不过还是能看出点什么的。

* [如何评价极路由公司 2013 年 11 月发布的「极贰」路由器？](http://www.zhihu.com/question/21971379)
* [为什么网络上极路由的负面评价那么多？](http://www.zhihu.com/question/21996327) 

虽然被坑了，看习惯了塑料外壳的个子老大的路由器，看一下小巧金属外壳的hiwifi还是很养眼的。 
从来没有接触过路由器固件的相关信息，现在有机会了，了解一下还是很好的，弄个下载机什么的。 

## 编译hiwifi的openwrt固件

### 环境准备
至于环境就没啥好准备的了，自己的电脑编译环境还是很全的。 
不过，hiwifi的代码是用svn管理的，从没有用过svn，还是先装一个。 

    sudo apt-get install subversion git

### 获取源码
    svn co https://code.hiwifi.com/svn/hiwifi

遇到提示输入密码时，直接打回车，然后出来输入用户名的提示，输入极客社区帐号email，再输入密码。  

### 编译
    cd hiwifi/trunk
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make package/symlinks 

#### 使用默认的编译选项
    make HC6361_defconfig 

#### 也可以自定义编译选项（这才是精华所在）
    make menuconfig
可以把openssh、python、pythonopenssl、unbound等，都配置进去。 

最后： 

    make -j4

如果出错，要查看详细的编译信息可以使用`V=s`参数: 

    make -j4 V=s

开始漫长的编译。 

### 制作成recovery.bin
        wget -O rom.bin http://updaterom.ikcd.net/upgrade_file/HC6361-0.775.784s_130802-131633-96d56f0c
        dd if=rom.bin of=uboot.bin bs=1k count=128
        cat uboot.bin bin/ar71xx/openwrt-ar71xx-generic-tw150v1-squashfs-sysupgrade.bin >recovery.bin

上面的链接404，暂时的解决方法是跳过wget，手动下载官方的一个[recovery.bin](http://bbs.hiwifi.com/thread-7710-1-1.html)，重命名为rom.bin然后执行下面的命令提取uboot.bin。 

### 刷机
* 去这里下载[官方开源版本固件](http://bbs.hiwifi.com/thread-7710-1-1.html)，解压
* 将上一步生成的recovery.bin替换目录中recovery.bin
* 用网线将极路由 LAN 口与电脑网口相连
* 将电脑网络接口 IP 设置为 192.168.1.88/255.255.255.0
* 用尖锐物按住极路由 RESET 不放，给极路由加电
* 等待电脑上 tftpd 出现传输 recovery.bin 进度条完成后，松开 RESET
* 极路由面板灯进入跑马灯状态，跑完后，系统自动重启，刷机完成

## 参考，扩展阅读
* [极路由的正确玩法](http://chaopeng.me/blog/2013/10/28/hiwifi.html)
* [OpenWrt安装goagent实例教程](http://www.openwrt.org.cn/bbs/forum.php?mod=viewthread&tid=14193)
* [Openwrt架设DNS转发器，解决污染问题 ](http://blog.csdn.net/conupefox/article/details/8557253)
* [openwrt-hiwifi](https://code.google.com/p/openwrt-hiwifi/)
