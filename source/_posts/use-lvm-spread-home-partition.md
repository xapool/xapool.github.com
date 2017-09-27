---
title: 采用 LVM 扩展 Home 分区
date: 2016-07-05
tags:
    - LVM
categories:
    - Ubuntu
---

电脑是双系统，从windows下压缩出了部分空间，来扩展ubuntu的home分区

## 创建lvm
`sudo apt-get install lvm2` 


`sudo fdisk /dev/sda`,新建分区后，输入`t`，输入要改变分区类型的分区号，输入`8e`，最后`w`保存。  

`sudo partprobe` 重读分区表,此时可能需要重启一下，要不下面一步会提示not found.

`sudo pvcreate /dev/sda4`  创建物理卷PV，让刚刚的分区可用

<!--more-->

`sudo pvdisplay` 查看PV 

`sudo vgcreate ext_vol /dev/sda4` 创建逻辑卷组VG，创建完毕之后，可以在/dev/下面看见设备

`sudo vgdisplay` 查看VG  

`sudo lvcreate --name home --size 48G ext_vol` 创建逻辑卷分区LV，创建完毕之后，就可以在/dev/ext_vol/下看见分区了，然后这个分区就可以操作了
或者`sudo lvcreate --name home -l +100%FREE 48G ext_vol`,使用全部空间

`sudo lvdisplay `

`sudo mkfs.ext4 /dev/ext_vol/home` 格式化

然后就可以挂载使用了

## 迁移home分区
进入rescue mode模式，把原先的home分区挂载到/home目录下，把`/dev/ext_vol/home`挂载到/home1目录下，操作前要让分区可写`mount -o remount rw /`,然后`cp -afR /home/* /home1`,最后修改`/etc/fstab`自动挂载。

## 将原先的home分区也添加到lvm中
* 修改分区类型为8e
* 重载分区表
* 格式化
* 创建PV
* `sudo vgextend ext_vol /dev/sda8` #扩展逻辑卷组ext_vol
* `sudo lvextend -l +100%FREE /dev/ext_vol/home` 扩容LV的home分区，使用全部的VG空间
* 再次进入rescue mod模式下，`resize2fs /dev/ext_vol/home`


## 参考
* [Linux LVM硬盘管理及LVM扩容](http://www.cnblogs.com/gaojun/archive/2012/08/22/2650229.html) 
* [Ubuntu Server上的LVM配置](http://www.cnblogs.com/yasmi/articles/4835644.html)


