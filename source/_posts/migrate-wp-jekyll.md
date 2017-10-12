---
title: 将 WordPress 的数据迁移到 Jekyll
date: 2013-10-16
tags:
    - Jekyll
categories: 
    - Tips
---

遇到了太多的麻烦，整个重来了好几遍

官方文档:

[http://jekyllrb.com/docs/migrations/](http://jekyllrb.com/docs/migrations/)

安装过程中出错，因为 ruby 版本太低，要更新版本到 1.9.2，因为先前的工作并没有更新 ruby 的版本，导致遇到了很多麻烦，所以重新来了一遍。更新 ruby 的方法，已经放到了第一篇文章中去了。

备份 wordpress 的文章:

进入 wordpress 的后台，工具-导出，导出文章即可，是一个 xml 文件

前期准备，这里使用从 xml 导出的方式，从数据库导出一直没有搞定

<!--more-->

    sudo gem install hpricot 

这里使用别人修改好了的脚本，官方脚本对中文支持不友好：

[https://gist.github.com/chitsaou/1394128](https://gist.github.com/chitsaou/1394128)

将备份的 wordpress.xml 放到项目的根目录，把脚本放到新建的 `utils` 目录中，然后运行：

    sudo ruby -r "./utils/wordpressdotcom.rb" -e "Jekyll::WordpressDotCom.process"

因为边一直使用了 sudo，导致后来出了很多问题，不得不使用 sudo 才行。

转换好的文章在 `source` 目录中。

把 html 转换成 markdown 真是个力气活，最后还有手动纠正很多错误才行。

