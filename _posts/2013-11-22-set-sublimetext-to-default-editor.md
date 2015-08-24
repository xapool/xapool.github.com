---
layout:     post
title:      将Sublime Text 2设置为默认编辑器
category:
    - Tools
tags:
    - Sublime text
---

虽然一直在用Sublime Text 2，但是一直比较懒，没有将其设置为默认编辑器。 

### 修改defaults.list
编辑`/etc/gnome/default.list`文件，将其中的所有`gedit.desktop`替换为`sublime-text-2.desktop`。


sublime-text-2.desktop在`/usr/share/applications/`目录下，使用`ls -al *sublime*`命令查看具体文件名。  

### 配置alternatives
执行：

    sudo update-alternatives --install /usr/bin/gnome-text-editor gnome-text-editor /usr/bin/sublime-text 300

sublime-text在/usr/bin目录下，是一个可执行二进制文件。 
然后：

    sudo update-alternatives --config gnome-text-editor

输入sublime-text那一行的行数就行了。 

OK!
