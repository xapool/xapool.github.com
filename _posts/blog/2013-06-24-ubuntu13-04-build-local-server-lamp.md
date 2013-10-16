---
layout:     post
title:      Ubuntu13.04 上搭建LAMP本地服务器
category: blog
description: 这是以前的一篇在本地测试用的
---

##安装


###安装MYSQL
    sudo apt-get install mysql-server
    sudo apt-get install mysql-client

安装mysql-server的过程中需要设置root用户的密码

###安装Apache
    sudo apt-get install apache2

###安装PHP
    sudo apt-get install php5
    sudo apt-get install libapache2-mod-auth-mysql
    sudo apt-get install php5-mysql

###安装phpMyadmin
    sudo apt-get install phpmyadmin
    sudo ln -s /usr/share/phpmyadmin

安装过程中配置phpMyadmin，服务器要选择apache。需要输入数据库的登陆密码，并设置phpMyadmin的登陆密码
##测试


###修改权限

    chown username /var/www（将username替换为您当前用户的用户名）
    chmod 777 /var/www/

###检测Mysql是否正常
在终端中输入：

    mysql -uroot -p

输入密码，看是否可正常登陆

###检测Apache是否正常
在浏览器中打开：[http://localhost/](http://localhost)

如果出现如下信息，则表明正常。
>  It works!
> 
> This is the default web page for this server.

>The web server software is running but no content has been added, yet.

###检测PHP是否正常
Ubuntu下Apache的默认安装路径为/var/www/，到其目录下新建info.php文件，文件内容为：

然后在浏览器中打开：[http://localhost/info.php](http://localhost/info.php) 看是否正常。

###检查phpMyadmin是否正常
在浏览器中访问[http://localhost/phpmyadmin](http://localhost/phpmyadmin)，到phpMyAdmin的登陆界面

重启apache服务器：

做完一些修改后有时要重启一下：

    sudo /etc/init.d/apache2 restart


