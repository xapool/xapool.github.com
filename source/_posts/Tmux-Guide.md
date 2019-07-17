---
title: Tmux 简明指南
date: 2017-11-03 12:26:51
categories:
    - Tools
tags:
    - tmux
---

Tmux 做为一利器，很早就知道了，但是一直没有搞明白其使用场景，甚至一直在以错误的方式使用。现今花点时间搞明白它。

首先就是使用场景的问题，至于具体的命令以后在慢慢记忆。

<!--more-->

## Update
1. 在 iTerm2 中 re-attach 一个会话后，中文输入有问题，参考这个 [issue](https://gitlab.com/gnachman/iterm2/issues/5551)，是 tmux 的 bug，升级到 2.3 及以上版本即可解决，Ubuntu 16.04 源中的版本比较低，需要重新编译安装
2. 因为 mosh 并不支持使用 `tmux -CC` 参数，因此使用 [et](https://github.com/MisterTea/EternalTerminal) 替代
3. 当服务端重启后，每次都得重新新建会话，打开一堆窗口，因此使用 tmux 插件 [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) 来[保存会话和恢复会话](https://blog.csdn.net/xy707707/article/details/80834428)，使用[tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)插件来自动保存会话，默认每十五分钟保存一次。

*注意*：但因为在和 iTerm2 集成的情况下，并不能使用 Ctrl + b，因此需要手动保存执行命令来保存会话状态 [issue](https://github.com/tmux-plugins/tmux-resurrect/issues/179#issuecomment-304748076)。在使用 resurrect 插件后，还会导致一个问题 [issue](https://github.com/tmux-plugins/tmux-sensible/issues/24#issuecomment-251045335)，这些 issue 中都有解决办法。还有一个需要注意的是，在新建一个会话后，先 detach, 然后执行脚本进行恢复，再 re-attach，直接在会话中进行 re-attach 时有问题。

## 使用场景
1. 在远程机器上安装和使用 tmux。一般使用 SSH 登陆到远程机器上后，若 SSH 断开后，在重新登陆，但是原先的窗口中的输出啊什么的就看不到了。若 SSH 登陆后，使用 tmux 命令开启一个会话，就算 SSH 断开了，你在重新登陆后，直接 attach 到原先的会话，就回到了原先的工作现场。而且在会话的窗口中可以使用 tmux 的快捷键开启多个面板，不需要在来一个 SSH 连接过去了。在 SSH 登陆的时候，使用 `ssh user@host "command"` 或 `ssh user@host -- command`，直接在远程机器上执行命令，如 tmux。 
2. 在本地机器上安装使用 tmux。在本地使用的话，可以方便的分屏，在会话和终端中切换，减少窗口数量等。这些iTerm2 就可以啦，一般还是在远程机器上使用。不过 detach 后，倒是可以变相的隐藏窗口...

## Tmux 的使用
Ctrl + b，然后 d，就会从当前会话中分离，回到原先终端。在原先终端中 `tmux attach`，就可以来到原先的会话。

在 tmux 的会话中，按下 Ctrl + b 后是激活控制台，输入 ? 可以显示控制台命令帮助。

如果有多个会话，可以使用 `tmux ls` 查看，然后 `tmux attach -t sessionname` 进入到这个会话。

命令可以查看这个 [CheatSheet](https://gist.github.com/MohamedAlaa/2961058)

## Mac 上和 iTerm2 的集成
如果本地机器使用的是 iTerm2，在 SSH 远程连接中使用 `tmux -CC` 命令，一个新的 tmux 会话就会被创建，并会开启一个新的窗口，而且 iTerm2 会接管 tmux 的功能，如分屏，就无需使用 tmux 的命令来进行了，可直接在这个新的窗口中使用 iTerm2 的快捷键，还有如历史查找等快捷键，也没必要对远程机器进行单独配置这些了。关闭某个面板时，选择 Hide，就可以使用 `tmux -CC attach` 命令来 attach 了。这个依然是使用场景1。

在 iTerm2 的 `Preferences > general` 中有一项 `tmux Integration`，可以对集成的 tmux 进行一些设置，如打开新窗口做为本地 tab，执行 `tmux -CC attach` 后，隐藏本窗口等。

使用 mosh 替代 ssh，mosh 会自动断开重连，需要在两端都安装。不过若使用 mosh 的连接，并不能使用 `-CC` 参数，参见该 [issue](https://github.com/mobile-shell/mosh/issues/640)。
