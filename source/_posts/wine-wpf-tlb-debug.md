---
title: Wine：因找不到 tlb 文件所导致的栈溢出
date: 2022-05-22 12:44:31
categories:
    - Wine
tags:
    - wine
---

有一款 WPF 应用在 Wine 下启动时，会重复不断地打印很多如下的 log，最后因 StackOverflowException 而崩溃：
> err:ole:TLB_ReadTypeLib Loading of typelib L"C:\\Program Files\\xxxxx\\xxxxxxx.tlb" failed with error 2

<!--more-->

## 问题程序集
tlb 是类型库文件，`error 2` 是找不到此文件。既然如此，把此程序集的 tlb 文件放到指定路径是否可行呢？
要验证一下，就得有此程序集的 tlb 文件。好在，经过检索，可使用 dotnet 的 RegAsm 来生成。

在 Windows 下执行以下命令：
> C:\Program Files\xxxxx>C:\windows\microsoft.net\framework\v4.0.30319\RegAsm.exe /codebase xxxxxxx.dll /tlb xxxxxxx.tlb

但出错了：
> RegAsm : error RA0000 : 类型库导出程序在处理“xxxxxxx.xxxxxxxxxx, xxxxxxx”时遇到了错误。错误: 找不到元素。

使用 tlbexp 工具来导出，也是同样的错误。而其他的程序集在导出 tlb 时并没有遇到过此问题。
使用 ILSpy 打开此 dll，找到出问题的类时，发现此 dll 中所有的类要导出 COM 时，使用的是同一个 GUID。而在 Windows 使用 x64dbg 调试此程序时，也发现了在调用 `CreateTypeLib2` 后，出现了同样找不到元素的错误日志。

那么，结论就是此程序集本身存在问题，但 Wine 无法兼容这种有问题的程序集，导致栈溢出。

## Dirty Workaround
延续上面的思路，使用 ildasm/ilasm 将重复的 GUID 修改掉后，最后在 Windows 下可成功导出 tlb 文件。将此 tlb 文件放到指定路径后，可修复栈溢出的问题。

此 dirty workaround 显然不太好，因为 Windows 下并不需要此 tlb 文件，还是要尝试找到出问题的代码。栈溢出通常是没有满足递归的出口造成的，所以需要对比下在 Windows 下程序正常执行时的逻辑。
打开 `+ole,+typelib,+seh` 调试频道，重点关注在调用 `CreateTypeLib2` 后，对返回的 COM 组件虚表中函数的调用逻辑，对比在 Windows 下使用 x64dbg 进行单步调试时分析出的逻辑，发现 Windows 很早就对有问题的类进行了返回，而 Wine 并不是。
Wine 直到 `ITypeInfo_fnGetRefTypeOfImplType FAILURE -- hresult 0x8002802b.` 才返回 0x8002802b，而后就是进入到另一个递归循环。

修改 Wine 的代码 `dlls/oleaut32/typelib.c`，尝试在 `ICreateTypeLib2_fnCreateTypeInfo` 时判断下若是有此问题的类，则直接返回 `TYPE_E_ELEMENTNOTFOUND`，这样同 Windows 下的逻辑就一致了。这又是一个 dirty workaround，既然是 dirty workaround，那就不止这几种，尝试其它了几种都是可行的。

但是要写出一个能被 Wine 接受的 patch，还需要对 Wine 的 `dlls/oleaut32/typelib.c` 进一步分析与理解，还需努力。
