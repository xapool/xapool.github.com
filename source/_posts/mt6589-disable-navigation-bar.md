---
title: mt6589 禁用 Navigation Bar
date: 2013-08-29
tags:
- MTK
categories:
- Android
---

默认 Navigation Bar 的控制在
```xml
<bool name="config_showNavigationBar">true</bool>
```
> `alps/frameworks/base/core/res/res/values/config.xml` 文件中

<!--more-->

6589 navigation Bar 最终控制在，会覆盖掉上述设置：
`alps/mediatek/custom/project_name/resource_overlay/generic/frameworks/base/core/res/res/values/config.xml`


所以主要修改 config 中的 overlay 为 false。

但是有的在 build.prop 中又定义了 qemu.hw.mainkeys，可以在 config 中的 system.prop 中去掉，或者改为 qemu.hw.mainkeys=1。如果 buildinfo.sh 中有此定义，也可以修改掉
