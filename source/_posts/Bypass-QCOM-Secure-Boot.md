---
title: Android 安全引导机制分析和绕过测试
date: 2017-09-30 12:44:31
categories:
    - Android
tags:
    - Secure Boot
---

上半年为了学位写了一篇论文，今天把它转成了 markdown 格式，便于分享。全文在我的 [Wiki里](https://github.com/HackerOO7/hackeroo7.github.com/wiki/Bypass-QCOM-Secure-Boot)，算是全文吧，去除了很多论文必须的废话。并把其中的干货拿出来放到这里。 

文章对高通的安全引导机制进行了简单分析，并在小米一款机器上综合漏洞成功绕过了其安全引导机制,达到自由修改系统分区的目的。

<!--more-->

## Android安全引导流程和组成
### Android安全引导流程

一台 Android 设备是由硬件和软件组成，当按下开机键时系统从硬件到软件，在到最后进入 Android 系统，是一个完成的引导过程。以高通为例，在一个常规的引导过程中，CPU 引导芯片代码 PBL（Primary Boot Loader，类似于 x86 的 BIOS，有时也被成为 BootROM）从预定义的地方（固化在 ROM）开始执行，PBL由高通做好后烧写在芯片中，不可更改，是 RoT（Root of Trust，信任根）。使用烧录在fuse中的根公钥校验并加载引导程序 SBL1（Secondary Boot Loader），跳转到 sbl1 执行，SBL1 加载校验 APPSBL（aboot），最后 APPSBL 加载校验 boot 分区[^15]。内核启动后，会通过内核中的 dm-verity[^16] 功能模块校验系统分区的完整性。这样就完成了整个系统的安全引导。整个流程如图所示[^17]：

![secureboot\_flow](/media/image2.png "安全引导流程")

目前 Android 一个完整的校验过程，分为两部分：

1. 一分部是官方的 verified boot，由内核中的 dm-verity 来确保 system 分区没有经过被篡改

2. 另一部分是针对于不同设备的引导加载程序的安全引导来验证最终 boot 镜像的完整性。这两部分共同建立了一个从 bootloader 到系统镜像的信任校验链

### Android安全引导组成
#### 引导加载程序的安全引导

这个过程是一个安全认证校验链，都是由上一阶段的程序加载校验下一阶段的要执行的程序，通过签名校验机制，来确保系统不被经过任何形式的篡改，只执行制造商的固件。此过程是特定于设备的，通常通过使用不可更改的特定于硬件的密钥来实现被“烧录”（写入只写存储器）到设备中。该密钥用于验证每级的引导加载程序到最终boot镜像的完整性。

高通的 bootloader 是开源项目，在 Android 代码树的 `bootable/bootloader/lk` 下可以看到它的代码。是针对特定的主板与芯片编写的，并不是Android操作系统的一部分。由于 SBL 代码是闭源代码，分析起来是一个复杂的过程。论文在分析研究引导加载程序的安全引导过程中只从 APPSBL 开始进行分析。

Bootloader 是 OEM 厂商或者运营商加锁和限制的地方。当 bootloader 上锁后就不允许在非解锁状态下对手机固件进行修改或者刷第三方系统。这些限制取决于 OEM 和运营商的具体决策，可能会有所不同，但普遍都会采用密码学的签名校验机制来阻止设备被刷机或者执行未经合法签名的代码。如果用户想要刷机就需要先对 bootloader 进行解锁。现 OEM 都会采用专门的机制，比如需向官方申请解锁码，申请通过后得到解锁码才可以解锁设备。设备解锁后 bootloader 将不再对 boot 和 recovery 分区进行签名校验，也就是不在进行安全引导，允许进行刷机和清除用户数据等操作。

后面的章节还将会针对高通的 LK 的签名和校验
机制进行解剖分析，研究具体的安全保护措施，分析存在的安全缺陷和隐患。

#### Verified Boot

从版本 4.4 起，Android 支持使用 Linux 的 Device-Mapper[^18] 框架中的 dm-verity 功能进行验证启动。Dm-verity 是为块完整性检查而设计开发，使用加密散列树提供块设备的透明完整性检查。它可以验证每个设备块在从磁盘读取时的完整性，如果块检出，则读取成功;
如果没有，读取会产生 I/O 错误，就好像块被实际损坏了一样。在 Android 中用来保护系统重要分区如 system 分区或 vendor 分区的完整性。系统分区被挂载为只读模式，不再允许被挂载为读写模式。校验系统分区时使用的密钥在 boot 镜像的 ramdisk 中。

论文后面的章节还将会继续分析 Verified Boot 在 Android 上的具体实现，研究存在的安全缺陷和隐患。

## Android安全引导机制及缺陷分析
### 引导加载程序引导机制分析
#### user keystore校验漏洞挖掘

Bootloader 序是一种专门的，特定于硬件的程序，当设备首次通电（ARM 设备复位时）执行。其目的是初始化设备硬件，提供最小的设备配置接口，然后找到并启动操作系统。引导设备通常需要经历不同的阶段，这涉及每个阶段的单独的引导加载程序，本文只分析 APPSBL（aboot）加载引导程序。Android 引导加载程序通常是专有的，特定于芯片 SoC 的系统。设备和 SoC 制造商在其引导加载程序中提供不同的功能和级别的保护。

在整个校验链中由aboot来提供验证 boot.img 的完整性，其开源代码 LK 可在 Code Aurora Forum 下载。在 LK 中有两个可用于校验的不同的密钥：

- 一个是 `oem_keystore`，被编译到 aboot 中，定义在 `platform/msm_shared/include/oem_keystore.h`

- 一个是 `user_keystore` 存储在 keystore 分区中

引导过程中始终尝试使用 OEM keystore 来验证 boot.img 和 recovery.img。但在 keystore 分区不为空的时候，会使用 OEM keystore 对其签名进行验证，如果验证通过，将从里面读取 `user_keystore`，然会用其验证 boot.img 和 recovery.img。 

`user_keystore` 包含了用于验证的 RSA 公钥。以 CAF 代码 `LA.BR.1.3.2_rb3.14`分支为例，整个基本函数和逻辑执行如图所示：

![boot\_verify\_flow](/media/image3.png "bootimage 验证流程")

最终调用的 `verify_image_with_sig()` 采用的是 `user_keystore`中的公钥进行校验。而 `user_keystore` 的值由 `boot_verifier_init` 调用 `read_oem_keystore`，将
`oem_keystore` 赋值 `user_keystore`。接着对 keystore 分区进行验证，如果验证通过，则将分区中的数据赋值 `user_keystore`。这样就完成了对 user
keystore 的利用。

但是 `read_user_keystor()` 方法中调用 `verify_keystore` 验证 user keystore 时，在 `if-else` 判断中的 385 行因缺少花括号，导致无论验证成功与否，都会 `user_keystore` 进行赋值。具体代码如图所示：

![issue\_code](/media/image4.png "问题代码")

这样就造成了一个明显的安全漏洞，user keystore 不用经过 OEM 的签名也可以用于校验 boot 或 recovery 镜像。我们只需要自己签名生成 keystore.img 通过其它漏洞写入手机就可以绕过安全引导机制。

#### 解锁标记位的保护分析

在高通的分区表中，有一个名为 devinfo 的分区，大小 1024K。在 `app/aboot/devinfo.h` 中定义了其数据结构，包括了 `is_unlocked` 解锁状态标记位；`is_tampered` 篡改标记位等。通过 `fastboot oem device-info` 命令可以获取相关信息。

在 LK 启动时，通 `aboot\_init()->read_device_info(&device)->read_device_info_mmc()` 读取，若 `is_unlock` 为 true，就跳过校验，允许执行 flash 命令等。使用 `fastboot oem unlock` 命令后，会通过 `write_device_info_mmc(&device)` 对 devinfo 分区的标记位进行操作。

高通源代码中并为对该标记位进行加密签名等保护，直接修改标记位就可以使用对手机的解锁。但是在 OEM 的实现中，大多都会对该分区进行保护，修改分区名和使用加密签名等手段，保证分区不被非法篡改。

但 Android 碎片化的存在，厂商技术的参差不齐，依然有很多设备未对该部分进行修改，留下了安全漏洞。

#### 高通下载模式分析

高通有着自己的下载协议，一般在设备生产的时候通过该协议烧录固件。在 lk 代码 `aboot_init` 中，通过监控按键等操作可以选择到进入到不同的模式，如 recovery 或 
fastboot 模式等。代码中默认当同时按下音量上下键时，则进入到 DLOAD 模式，也就是下载模式。然后通过高通专有的 sahara 或 firehose 协议工具进行固件的下载更新[^19]。

同样在 `kernel/drivers/power/reset/msm-poweroff.c` 中相关代码由宏 `CONFIG_MSM_DLOAD_MOD` 控制，可开启或关闭是否可以通过  `adb reboot edl/dload` 命令重启进入到下载模式。

高通的升级工具及协议在下载的过程中，并不会对固件进行任何的校验，如果下载了错误或损坏的固件，则直接会让设备变砖。但是，厂商为方便开发、生产、售后等需求，并不会完全关闭掉高通的下载模式，有的会留下隐蔽的接口来进入到该模式。

### Android的Verified Boot
#### Dm-verity概述

Dm-verity 使用加密散列树提供块设备的透明完整性检查，每个块以 4k 的大小来划分，都有一个 SHA256 的值。树中的每个节点是加密 hash，其中叶节点包含物理数据块的 hash，并且中间节点包含其子节点的 hash。因为根节点中的哈希是基于所有其他节点的值，所以只有根哈希需要被信任才能验证树的其余部分。对任何一个节点块的改动都破坏整个加密 hash。整个哈希树的结构如图所示：

![dm-verity\_hash-tree](/media/image5.png "哈希树")

验证时使用包含在 boot 分区中的 RSA 公钥来执行。设备块在运行时通过计算读取的块的哈希值并将其与散列树中的记录值进行比较来检查。如果值不匹配，则读取操作将导致 I/O 错误，指示文件系统已损坏。因为所有的检查都是由内核执行的，所以启动过程需要验证 boot.img 的完整性，以便验证引导工作。

在 Android 中被校验的分区始终挂载为只读状态，只能在 OTA 块设备升级时才可做更改。其它任何对分区的操作都会破坏分区的完整性，比如 root 等操作。

#### 在Android中的实现方法

Dm-verity device-mapper 目的最初是为了在 Chrome 操作系统中实现验证启动而开发的，并且已经在 Linux 内核的 3.4 版本中集成。它使用 `CONFIG_DM_VERITY` 内核配置项来进行开关。

但 Android 的具体实现方式和 Chrome 有所不同。用于验证的 RSA 公钥在 boot 镜像的 ramdisk 中，文件名是 `verity_key`，用于验证目标设备的 root
hash 签名。被验证的目标分区，有着一个包含了哈希表和它自身签名的元数据块，被附加到镜像的最后。如果要启用对某一分区的校验，需要在 ramdisk 中的 fstab 文件中对特定设备添加 verify 标签[^20]。

当系统启动过程中，检测到该标签，则会使用 `verity_key` 公钥加载校验该分区最后附加的元数据。如果签名验证通过，则文件系统管理器解析 dm-verity 映射表，并将其传递给 Linux 设备映射器，设备映射器使用映射表中包含的信息来创建虚拟的 dm-verity 块设备。然后将该虚拟块设备安装在 fstab 中指定的安装点上，代替相应的物理设备。因此，所有读自底层物理设备的数据都会用预先生成的散列树进行透明验证。对设备任何修改或添加文件，甚至将分区重新挂载为读写都会导致完整性验证和 I/O 错误。虚拟设备的挂载如图所示：

![dm-verity-virutal-block-device-mounted](/media/image6.png "虚拟设备")

但是因为具体的实现方式原因，用于校验的 RSA 公钥 `verity_key`，直接被放在了 ramdisk中。这给了替换该公钥文件进行攻击的可能性。而且对目标设备是否进行校验，也直接用明 verify 签进行判断，这也是一个明显的安全缺陷。

#### 启用Verified Boot

在谷歌的官方文档描述中，要完全启用 verified boot，除了要配置整个编译系统开启相关选项，还需要引导加载程序实现相关对boot镜像的完整性校验。上节已经针对高通 SoC 在这块的实现进行了分析研究。

AOSP 源代码中，开发 key 包括公钥和私钥，它们位 `build/target/product/security/` 目录。用来给 boot/recovery/system 镜像签名，以及验证 system 分区的真实性元数据块表[^21]。在启用 verified boot 时需要生成自己的公私钥，但某些机型设备依然是使用的默认的密钥，这相当于是导致了密钥的泄露，对设备来说没有任何安全性可言了。

## 漏洞利用测试和安全加固
### 利用漏洞绕过安全引导
#### 攻击方法的设计

在上一章中分析了存在安全缺陷和漏洞。利用自签名的 user keystore 和 boot/recovery 镜像，并且在 boot 的 ramdis k中移除对 system 分区的进行校验的 verify 标记。或者替换 ramdisk 中的verity\_key，并对 system 镜像进行签名。刷写到手机中，就能实现绕过某些机型的安全引导机制，对设备进行自由修改。

但是在设备处于 LOCKED 状态时，是无法通过 fastboot 进行刷写操作的。但是 OEM 一般都会预留自己的下载模式，比如三星的 ODIN，联发科的 SP Flashtool。而高通 SoC 则是上一章中分析到的 dload/edl 模式，该模式在固件镜像下载过程中并不做任何的校验，直接能刷写进去。

本文测试机器是 红米Note3 全网通版，系统的版本为 V7.2.3.0，Android 版本 6.0,内部开发代号 kenzo。Kenzo 在几次的升级后，逐渐关闭了按键进入，`adb reboot dload/edl` 重启进入下载模式的途经，开启了 dm-verity，来保护手机不被破解和刷机。但是通过IDA
Pro逆向分析 aboot 分区中的 emmc_appsboot.mbn 引导加载程序镜像时，发现了 `reboot-edl`的命令。如图所示：

![reboot-edl\_ command](/media/image7.png "小米自己添加的命令")

正如其命名一样，是标准 fastboot 协议是不支持此命令的，为此需要修改 fastboot 源码。fastboot 源代码在 AOSP 源码树  `system/core/fastboot` 中。分析 fastboot 源码，命令最后是通过 `fb_queue_command` 发送给 bootloader，修改代码添加对该命令的支持。然后就能成功的重启到 edl 模式。核心代码示例如图所示：

![code](/media/image8.png "添加命令支持")

#### 漏洞利用测试过程

整个测试过程是为了验证本文对安全引导机制进行分析研究后挖掘出的相关安全漏洞，达到在设备处于 LOCKED 状态时，篡改并修改设备，绕过 Android 安全引导机制。过程如下：

1. 生成自己的公私钥对

2. 利用公私钥对生成并签名 keystore.img

3. 对 boot.img 重新打包，移除 system 分区 verify flag

4. 对 boot.img 进行重新签名

5. 使用修改后的 fastboot，执行` fastboot reboot-edl`进入下载模式

6. 使用 emmcdl[^22] 工具分别刷入 keystore.img boot.img

若设备能成功开启，则证明完全绕过了 Android 的安全引导机制。System 分区也不在不挂载为虚拟设备，而是真实的物理设备块。如图所示：

![屏幕快照 2017-03-24 20.05.29](/media/image9.png "真实设备的挂载")

在手机预装行业中，还会对 system 分区镜像进行篡改，然后利用上面的过程也刷写到手机中。同样也可以修改 devinfo 分区的标记位，强制修改手机的状态。这样有了一套对该机型进行刷机预装的方案。

## 参考

[^1]:  N.Elenkov. Android Security Internals[M]. No Starch Press, 2015.

[^2]:  [IDC. Smartphone VendorMarket Share[EB/OL].](http://www.idc.com/promo/smartphone-market-share/vendor)
    
[^3]:  [DCCI. 2016年中国Android手机预装软件调查研究报告](http://www.dcci.com.cn/dynamic/view/cid/2/id/1310.html)

[^4]:  [PanguTeam. 利用漏洞解锁锤子T1/2手机的bootloader](http://blog.pangu.io/%E5%88%A9%E7%94%A8%E6%BC%8F%E6%B4%9E%E8%A7%A3%E9%94%81%E9%94%A4%E5%AD%90t12%E6%89%8B%E6%9C%BA%E7%9A%84bootloader/)

[^5]:  J.J.Drake. Android hacker’s Handbook[M]. TURING,2014.

[^6]:  [Google. Android Open Source Project](https://source.android.com/)
    
[^7]:  [Google. Verified Boot](http://source.android.com/security/verifiedboot/index.html)

[^8]:  [Linux kernel source tree. dm-verity](http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/device-mapper/verity.txt)
    
[^9]:  [Code Aurora Forum. (L)ittle (K)ernel based Android bootloader](https://www.codeaurora.org/blogs/little-kernel-based-android-bootloader/)

[^10]:  Mediatek. Security Feature Introduction

[^11]:  [LWN. Android Verified Boot](https://lwn.net/Articles/638627/)

[^12]:  [Code Aurora Forum. LK source](https://www.codeaurora.org/cgit/quic/la/kernel/lk/)
    
[^13]:  [Qualcomm. Qualcomm Technologies Secure Boot whitepaper](https://www.qualcomm.com/media/documents/files/secure-boot-and-image-authentication-technical-overview.pdf)

[^14]:  [Google. Android Compatibility Definition Document](http://static.googleusercontent.com/media/source.android.com/zh-CN//compatibility/6.0/android-6.0-cdd.pdf)

[^15]:  [Tecent. Android系统典型bootloader分析](https://security.tencent.com/index.php/blog/msg/38)

[^16]:  [Milan Broz. dm-verity: device-mapper block integrity checking target](https://code.google.com/p/cryptsetup/wiki/DMVerity)

[^17]:  [laginimaineb. Unlocking the Motorola Bootloader](http://bits-please.blogspot.jp/2016/02/unlocking-motorola-bootloader.html)

[^18]:  [Red Hat Inc. Device-Mapper Resource Page](https://www.sourceware.org/dm/)

[^19]:  [CSDN. 高通 MSM8K bootloader 之二：SBL1](http://blog.csdn.net/fybon/article/details/37565227)

[^20]:  [Google. dm-verity](http://source.android.com/devices/tech/security/dm-verity.html)

[^21]:  [CSDN. QualComm Android boot recovery vertify](http://blog.csdn.net/a04081122/article/details/53522705)

[^22]:  [Github. emmcdl](https://github.com/binsys/emmcdl)

