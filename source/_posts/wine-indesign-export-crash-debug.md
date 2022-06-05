---
title: Wine：InDesignCS6 导出 PDF 时的崩溃问题
date: 2022-05-21 12:44:31
categories:
    - Wine
tags:
    - wine
---

Wine AppDB 上记录的对 [Adobe InDesign CS6](https://appdb.winehq.org/objectManager.php?sClass=version&iId=26506) 支持不错，但在使用的过程中，有一个严重的 bug。若是选择 "Adobe 打印" 的方式导出 pdf，会造成程序的崩溃。

<!--more-->

## 崩溃日志
崩溃信息如下(截取部分)：
> Unhandled exception: page fault on read access to 0x00000000 in 32-bit code (0x00981d1d).
> Register dump:
>  CS:0023 SS:002b DS:002b ES:002b FS:0063 GS:006b
>  EIP:00981d1d ESP:3241f740 EBP:3241f754 EFLAGS:00010287(  R- --  I S - -P-C)
>  EAX:00000000 EBX:00000000 ECX:3241f748 EDX:292676e8
>  ESI:291b5788 EDI:00003ee1
> Stack dump:
> 0x3241f740:  0defc619 0defcaa0 3241f81c 0df191db
> 0x3241f750:  ffffffff 3241f760 0defcab3 292d33f8
> 0x3241f760:  3241f77c 100135dc 291b5788 27ef6ec8
> 0x3241f770:  08027fe0 00000010 00003e01 3241f7a8
> 0x3241f780:  1000e581 00000000 00003ee1 27ef6ec8
> 0x3241f790:  00003e13 00000101 00000000 27ef6ec8
> Backtrace:
> =>0 0x00981d1d in pmruntime (+0x1d1d) (0x3241f754)
>   1 0x0defcab3 in font manager.rpln (+0x4cab3) (0x3241f760)
>   2 0x100135dc in objectmodel (+0x135dc) (0x3241f77c)
>   3 0x1000e581 in objectmodel (+0xe581) (0x3241f7a8)
>   4 0x1001b802 in objectmodel (+0x1b802) (0x3241f7d0)
>   5 0x1001a8cb in objectmodel (+0x1a8cb) (0x3241f7e0)
>   6 0x0def3024 in font manager.rpln (+0x43024) (0x3241f828)
>   7 0x0def32e3 in font manager.rpln (+0x432e3) (0x3241f834)
> ......
> ......
> 0x00981d1d pmruntime+0x1d1d: cmpl	$0,0x0(%eax)

## 问题分析
崩溃的原因是 page fault，地址是 `0x00981d1d in pmruntime (+0x1d1d)`，汇编代码 `cmpl	$0,0x0(%eax)`，取 eax 的值与零进行比较，但通过上面的 Register dump，eax 的内容是零，对零解引用，就造成了 page fault。
eax 通常用做存储函数的返回值。所以这种问题，如果程序没有加壳的话，可以直接使用 IDA F5 键看下崩溃处的代码，看下在出问题的指令前调用了什么函数。

F5 键结果:

```C++
BOOL __cdecl K2Memory::IsUIThread()
{
  _DWORD *v0; // eax

  v0 = NtCurrentTeb()->NtTib.FiberData;
  return v0 != (_DWORD *)7680 && !*v0;
}
```

问题出在 `*v0`, `NtCurrentTeb()->NtTib.FiberData` 的返回值是零。这里有 [TEB NtTib 结构体的介绍](https://bbs.pediy.com/thread-223816.htm#msg_header_h2_7)，FiberData 经过查询资料得知是关于协程的一个东西，跟了以下 Wine 的代码，也没搞明白该如何修复。使用 x64dbg 单步调试了下在此处的逻辑后，发现直接 nop 出问题的指令，好像并无影响。

原汇编代码：

```C++
.text:10001D10 ; bool __cdecl K2Memory::IsUIThread(K2Memory *__hidden this)
.text:10001D10                 public ?IsUIThread@K2Memory@@YA_NXZ
.text:10001D10 ?IsUIThread@K2Memory@@YA_NXZ proc near  ; DATA XREF: .rdata:off_1000A588↓o
.text:10001D10
.text:10001D10 this            = dword ptr  4
.text:10001D10
.text:10001D10                 mov     eax, large fs:10h
.text:10001D16                 cmp     eax, 1E00h
.text:10001D1B                 jz      short loc_10001D28
.text:10001D1D                 cmp     dword ptr [eax], 0
.text:10001D20                 jnz     short loc_10001D28
.text:10001D22                 mov     eax, 1
.text:10001D27                 retn
.text:10001D28 ; ---------------------------------------------------------------------------
.text:10001D28
.text:10001D28 loc_10001D28:                           ; CODE XREF: K2Memory::IsUIThread(void)+B↑j
.text:10001D28                                         ; K2Memory::IsUIThread(void)+10↑j
.text:10001D28                 xor     eax, eax
.text:10001D2A                 retn
.text:10001D2A ?IsUIThread@K2Memory@@YA_NXZ endp
```

修改后的汇编：

```C++
.text:10001D10 ; bool __cdecl K2Memory::IsUIThread(K2Memory *__hidden this)
.text:10001D10                 public ?IsUIThread@K2Memory@@YA_NXZ
.text:10001D10 ?IsUIThread@K2Memory@@YA_NXZ proc near  ; DATA XREF: .rdata:off_1000A588↓o
.text:10001D10
.text:10001D10 this            = dword ptr  4
.text:10001D10
.text:10001D10                 mov     eax, large fs:10h
.text:10001D16                 cmp     eax, 1E00h
.text:10001D1B                 jz      short loc_10001D28
.text:10001D1D                 nop
.text:10001D1E                 nop
.text:10001D1F                 nop
.text:10001D20                 nop
.text:10001D21                 nop
.text:10001D22                 mov     eax, 1
.text:10001D27                 retn
.text:10001D28 ; ---------------------------------------------------------------------------
.text:10001D28
.text:10001D28 loc_10001D28:                           ; CODE XREF: K2Memory::IsUIThread(void)+B↑j
.text:10001D28                 xor     eax, eax
.text:10001D2A                 retn
.text:10001D2A ?IsUIThread@K2Memory@@YA_NXZ endp
```

还有一种修改 Wine 代码的 dirty workaround，修改 ntdll 的 `dispatch_exception` 函数，对此 page fault 异常进行处理，让 `Eip + 5` 后，跳过出问题的指令，让程序继续运行。
