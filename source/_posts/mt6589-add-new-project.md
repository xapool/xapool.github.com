---
title: mt6589 增加新的项目
date: 2013-09-30
tags:
- MTK
categories:
- Android
---

从自己的笔记中，摘抄出来的，一直没有整理

<!--more-->

只有使用自定义签名时才使用项目签名:

配置选项为:

```shell
MTK_SIGNATURE_CUSTOMIZATION = yes
MTK_INTERNAL = no
cp -fr build/target/product/security/$old_p/ build/target/product/security/$new_p/
```

其它:
```shell
cp -fr build/target/product/$old_p.mk build/target/product/$new_p.mk
cp -fr mediatek/config/$old_p/ mediatek/config/$new_p/
cp -fr mediatek/custom/$old_p/ mediatek/custom/$new_p/
cp -fr vendor/mediatek/$old_p/ vendor/mediatek/$new_p/
mv vendor/mediatek/$new_p/artifacts/out/target/product/$old_p vendor/mediatek/$new_p/artifacts/out/target/product/$new_p
```

还有
`/vendor/mediatek/$project/artifacts/target.txt`
修改里面的 $project 为 $new_p
