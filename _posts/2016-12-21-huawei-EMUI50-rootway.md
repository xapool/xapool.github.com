---
layout:     post
title:      华为 EMUI5.0 root 方法
category:
    - Android
tags:
    - root
---

## 华为EMUI5.0 获取 root 方法

华为EMUI5.0 目前 root 方法是刷TWRP，然后使用 TWRP 刷入 Chainfire 的 SuperSU 或者 phh 的 Superuser。你需要支持 Nougat 版本的 TWRP，但是在刷入 Chainfire 的 SuperSU 过程中会直接导致设备重启，因为 SuperSU 的工作原理是在采用 systemless 时无论在刷入还是开机过程中都需要 mount 一个 loop 设备 su.img，猜测是华为的 kernel 做了限制，当 mount 一个 loop 设备时设备会直接重启最后进入到 erecovery.  

使用 phh 的 Superuser 则无此问题，但是默认提供的 Superuser 版本是开启了 dm-verity 和 forceencrypt，因为 dm-verity 的存在导致获取到的 root 权限是不完整的，无法对 system 分区做任何修改，所以自己修改了一个 Superuser-r275 的版本，关闭了这两个开关.  

同时也借鉴 phh 的做法，将 SuperSU 相关 su 文件放到 ramdisk 下并移除 su.img 的创建和挂载过程，最后对 sepolicy 重新打 patch，这部分脚本完全来自 phh 的 Superuser. 但是因此也失去了 SuperSU 特有的一些功能，例如 frp 和 app 内更新二进制的功能，升级版本只能通过重刷来解决.  

至于最终到底是不是华为 kernel的限制，还是需要等华为开源时，才能最终解决.

## FRD-AL00 root 所需文件

自己测试的机器是荣耀8 FRD-AL00 版本，需要到的文件：  

* [frd-twrp](https://mega.nz/#!XR91RJrL!zKgVWf8WvBGlP3n0Aip59tT1Z3l8C2Lh6smsijw3wQQ)
* [SuperSU](https://mega.nz/#!2Y8CgIDa!RvUXD1dJKYA0xBPHRfzVy0wj_CZXPw-bMdZJLpypHUY)
* [phh's Superuser](https://mega.nz/#!PYshWCZZ!SwrpezliztIFKooEY5Np7zT2m7yWmp6QtjlTExntakU)

该 recovery 应该也同样适用于华为P9,或者其他的 hi3650 机器.

