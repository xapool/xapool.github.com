---
title: Linux 下 mail 命令的使用
date: 2013-10-31
categories:
    - Ubuntu
---

因为服务器上android项目的一个编译脚本，要检测编译的状况。要增加一个发送email的功能，可以以前没有用过，就研究一下。 

## 安装
安装mailutils


    sudo apt-get install mailutils

因为还要发送附件，需安装

    sudo apt-get install sharutils

<!--more-->

## 发送方式

### 一般的发送方式
    mail address@address.com

 编辑抄送对象，邮件主题，邮件正文后，按Ctrl-D结束。

### 快速发送方式
    echo “邮件正文” | mail -s "邮件主题" address@address.com

### 以文件内容作为邮件正文来发送
    mail -s "邮件主题" address@address.com < 邮件正文.txt

### 发送带附件的邮件
    uuencode 附件名称 附件显示名称 | mail -s "邮件主题" address@address.com 

例如： 

     uuencode test.txt test.txt | mail -s Test address@gmail.com

### 以文件内容作为邮件正文和同时发送附件
没有找到什么便利的方法 
例：

    uuencode log.tar.gz log.tar.gz > attachment.txt
    cat info.txt attachment.txt > combined.txt
    mail -s "服务器编译错误，请查看日志文件" x2280854@gmail.com < combined.txt

经测试，发送到gmail邮箱，邮件正文和附件是可以正确识别的。而发送到163的公司邮箱，无法正确识别，而是把整个combined.txt当作了正文。

## 11.26更新

### 遇到的一个错误
最近一段时间服务器上的邮件，一直无法成功发送到我的邮箱，今天抽空看了一下。

    /usr/lib/sendmail -bp

错误日志：
> 47DA518ADCE6      397 Tue Nov 26 14:40:39  shenduos@Raphael-DeepinLinux
> (Host or domain name not found. Name service error for name=gmail.com type=MX: Host not found, try again)
>                                          x2280854@gmail.com

最后的问题在：

    /var/spool/postfix/etc/resolv.conf

编辑`/var/spool/postfix/etc/resolv.conf`，文件内容应该和`/etc/resolv.conf`中一样。

## 参考
* [Linux mail命令使用 ](http://blog.csdn.net/c395565746c/article/details/6011731)
* [linux下mail命令使用(转)](http://sunxiaqw.blog.163.com/blog/static/99065438201010182277261/)
