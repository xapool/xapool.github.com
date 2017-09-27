---
title: git stash 的使用
date: 2013-10-22
tags:
    - Git
categories:
    - Tips
---

对于有时某些未完善的修改，并不想commit时，而又有需求切换分支工作时，这时git stash命令就派上用场了

## 搁置修改
有时在分支上有未提交的修改，因为要切到其它分支或要做其它修改测试，因修改未整理，不想提交。这时就可以使用stash命令，例：

    git add .
    git stash

这样把未提交的修改暂时搁置，所有文件恢复到未修改之前的，然后就可以进行其它的工作了

<!--more-->

## 恢复搁置的修改
恢复之前搁置的修改：

    git stash apply

## git stash 的其它命令

### 查看所有之前搁置的修改

    git stash list

### 恢复其中的某个修改

    git stash apply stash@{1} #注意这是找回第二个
    git stash pop #找回第一个

### 删除某个stash
    git stash drop <id>

### 删除所有stash
    git stash clear
