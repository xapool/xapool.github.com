---
layout:     post
title:      搭建jenkins编译nightly version rom
category: blog
description: 使用CI(持续集成)jekins编译nightly版的ROM
---

### 安装apache
    sudo apt-get install apache2 

### 安装jenkins
切换到root用户下: 

    echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list 

切回用户: 

    apt-get update && apt-get install jenkins 

### 其它
重启服务命令: 

    /etc/init.d/jenkins restart 

安装完成后,系统中添加了一个用户jenkins,不要尝试修改该用户的密码. 

`/var/lib/jenkins`下面的文件都是jenkins用户的,对jenkins来说,这个目录就是它的home目录,所以修改这个下面的文件时注意文件的拥有者. 

    sudo su - jenkins 

可以切换到该用户.

访问`localhost:8080`,首先要做的就是添加一个用户所用权限的用户，然后使用该用户sign up。 

jenkins的配置文件在`/etc/default/jenkins`.

### Setting up the job

To use Jenkins to build regular nightlies for multiple devices, follow this quick steps: 

*  Prepare your Android source tree
*  Create a new job, as a multi-configuration project 
*   In Advanced Project Options, check "Custom workspace", and point both the Directory and Directory for sub-builds to the root of your Android tree 
*    Add a new user-defined axis to the matrix, and call it 'device'. In values, you must put each device you want to build, separated by spaces (e.g. 'mako manta flo deb'). 
*    Check 'Run each configuration sequentially' 
*    Add a new 'Execute shell' build step, in order to run a short build script. In Omni's case we have a script at the root of our workspace, thus we put './build_nightly.sh $device', where $device will be replaced by each device for each build. 
*    Save the job, you're all set. 

Create then your build script. Here's Omni build script:  

    #!/bin/bash
    
    export USE_CCACHE=1
    export CCACHE_DIR=/home/build/.ccache
    export BUILDTYPE_NIGHTLY=1
    
    DEVICE=$*
    
    cd /home/build/omni
    . build/envsetup.sh
    repo sync -j48
    rm -rf out/target
    brunch $DEVICE

### Adding a device to a nightly job
Just add the device code into the 'device' axis in the job settings. 

### 遇到的问题
当脚本被触发运行时,使用的jenkins用户的环境变量,会出现找不到环境变量,和许多的权限问题.最后的解决方法是,新建一个节点,指向本机IP和workspace,以ssh登录即可.


### 参考
* [Setting up Jenkins for building nightlies](http://docs.omnirom.org/Setting_up_Jenkins_for_building_nightlies)
* [HOW TO AUTOMATE YOUR ROM BUILDING PROCESS](http://forum.xda-developers.com/showthread.php?t=2467004)