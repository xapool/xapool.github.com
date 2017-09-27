---
title: 生成用于 verifiedboot 的 system image
date: 2016-07-05
tags:
    - verifiedboot
categories:
    - Android
---

android从6.0开始启用了verifiedboot，来保证系统的完整性

## GetVerityTreeSize和GetVerityMetadataSize

`build_verity_tree -s 2046820352`

`build_verity_metadata.py -s 2046820352`

该两个方法在源码的`./tools/releasetools/build_image.py`中.

参数是真实system分区的大小

## 生成预留空间的system.simg

要重新打包system.simg给verity_tree和verity_metadata预留出空间，`-l`指定的大小为真实system空间的大小减去上一步分别得到的大小

<!--more-->

## 生成root_hash即verity_tree

`build_verity_tree -A aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7 system.simg verity.img`

其中`aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7`是salt，`system.simg`需要是sparse image，生成verity.img.

命令输出例子

`3a82cfc74206a6a8b467fb699022d86ea36dee48b04fc8b40585d2cad941f463 aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7`

第一个就是后面要用到的root_hash值.

## 生成verity_metadata

`build_verity_metadata.py 2030665728 verity_metadata.img 3a82cfc74206a6a8b467fb699022d86ea36dee48b04fc8b40585d2cad941f463 aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7 /dev/block/platform/msm_sdcc.1/by-name/system verity_signer verity.pk8`

其中第一个参数是预留了空间后的system大小，后面的分别是root_hash, salt,system分区在手机里的分区，signer_path,私钥. 最后生成verity_metadata.img，32768个字节32kb是固定值。

## 生成最终的image

`append2simg system.simg verity_metadata.img`

`append2simg system.simg verity.img`

分别是前两步中生成的文件.

## 参考

* [Android secrue boot](http://blog.andrsec.com/android/2015/04/10/android-boot-verity.html)