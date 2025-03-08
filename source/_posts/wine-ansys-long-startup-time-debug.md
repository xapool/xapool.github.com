---
title: Wine：Ansys-16 启动时间过长问题分析
date: 2022-05-28 10:34:29
categories:
    - Wine
tags:
    - wine
---

以前工作时的一些笔记，现整理后分享出来。某些知识或问题可能已经过时，但是主要分享的是调试技巧。本文是分析 Ansys 16 在 WINE 下启动时间过长的问题，通过调试找到问题根源，最终通过引入 esync/fsync 补丁而解决，老鸟可略过。

<!--more-->

## 问题的描述与初步分析
启动 Ansys 的 launcher 程序：
```bash
$ WINEARCH=win64 WINEPREFIX="~/apps/ansys-16.0" wine "C:\Program Files\ANSYS Inc\v160\ansys\bin\winx64\launcher160.exe"
```

launcher160.exe 会启动 wish.exe 与 ansysli_client.exe 两个进程，wish.exe 进程启动后进入主界面经历的时间过长，中间疑似 block 在某处，程序没有进一步向下执行。

添加 `WINEDEBUG` 频道，根据日志判断，wish.exe 进程阻塞在 socket `select()` 函数，阻塞超时时间为 60s。进一步根据日志上下文分析，ansysli_client 进程创建了一个非阻塞的 socket 服务端，wish.exe 进程做为一个 socket 客户端进行连接，但是服务端无响应，所以 wish.exe 调用 `select()` 函数进行轮询，等待服务端的响应。如图所示，进程 00b8 为 wish.exe 进程，0118 为 ansysli_client 进程。00b8 等待 23s 后，服务端才响应请求：

![ansysli socket ](/media/wine_ansys_image1.png "Ansys socket")
 
在 Windows 下安装 ansys，得知 ansys 版本是破解版，通过修改 ansysli_client.exe 用来达到此目的。修改后的 ansysli_client 作为一个本地的许可证认证服务端，来接收客户端的证书认证请求。因此，直接修改 select 函数的超时时间是不可行的（经实际测试，也确实是不可行的，直接提示连接不上许可证认证服务端）。

继续分析，直接启动 ansysli_client.exe：
```bash
$ WINEARCH=win64 WINEPREFIX="~/apps/ansys-16.0" wine "C:\Program Files\ANSYS Inc\Shared Files\Licensing\winx64\ansysli_client.exe" -nodaemon -demo -log "C:\users\ansys\Temp\.ansys\demo.log"
```

查看生成 demo.log 文件，如图：

![ansysli client wine log](/media/wine_ansys_image2.png "ansysli_client log")
 
在日志 "Ready to accept connections." 行距上一条日志，时间相距 24s，而 windows 下的日志文件如图，只有 1s:

![ansysli client windows log](/media/wine_ansys_image3.png "ansysli_client windows log")

进一步测试，无论 wineserver 是否常驻后台，对 ansysli_client socket 服务端准备就绪并无影响。可得出结论，是作为 socket 服务端 ansysli_client 准备就绪时间过长，从而也导致 wish.exe 进程阻塞。

## 深入分析
在 Windows 下使用 API Monitor 监控 ansysli_client 的所有调用，创建 socket 服务端的线程1在调用 ` IOCTL_AFD_START_LISTEN ` 后，接着调用 NtWaitForSingleObject 进入等待状态，等待锁的释放，如图： 

![ansysli client wait](/media/wine_ansys_image4.png "ansysli_client NtWaitForSingleObject")

另一个线程 4 持有锁，不停的调用 NtWaitForSingleObject 与 NtReleaseMutant 将近 500w 次后才释放此锁，线程1获取到锁后进一步执行，调用 `IOCTL_AFD_SELECT` 开始接受客户端的请求。

![ansysli client release lock](/media/wine_ansys_image5.png "ansysli_client IOCTL_AFD_SELECT")
 
经调试对比，在 Wine 下的进程执行流程与 Windows 下并无区别。问题出在 4 线程，在 Wine 下执行耗时过长。此时还未怀疑同步原语性能开销的问题。

下面开始才是重点，对此线程进一步进行行为分析，使用 relay 逐个排除开销大的函数，只剩下 NtWaitForSingleObject 与 NtReleaseMutant 两个函数了，推测可能就是 Wine 在多线程超频繁调用同步原语时性能表现差。此时才意识到是同步原语性能开销问题。

## 问题解决
怀疑是 WINE 同步原语开销过大的问题，直接使用 wine-staging 分支，开启 WINEESYNC 后，4线程执行时间差不多 2-3s，但依然比不上 Windows 下 1s 的性能表现。问题算是得以解决。

### WINEESYNC
wineserver 作为应用启动后的守护进程，提供了 ntdll 中的同步原语功能，将 Windows API 转换为了 POSIX 的 `select()` 调用。但 linux 的 select 机制本身性能就不是很好，如果一个线程超频繁的使用同步原理，那么性能就堪忧了。

而 Esync 是 eventfd-based synchronization，基于 eventfd 的同步。在 “用户空间” 中执行所有同步操作，而无需通过 wineserver，这提高了许多应用的性能，尤其是那些严重依赖多线程的游戏。Esync 依赖于内核的 `eventfd()` 功能，该功能需要设置系统文件描述符上限，并且事件密集型应用程序存在可能耗尽文件描述符的问题。一旦 Esync 打开的文件描述符已经超过上限，同步就会失败，Wine 程序就会卡住，或者崩溃。所以，通常需要把系统文件描述符上限修改为最大值。

提供类似优化的还有 Fsync，基于快速用户区互斥锁的同步（fast userspace mutex based synchronization / futex-based synchronization）。由 Valve 实现，作为 esync 的替代方案，比 esync 有着更少的 CPU资 源占用。但要求Linux内核版本 >= 5.17。如果内核不支持 Fsync，默认会使用 Esync。
