---
title: Ubuntu 13.04 gcc 版本降级
date: 2013-05-30
tags:
    - GCC
categories:
- Ubuntu
---

遇到的一个问题：

在ubuntu中安装完virtualbox，启动时出错，按照提示执行：
`sudo /etc/init.d/vboxdrv setup`

再模块加载时出了一个错：
```
* Modprobe vboxdrv failed. Please use 'dmesg' to find out why.
```
查看log，`/var/log/vbox-install.log`，怀疑是gcc的问题

遂将gcc版本升级为4.7，再次执行
```
sudo /etc/init.d/vboxdrv setup
```

时成功通过，并启动。然后又将gcc版本降为4.4。

<!--more-->

ubuntu13.04 的 gcc 版本是 4.7.3 的，防止以后编译时因版本太高而出现的编译错误，将版本降为 4.4.

查看版本：
```shell
gcc -v
```

安装gcc4.4：
```shell
sudo apt-get install g++-4.4-multilib gcc-4.4-multilib
```

注意软链：
```shell
ls /usr/bin/gcc* -l
ls /usr/bin/g++* -l
```

修改软链:
```shell
cd /usr/bin/
sudo mv gcc gcc.bak
sudo ln -s gcc-4.4 gcc
```

同样的修改g++：
```shell
sudo mv g++ g++.bak
sudo ln -s g++-4.4 g++
```

再次查看版本号，OK
