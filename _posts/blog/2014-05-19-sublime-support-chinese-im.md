---
layout:     post
title:      Sublime_text支持中文输入
category: blog
description: 让sublime_text支持中文输入，这在ubuntu上是一直不可以的，以前用过插件来达到中文你输入的目的，不过太繁琐。
---

### 安装编译所需依赖
    sudo apt-get install build-essential libgtk2.0-dev 

### 源代码

    /*
    sublime-imfix.c
    Use LD_PRELOAD to interpose some function to fix sublime input method support for linux.
    By Cjacker Huang <jianzhong.huang at i-soft.com.cn>

    gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
    LD_PRELOAD=./libsublime-imfix.so sublime_text
    */
    #include <gtk/gtk.h>
    #include <gdk/gdkx.h>
    typedef GdkSegment GdkRegionBox;

    struct _GdkRegion
    {
      long size;
      long numRects;
      GdkRegionBox *rects;
      GdkRegionBox extents;
    };

    GtkIMContext *local_context;

    void
    gdk_region_get_clipbox (const GdkRegion *region,
                GdkRectangle    *rectangle)
    {
      g_return_if_fail (region != NULL);
      g_return_if_fail (rectangle != NULL);

      rectangle->x = region->extents.x1;
      rectangle->y = region->extents.y1;
      rectangle->width = region->extents.x2 - region->extents.x1;
      rectangle->height = region->extents.y2 - region->extents.y1;
      GdkRectangle rect;
      rect.x = rectangle->x;
      rect.y = rectangle->y;
      rect.width = 0;
      rect.height = rectangle->height;
      //The caret width is 2;
      //Maybe sometimes we will make a mistake, but for most of the time, it should be the caret.
      if(rectangle->width == 2 && GTK_IS_IM_CONTEXT(local_context)) {
            gtk_im_context_set_cursor_location(local_context, rectangle);
      }
    }

    //this is needed, for example, if you input something in file dialog and return back the edit area
    //context will lost, so here we set it again.

    static GdkFilterReturn event_filter (GdkXEvent *xevent, GdkEvent *event, gpointer im_context)
    {
        XEvent *xev = (XEvent *)xevent;
        if(xev->type == KeyRelease && GTK_IS_IM_CONTEXT(im_context)) {
           GdkWindow * win = g_object_get_data(G_OBJECT(im_context),"window");
           if(GDK_IS_WINDOW(win))
             gtk_im_context_set_client_window(im_context, win);
        }
        return GDK_FILTER_CONTINUE;
    }

    void gtk_im_context_set_client_window (GtkIMContext *context,
              GdkWindow    *window)
    {
      GtkIMContextClass *klass;
      g_return_if_fail (GTK_IS_IM_CONTEXT (context));
      klass = GTK_IM_CONTEXT_GET_CLASS (context);
      if (klass->set_client_window)bbbbbbbb
        klass->set_client_window (context, window);

      if(!GDK_IS_WINDOW (window))
        return;
      g_object_set_data(G_OBJECT(context),"window",window);
      int width = gdk_window_get_width(window);
      int height = gdk_window_get_height(window);
      if(width != 0 && height !=0) {
        gtk_im_context_focus_in(context);
        local_context = context;
      }
      gdk_window_add_filter (window, event_filter, context);
    } 

### 编译
    gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC 

### 启动sublime
    LD_PRELOAD=./libsublime-imfix.so subl

### 添加到默认启动
查看sublime-text所在文件夹： 

    which subl
    vi /usr/bin/subl 

复制libsublime-imfix.so到sublime所在文件夹： 

    sudo cp libsublime-imfix.so /opt/sublime_text 

#### 方法一
    cd /usr/bin/
    sudo touch sublime_text3 
    sudo chmod a+x sublime_text3
    sudo vi sublime_text3

添加内容：

    #!/bin/bash
    SUBLIME_HOME="/opt/sublime_text"
    LD_LIB=$SUBLIME_HOME/libsublime-imfix.so
    sh -c "LD_PRELOAD=$LD_LIB $SUBLIME_HOME/sublime_text $@"

保存退出。 

编辑`/usr/share/applications`将其中的三处`/opt/sublime_text/sublime_text`修改为`/usr/bin/sublime_text3`。 

这样无论在终端中执行`sublime_text3`还是双击或者右键打开文本都可以输入中文了。

#### 方法二
编辑`/usr/bin/subl`，在最后一行上面添加： 

    export LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so

编辑`/usr/share/applications`将其中的三处`/opt/sublime_text/sublime_text`替换为`/usr/bin/subl`

### 参考
* [Input method support](http://www.sublimetext.com/forum/viewtopic.php?f=3&t=7006&start=10#p41343)