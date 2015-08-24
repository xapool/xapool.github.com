---
layout:     post
title:      使用Sublime Text 2 编辑Markdown
category:
    - Tools
tags:
    - 快捷键
    - Sublime text
---

Sublime Text 2 现在做为我的第一编辑器，用好它还需要一个漫长的过程。学习Markdown必须找一个合手的编辑器

## Sublime Text 2的配置
这里使用了两个插件：

* MarkdownEditing
* Markdown Preview

Markdown Preview是预览插件。安装过程，待以后补全。

## Sublime Text 2的快捷键
* Ctrl+Win+V 选中的内容将自动转换为行内式超链接，链接到剪贴板中的内容
* Ctrl+Win+R 选中的内容将自动转换为参考式超链接，链接到剪贴板中的内容
* Ctrl+Alt+R 弹出提示框插入一个参考式超链接，在提示框中输入链接内容和定义参考ID[^3]
* Ctrl+Win+K 插入一个标准的行内式超链接
* Win+Shift+K 插入一个标准的行内式图片（此快捷键可能与输入法有冲突）
* Ctrl+1 至 Ctrl+6 插入一级至六级标题
* Win+Alt+i 选中的内容转换为斜体
* Win+Alt+b 选中的内容转换为粗体[^1]
* Ctrl+Shift+6 自动插入一个脚注，并跳转到该脚注的定义中。
* Alt+Shift+F 查找没有定义的脚注并自动添加其定义链接
* Alt+Shift+G 查找没有定义的参考式超链接并自动添加其定义链接
* Ctrl+Alt+S 脚注排序
* Ctrl+Shift+. 缩进当前内容
* Ctrl+Shift+, 提前当前内容

## 其它Ubuntu 下的Markdown 工具
* [ReTex](http://sourceforge.net/p/retext/home/ReText/)
* [mahua](http://mahua.jser.me/)

其中第二个mahua是在线编辑器，都可以实现实时预览。

### ReTex Ubuntu 13.04下安装过程
    sudo add-apt-repository ppa:mitya57
    sudo apt-get update
    sudo apt-get install retext

## 一个Markdown语法高亮主题
* [Monokai-custom.tmTheme](https://dl.dropbox.com/u/837457/sublime%20text%202/Monokai-custom.tmTheme)

放到~/.config/sublime-text-2/Packages/User/ 文件夹下，在Preferences -> Color Scheme -> User选择Monokai-custom。


