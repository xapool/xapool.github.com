Personal Blog
------------------

Personal [Blog](http://blog.omitol.com) and [Wiki](http://wiki.omitol.com)

How TO
------------------

### 安装环境

若新环境中没有安装 Node.js、Hexo、Git 的话需要首先安装

- 安装 Node.js
```bash
$ wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
$ nvm install node
```

- 安装 Hexo
```bash
$ npm install hexo-cli -g # 会自动安装 hexo
```

### 克隆并安装依赖

- Clone 项目
```bash
$ git clone git@github.com:xapool/xapool.github.io.git
$ git checkout src  # 进入目录，切换到 src 分支
```

- 安装依赖
```bash
$ npm install   # 安装依赖
```

- 写文章
```bash
$ hexo new "post"    # hexo 会根据模板，在source/_posts目录下生成post.md
```

- 部署到 github
```bash
$ hexo server   # 本地查看效果，浏览器访问 localhost:4000
$ hexo g -d    # 部署，发布之前可清除一下 hexo clean 
```

- Push src
```bash
$ git push origin src
```
