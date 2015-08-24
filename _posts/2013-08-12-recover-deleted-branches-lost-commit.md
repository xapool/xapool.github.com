---
layout: post
title: 恢复删除的分支、或者丢失的commit
category: 
    - Tips
tags:
    - Git
---

手一哆嗦把分支删掉了，干掉了好几天的工作成果，不甘心。谁让咱git使用没那么牛呢，遂找办法。还是把《git权威指南》细细看完吧。

转自：[http://sumsung753.blog.163.com/blog/static/146364501201301711943864/](http://sumsung753.blog.163.com/blog/static/146364501201301711943864/)

在使用Git的过程中，有时可能会有一些误操作

比如：执行`checkout -f` 或  `reset -hard` 或  `branch  -d`删除一个分支

结果造成本地（远程）的分支或某些commit丢失

可以通过reflog来进行恢复，前提是丢失的分支或commit信息没有被git gc清除

一般情况下，gc对那些无用的object会保留很长时间后才清除的

reflog是git提供的一个内部工具，用于记录对git仓库进行的各种操作

可以使用`git reflog show`或`git log -g`命令来看到所有的操作日志

恢复的过程很简单：


1. 通过`git log -g` 命令来找到我们需要恢复的信息对应的commit_id，可以通过提交的时间和日期来辨别。一个好的办法是运行：
    
    *   git log --since="2 weeks ago" -- myfile #可以查看2个星期期间的myfile历史
    *   git log --branches="developer" #可以查看某个developer的commit

2.  通过git branch recover_branch[新分支] commit_id 来建立一个新的分支

这样，我们就把丢失的东西给恢复到了recover_branch分支上了。

Q:如果是不小心执行了git reset，还有办法取消吗？

A:git reflog 查看操作历史，找到之前 HEAD 的 hash 值，然后 git reset --hard 到那个 hash 即可。

Q:怎样找回历史版本中删除的文件？

A:先确定需要恢复的文件要恢复成哪一个历史版本(commit)，假设那个版本号是： commit_id，那么

    git checkout [commit_id] — <path_to_file>

就可以恢复。
