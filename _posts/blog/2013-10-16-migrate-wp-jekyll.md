---
layout:     post
title:      将wordpress的数据迁移到jekyll
category: blog
description: 遇到了太多的麻烦，整个重来了好几遍
---

##将wordpress的数据迁移到jekyll
官方文档:

    [http://jekyllrb.com/docs/migrations/](http://jekyllrb.com/docs/migrations/)

安装过程中出错，因为ruby版本太低，要更新版本到1.9.2，因为先前的工作并没有更新ruby的版本，导致遇到了很多麻烦，所以重新来了一遍。更新ruby的方法，已经放到了第一篇文章中去了。

###备份wordpress的文章
进入wordpress的后台，工具-导出，导出文章即可，是一个xml文件


前期准备，这里使用从xml导出的方式，从数据库导出一直没有搞定

    sudo gem install hpricot 

这里使用别人修改好了的脚本，官方脚本对中文支持不友好：

    [https://gist.github.com/chitsaou/1394128](https://gist.github.com/chitsaou/1394128)

将备份的wordpress.xml放到项目的根目录，把脚本放到新建的utils目录中，然后运行：

    sudo ruby -r "./utils/wordpressdotcom.rb" -e "Jekyll::WordpressDotCom.process"

因为边一直使用了sudo，导致后来出了很多问题，不得不使用sudo才行。

转换好的文章在`source`目录中。

把html转换成markdown真是个力气活，最后还有手动纠正很多错误才行。

