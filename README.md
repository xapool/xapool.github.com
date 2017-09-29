HackerOO7's Blog
------------------

Personal [Blog](http://blog.omitol.com) and [Wiki](http://wiki.omitol.com)

How TO
------------------

- 安装 Node.js
```shell
$ wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
$ nvm install stable
```

- 安装 Hexo
```shell
$ npm install hexo-cli -g
```

- Clone 项目
```shell
$ git clone git@github.com:HackerOO7/hackeroo7.github.com.git
# 进入目录，切换到 src 分支
$ git checkout src
```

- 安装依赖
```shell
# 更换为 tabobao 的源，使用 cnpm 安装依赖，避免先前出现的编译错误
$ npm install -g cnpm --registry=https://registry.npm.taobao.org
$ npm config set registry https://registry.npm.taobao.org
$ hexo init
$ cnpm install
$ cnpm install hexo-renderer-scss --save
$ cnpm install hexo-deployer-git --save
$ cnpm install hexo-generator-seo-friendly-sitemap --save
$ cnpm install hexo-generator-search --save
$ cnpm install hexo-generator-feed --save
```

- 写文章
```shell
$ hexo new "post"
# hexo 会根据模板，在source/_posts目录下生成post.md
```

- 部署到 github
```shell
# 本地查看效果，浏览器访问 localhost:4000
$ hexo server
# hexo clean 发布之前清除一下
# 部署
$ hexo g -d
```

- Push src
```shell
# git commit 本地修改
$ git push origin src
```
