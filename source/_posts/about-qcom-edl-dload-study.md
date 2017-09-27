---
title: 关于高通 9008 刷机的研究
date: 2015-09-01
tags:
    - EDL
    - DLOAD
categories:
-  Android
---

## 生成所需xml

### GPT 分区 parse_gpt

根据官方 GPT 文件解析出具体的 GPT 的分区信息并生成对应平台的 partiiton.xml 文件，最后通过 ptool.py 生成可刷写的配置文件 rawprogram0.xml、patch0.xml 跟最后的 GPT. 

官方的gpt文件一般需要经过裁剪,一般裁剪成17408字节大小,包括文件头开始的512字节的MBR信息`dd if=gpt.bin of=gpt-new.bin bs=17408 count=1`,然后使用`./parse_gpt gpt-new.bin`,输出在`GPT_DUNP_FILES`中. 

或者在手机中`dd if=/dev/block/mmcblk0 of=/sdcard/gpt-new.bin bs=17408 count=1`,为配合 parse_gpt,大小一般为 17408,34304. 

<!--more-->

### MBR 分区

上面所说的是 GPT 分区的，但是一些老平台的机器依然使用的是 MBR 分区，例如 msm7x30 和 msm8x60 平台

> partition.xml           - Everything begins with this file, which describes the number of 
                          partitions desired, and how many sectors each one should be.
PartitioningTool.py     - translates partition.xml into binary partitions
msp.exe                 - writes binary partitions to SD/eMMC cards using card reader
mjsdload.cmm            - writes binary partitions to SD/eMMC cards using Trace32
msp.py                  - writes binary partitions to a single image file
QPST                    - writes binary partitions to SD/eMMC cards on Target
parseBinaryPartitionFile.pl     - Decodes MBR partition tables. Run: 
                                  "Perl parseBinaryPartitionFile.pl partition.bin" 
                                  to generate the partition information
parseGPT.pl                     - Decodes GPT partition tables

