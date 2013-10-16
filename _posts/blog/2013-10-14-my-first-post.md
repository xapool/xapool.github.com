---
layout:     post
title:      第一篇博文
category: blog
description: 这是首次使用githubpages的第一篇博文，也是一篇教程
---

##安装jekyll
###更新ruby版本

已弃用，请查看新方法


此环境需要ruby的版本>=1.9.2，`ruby -v`查看ruby的版本，如果版本低于1.9.2，得更新ruby

    curl -L https://get.rvm.io | bash -s stable --ruby

编辑~/.bashrc，将~/.bash_profile中的文本复制到.bashrc末尾，然后更新环境变量：

    source ~/.bashrc

然后安装1.9.2：

    rvm install 1.9.2

此时`ruby -v`查看版本ruby的版本默认为最新的，设置为默认的1.9.2：

    rvm --default 1.9.2

也可以暂时调整使用其它版本如：

    rvm use 1.9.3

如果版本不对，请按照上诉步骤更新环境变量。

####新方法
以上方法虽然可以允许自定义但是很麻烦，使用的是ubuntu13.04，源中有ruby1.9.3版本，直接安装，弃用以上方法。

    sudo apt-get install ruby1.9.3

###安装jekyll
为了在本地可以测试，直观的看到修改后的展示效果，需要安装jekyll

    sudo apt-get install rubygems

然后使用gem命令安装以下包：

    sudo gem install jekyll
    sudo gem install rdiscount

国外的gem源，也许比较慢，可以更改gem的源（未测试）

    sudo gem sources --remove http://rubygems.org/
    sudo gem sources -a http://ruby.taobao.org/ 

##创建项目
在你的github上创建一个项目username.github.com，username为你在github上的用户名，创建时可以初始化一个readme.md和jekyll的
.gitignore文件


将你的项目git clone到本地
##clone一个模板
这里有很多jekyll的模板:


    https://github.com/mojombo/jekyll/wiki/sites

clone一个Octopress的模板:(有问题，木有搞定，换一个模板）

    git clone https://github.com/xuhdev/homepage.git

使用


    https://github.com/beiyuu/beiyuu.github.com.git


这个模板

然后删除其中的.git文件，copy到你的项目目录

##本地查看效果
在你的项目目录下执行:


    jekyll serve

如果没有什么错误发生的话，就可以在浏览器中浏览


    localhost:4000

##开始自己的修改吧

测试没有问题的话，就可以开始自己的修改了。删除原来的文章，增加自己的文章，修改域名，博客标题，icon等.本地测试一下没有问题的话，就可以push了.

下面就是开始努力的学习markdown语法了，这个东西对我最头痛排版的问题，简直是太爽 了，有种相见恨晚的赶脚。