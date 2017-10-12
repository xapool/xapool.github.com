---
title: 使用 github 搭建静态博客
date: 2013-10-14
tags:
    - Jekyll
categories: 
    - Tips
---

这是首次使用 githubpages 的第一篇博文，也是一篇教程

## 安装 Jekyll

### 更新 Ruby 版本

已弃用，请查看新方法

<!--more-->

此环境需要 ruby 的版本 >=1.9.2，`ruby -v`查看 ruby 的版本，如果版本低于 1.9.2，得更新 ruby

    curl -L https://get.rvm.io | bash -s stable --ruby

编辑 `~/.bashrc`，将 `~/.bash_profile` 中的文本复制到 `.bashrc` 末尾，然后更新环境变量：

    source ~/.bashrc

然后安装 1.9.2：

    rvm install 1.9.2

此时 `ruby -v` 查看版本 ruby 的版本默认为最新的，设置为默认的 1.9.2：

    rvm --default 1.9.2

也可以暂时调整使用其它版本如：

    rvm use 1.9.3

如果版本不对，请按照上诉步骤更新环境变量。

#### 新方法
以上方法虽然可以允许自定义但是很麻烦，使用的是 ubuntu13.04，源中有 ruby1.9.3 版本，直接安装，弃用以上方法。

    sudo apt-get install ruby1.9.3

### 安装 jekyll
为了在本地可以测试，直观的看到修改后的展示效果，需要安装 jekyll

    sudo apt-get install rubygems

然后使用 gem 命令安装以下包：

    sudo gem install jekyll
    sudo gem install rdiscount

国外的 gem 源，也许比较慢，可以更改 gem 的源（未测试）

    sudo gem sources --remove http://rubygems.org/
    sudo gem sources -a http://ruby.taobao.org/ 

## 创建项目
在你的 github 上创建一个项目 username.github.com， username 为你在 github 上的用户名，创建时可以初始化一个 readme.m d和 jekyll 的 
.gitignore 文件


将你的项目 git clone 到本地 

## clone 一个模板
这里有很多 jekyll 的模板:


    https://github.com/mojombo/jekyll/wiki/sites

clone 一个 Octopress 的模板:(有问题，木有搞定，换一个模板）

    git clone https://github.com/xuhdev/homepage.git

使用


    https://github.com/beiyuu/beiyuu.github.com.git


这个模板

然后删除其中的 .git 文件，copy 到你的项目目录 

## 本地查看效果
在你的项目目录下执行:


    jekyll serve

如果没有什么错误发生的话，就可以在浏览器中浏览


    localhost:4000

## 开始自己的修改吧

测试没有问题的话，就可以开始自己的修改了。删除原来的文章，增加自己的文章，修改域名，博客标题， icon 等。本地测试一下没有问题的话，就可以 push 了。

下面就是开始努力的学习 markdown 语法了，这个东西对我最头痛排版的问题，简直是太爽 了，有种相见恨晚的赶脚。