* [eMMC Partition tools usage for msm7x30/msm8x60](http://forum.xda-developers.com/showthread.php?p=31843325)

### ptool.py

`python ptool.py –x partition.xml` 

这些工具源于高通的 modem 源码,当然是闭源的了:

> boot_images/core/storage/tools/ptool/
ptool.py         //分区生成工具 partition =========> rawprogram0.xml
                    Python ptool.py –x partition.xml:
msp.py          //ubuntu使用：根据 rawprogram0.xml进行升级软件工具
singleimage.py　　//根据singleimage_partition_8974.xml生成single boot image: 8974_msimage.mbn, python singleimage.py -x singleimage_partition_8974.xml
lsusb.py       // ls usb
dd.py            // dd command
checksparse.py         //sparse system/cache/userdata image

[checksparse.py的使用](http://kernel-develop.blogspot.com/2012/06/emmc-sparse-image-download-in-msm8x60.html) 

一个整合的工具，包括刷机命令行刷机的 qdload.pl 

* [aries-image-builder](https://github.com/M1cha/aries-image-builder) 

### 文件说明

1. 8x10_msimage.mbn----平台镜像，是个完整的最小系统启动镜像，包括 sbl，tz，sdi，rpm 等必要启动分区和分区表 
2. MPRG8x10.hex----对应平台的串口烧写协议
3. gpt_both0.bin----对应 EMMC 的分区表，因为不同批次的 EMMC 大小有细微差别，这个分区表不包含最后一个分区信息
4. rawprogram0.xml----要烧写的具体文件跟对应的扇区位置
5. patch0.xml----刷机软件根据手机服务端返回的具体磁盘大小打上最后一个分区的补丁、完成分区表头校验的配置文件，没有正确的 patch0.xml 分区表头就不能通过校验，手机也启动不了

8x10_msimage.mbn、MPRG8x10.hex 是通用的并可以在网上直接获取,单让手机进入磁盘模式，只需要 msimage 和 MPRG 即可.

### msimage生成

生成自己的 msimage.mbn,在 msm7k 平台需要 MBR0.bin 和`qcsblhd_cfgdata.mbn/qcsbl.mbn/oemsblhd.mbn/oemsbl.mbn`或者完整的`dbl/osbl`.

在 msm8k 平台后需要 gpt,`sbl1/sbl2/sbl3/rpm/tz`. 并不建议自己生成 msimage，防止成真砖。 

#### win(未验证）

[How to generate the 8660_msimage.mbn](kernel-develop.blogspot.com/2012/05/how-to-generate-8660msimagembn.html) 
[ How to build eMMC flash programmer MPRG7x30.hex and 7x30_msimage.mbn](kernel-develop.blogspot.com/2012/04/how-to-build-emmc-flash-programmer.html)

`emmcswdownload.exe -f 8660_msimage.mbn -x partition_boot.xml -s 16G` 

注意现在新版的 qspt，也只支持由 rawprogram0.xml 来生成 msimage 了。

#### linux

[How to generate the 7x30_msimage.mbn ](kernel-develop.blogspot.com/2012/05/how-to-generate-7x30msimagembn.html) 

`python msp.py -r rawprogram0.xml -d 2048`  
生成 2048Kb,rawprogram0.xml 和其它一些文件如分区 mbr gpt 等是由上面所提到的ptool.py生成.这个 rawprogram0.xml只需要包含生成msimage的必须项即可，可以手动直接修改，也可以修改 artition.xml,添加更多的启动分区命名成上面提到的 partition_boot.xml,然后再生成rawprogram0.xml. 

添加更多的分区，只要有该分区的镜像或者备份即可，比如包含 bootloader，这样有可能就可以直接启动到 bootloader 模式下刷机了，或者 NON-HLOS 等，或者一个完整的 rawprogram0.xml，这就相当于直接刷机了，但是这样生成的msimage将会非常大，刷起来非常的慢。

## edl模式

就是常说的救砖模式,一般高通手机只要没有硬件问题,使用 QHSUSB DLOAD 模式一般都救的回来,使用的是高通的 sahara和 firehose 协议,是 msm8k 以后平台的协议标准,两种协议分别使用 eMMC Software Download 和 QFIL(Qualcomm Flash Image Loader)刷机,这两个工具全部包括在高通的QPST中.在这两种协议下,在 9008 模式时烧写进去的大概只有五个文件,然后系统会进入9006模式，这个模式下系统会识别 qualcomm emmc 磁盘,此时就可以恢复各分区的备份,或者直接写入关键的系统分区备份(可以使用UltraISO/HDD Raw Copy Tools等工具),这样就可以进入 recovery,bootloader 进行刷机,也可以使用 QFIL 或 Miflash 或 Msm8974 Download Tool等救砖工具一步完成.   

在 msm7k 平台以前是没有 EDL 急救模式的，出了问题只能 JTAG。 

备份的时候可以使用 dd 命令备份出整个磁盘,或者系统关键分区.或者使用[emmc raw tool](http://4pda.ru/forum/index.php?showtopic=655617)  

msimage MPRG 是 Sahara 协议下刷机的必需的,而 firehose 协议下的必须文件变成了`prog_emmc_firehose_platform.mbn`,看文件就可以知道使用的是什么协议.而以前的例如 msm7k 平台有的使用的是 stream dload 协议，QPST 工具里面使用的是 Software Download，和 Sahara 协议相比，并不需要 msimage，也不需要 xml，只需要串口烧写协议如`eNPRG hex`和`dbl/osbl`，实际上 Sahara 协议所使用的 msimage 刚好是`dbl/osbl`的结合体，so，`prog_emmc_firehose_platform.mbn`也是 msimage 和 MPRG hex 的结合体？  

stream dload协议救砖方法:

[How to program eMMC images into blank flash with USB only in MSM7630 ](http://kernel-develop.blogspot.com/2012/05/how-to-program-emmc-images-into-blank.html)  
[ qualcomm 8K平台Sahara Protocol相对7K, 6K 平台Software Download优点 ](http://blog.csdn.net/fybon/article/details/18263191)  

总结就是：8k Sahara Protocol省去了 CRC，打包、解包的过程直接传输 raw data，效率高。 
同样的使用此模式刷机可以绕过华为的 MD5withRSA 的签名校验.  

* 一般手机都有特别的按键方式进入,例如`vol+ & usb`等等
* 使用`adb reboot edl` 或者`adb reboot dload` 或者`fastboot oem reboot-edl`（联想？）
* 清除tz分区`cat /dev/zero > /dev/block/platform/msm_sdcc.1/by-name/tz`或者其它重要的分区如 sbl 分区、aboot 分区，也可在 fastboot 下直接 erase
* 当只能被识别为 9006 模式时，如果想切换到 9008，可以使用磁盘管理工具重建分区表，或者删除关键分区
* 拆机，短接测试点：把电信卡槽上面的金属片跟测试点连在一起，测试点要拆机才能看到（彻底黑砖的用这个方法） 

## QFIL command line

```shell
qfil.exe -Mode=1 -COM="enter your comport number setting here" -SEARCHPATH="enter your complete path to 8675_W00 folder" -Sahara=true;"enter your complete path to the prog_emmc_FireHose_8936.mbn" -RawProgram=rawprogram0.xml -patch=patch0.xml -AckRawDataEveryNumPackets=TRUE;100 -DeviceTYPE="eMMC" -PlatForm="8x26" -MaxPayloadSizeToTargetInBytes="49152"

Here are example to use it

qfil.exe -Mode=1 -COM=64 -SEARCHPATH="D:\CBW8600A01_A_T1701" -Sahara=true;"D:\CBW8600A01_A_T1701\prog_emmc_FireHose_8x26.mbn" -RawProgram=rawprogram_unsparse.xml,rawprogram2.xml -patch=patch0,patch2.xml -AckRawDataEveryNumPackets=TRUE;100 -DeviceTYPE="eMMC" -PlatForm="8x26" -MaxPayloadSizeToTargetInBytes="49152"
```

![参数参考](http://forum.xda-developers.com/attachment.php?attachmentid=3261470&stc=1&d=1428998570)  
更多文档在 QPST 软件的目录中.

## 华为免解锁 

官方卡刷跟官方平台线刷都会校验每个字节，每个文件，每个镜像文件都是 CRC32k 算法校验的，这是公开的。还有就是华为为防止文件的数据被修改还加了 MD5withRSA 加密算法，这个需要华为的私钥文件才能校验成功，私钥只有华为知道. 

### 解锁方法

* 官方申请解锁码
* 将其它手机解完锁后的 oeminfo.img写入 oeminfo 分区,进行强制解锁,但是IMEI之类的貌似就是别人的了
* 使用 ebl 模式,刷入修改后的 oeminfo 分区镜像,或者直接修改`echo -ne '\x02' | dd of=/dev/block/mmcblk0p3 bs=1 seek=33669144 conv=notrunc`
* [TUTORIAL: Remove *TAMPERED* & *RELOCKED* flag ](http://forum.xda-developers.com/showthread.php?t=2541843)
* [沃日，华为的解锁原理竟是如此的简单](http://www.in189.com/thread-1079000-1-1.html)
* 十六个U是什么鬼,配合特定的机型,特定的 ROM 版本(efi fastboot),可实现解锁?  

华为的手机存在解锁后没法降级的情况,就算重新锁上也是不行的.可以`dd if=/dev/urandom of=/dev/block/mmcblk0p8 bs=512 count=10`向 oeminfo 分区写入随机数据(记得备份),重启后 bootloader 就会重新锁上,就可以自由升降级了

## 参考

* [高通 MSM8K bootloader](http://blog.csdn.net/fybon/article/details/37565227)
* [[教程] 高通平台线刷ROM制作简明教程，暴力ROOT](http://www.in189.com/thread-1107 257-1-1.html)
* [IM-A820L显示QHSUSB_DLOAD的救砖方案](http://blog.csdn.net/su_ky/article/details/7773273)
* [A840S黑砖修复过程](http://blog.csdn.net/ziyouwa/article/details/8620595)
* [泛泰SKYA850救砖原理与分区表解析](http://blog.csdn.net/benjaminwan/article/details/8854437)
* [泛泰SKYA850黑砖QHSUSB_DLOAD救砖教程](http://blog.csdn.net/benjaminwan/article/details/8804647)
* [SHV-E160L Debricking Tool / Qualcomm Tool Pack V2-1](http://forum.xda-developers.com/showthread.php?t=2136738)
* [[REF][R&D] Building Bootloaders on Qualcomm Devices](http://forum.xda-developers.com/showthread.php?t=1978703)
* [[R&D][QUALCOMM] Using QDL, EHostDL and DIAG interfaces & features](http://forum.xda-developers.com/showthread.php?t=2086142)
* [[PROJECT] Reviving Hard Bricked YU (QLoader 9008 Mode)](http://forum.xda-developers.com/yureka/help/question-qualcomm-download-mode-k-t3068040)
* [Flashtools (MiFlash4Linux, Recovery from QDL/DLOAD, Partition resize)](http://forum.xda-developers.com/mi-2/orig-development/flashtools-miflash4linux-recovery-qdl-t3036730)

