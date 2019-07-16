Personal Blog
------------------

Personal [Blog](http://blog.omitol.com) and [Wiki](http://wiki.omitol.com)

How TO
------------------

### 安装环境

若新环境中没有安装 Node.js、Hexo、Git 的话需要首先安装

- 安装 Node.js
```shell
$ wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
$ nvm install node
```

- 安装 Hexo
```shell
~~$ npm install hexo --no-optional~~
$ npm install hexo-cli -g # 会自动安装 hexo
```

### 克隆并安装依赖

- Clone 项目
```shell
$ git clone git@github.com:xapool/xapool.github.com.git
# 进入目录，切换到 src 分支
$ git checkout src
```

- 安装依赖
```shell
# 安装依赖
$ npm install
```
~~# 使用 tabobao 的镜像 cnpm，避免在我的 MAC 上编译依赖 hexo-renderer-scss 时出错误~~  
~~$ npm install -g cnpm --registry=https://registry.npm.taobao.org~~  
~~$ npm config set registry https://registry.npm.taobao.org~~  
~~# 安装依赖~~  
~~$ cnpm install~~  


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
