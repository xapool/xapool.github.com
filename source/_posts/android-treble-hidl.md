---
title: Android Treble 架构下的 HAL
date: 2018-11-09 12:26:51
categories:
    - Android
tags:
    - HAL
---

在 Android 8.0 时，Treble Project 重新设计了 Android 操作系统框架，以便让制造商能够以更低的成本，更轻松、更快速地将设备更新到新版 Android。在这种新架构中，采用 HIDL（HAL 接口定义语言，发音为 "hide-l"）来指定 framework 和 HAL 层之间的接口，从而可以实现无需重新编译 HAL，便能升级系统。

<!--more-->

## HAL 类型和概念
这一块感觉官方文档的描述不够清楚，稀里糊涂的，单读文档概念都不明白。尝试先搞清楚 Treble 中绑定式和直通式 HAL 的概念。官方的中文翻译是：
* 绑定式 HAL。 以 HAL 接口定义语言 (HIDL) 表示的 HAL。这些 HAL 取代了早期 Android 版本中使用的传统 HAL 和旧版 HAL。在绑定式 HAL 中，Android 框架和 HAL 之间通过 Binder 进程间通信 (IPC) 调用进行通信。所有在推出时即搭载了 Android 8.0 或更高版本的设备都必须只支持绑定式 HAL
* 直通式 HAL。 以 HIDL 封装的传统 HAL 或旧版 HAL。这些 HAL 封装了现有的 HAL，可在绑定模式和 Same-Process（直通）模式下使用。升级到 Android 8.0 的设备可以使用直通式 HAL

这里的绑定式 HAL(Binderized HALs)、直通式 HAL (Passthrough HALs)，应该指的是 HAL 层的共享库 .so 文件。其中直通式 HAL，是把 Treble Project 之前的传统 HAL 或旧版 HAL 库文件使用 HIDL 进行了封装，而封装后的库文件可用于 Treble Project 中的绑定模式和 Same-Process（直通）模式。  

在看一下官方的 roadmap:

![HAL Roadmap](/media/treble_cpp_legacy_hal_progression.png "HAL Roadmap")  

这 ①②③④ 四种模式，是到目前为止四种实现架构。
1. ① 是 Treble Project 之前使用的实现架构，使用的是传统 HAL 和旧版 HAL
2. ② 直通模式，passthrough mode。如图所示，Framework 和 HAL 层工作在同一个进程当中，下面的 HAL 是使用 HIDL 封装后的库，是直通式 HAL。这些库文件也可用于 ③ 绑定模式
3. ③ 绑定模式，binderized mode。是直通式 HAL binder 化，变为绑定式 HAL。Framework 和  HAL 层工作在不同的进程，之间通过 Binder 进行 IPC
4. ④ 纯绑定式。相对于 ③ 来说，绑定式 HAL 中并不包含直通式 HAL，因此称为纯绑定式

因此根据谷歌要求，出厂时就搭载 8.0 的设备，除了谷歌规定的 android.hardware.graphics.mapper@1.0 和 android.hardware.renderscript@1.0 需使用 ②直通模式，其它 HAL 只能采用 ③ 和 ④ 模式的实现架构。  

而升级到 8.0 的设备，除谷歌规定外，其它 HAL 则可使用 ②③④ 三种实现架构。既是供应商映像提供的所有其他 HAL 既可以在直通模式下使用，也可以在绑定模式下使用，也可完全使用纯绑定式。  

补充：
旧版 HAL 是直接被编译进系统，如 WLAN 就在[libhardware_legacy](https://android.googlesource.com/platform/hardware/libhardware_legacy/+/refs/tags/android-7.1.2_r36) 中；传统 HAL 是通过 libhardware 库中 [get_hw_module()](https://android.googlesource.com/platform/hardware/libhardware/+/refs/tags/android-8.1.0_r65/hardware.c#216) 的方式来获取。未使用 HIDL 表示的 HAL 有 openGL 和 Vulkan。

## 实现模式的架构差异
②③④ 三种实现架构从实现上来看，当然也是不同的

### 直通模式
和 Framework 工作在同一个进程当中，因没有 service 进程，服务也没有被事先注册到 hwservicemanager，Framework 通过 Binder 得到的是同一个进程中的实例。在 manifest.xml 中 transport 类型为 passthrough。以 android.hardware.graphics.composer@2.1 为例，在 [Android.bp](https://android.googlesource.com/platform/hardware/interfaces/+/refs/tags/android-8.1.0_r65/graphics/composer/2.1/default/Android.bp#22) 中，Hwc.cpp 被编译为 `android.hardware.graphics.composer@2.1-impl.so`，其 [HIDL_FETCH_IComposer](https://android.googlesource.com/platform/hardware/interfaces/+/refs/tags/android-8.1.0_r65/graphics/composer/2.1/default/Hwc.cpp#747) 方法中会使用 hw_get_module() 方法去加载传统 HAL。

### 绑定模式
而将直通模式中的直通式 HAL，添加上 service 进程，修改 transport 类型为 hwbinder，就成为了绑定模式。service 的注册使用的是 [defaultPassthroughServiceImplementation()](https://android.googlesource.com/platform/hardware/interfaces/+/refs/tags/android-8.1.0_r65/graphics/composer/2.1/default/service.cpp#43) 方法。

### 纯绑定式
service 的注册方法都是 `registerAsService()`，在 manifest.xml 中的 transport 类型为 hwbinder，不再单独编译 `*-impl.so`，而是全编译进 service 中。以 android.hardware.power@1.1 默认实现为例。android.hardware.power@1.1-service 服务启动时，服务的注册方法是 [registerAsService()](https://android.googlesource.com/platform/hardware/interfaces/+/62cc79bdf0c52c773602d9e93bbf732b1c54b934/power/1.1/default/service.cpp#74)。在 [Android.bp](https://android.googlesource.com/platform/hardware/interfaces/+/62cc79bdf0c52c773602d9e93bbf732b1c54b934/power/1.1/default/Android.bp#21) 中将两个源文件编译为 android.hardware.power@1.1-service。有意思的是在 service 的 main 方法中居然会去 [hw_get_module(POWER_HARDWARE_MODULE_ID, &hw_module)](https://android.googlesource.com/platform/hardware/interfaces/+/62cc79bdf0c52c773602d9e93bbf732b1c54b934/power/1.1/default/service.cpp#47) 加载传统 HAL，那这个默认实现 1.1 版相对于 1.0 版就没有意义了。也因并没有厂商使用这个默认版，[谷歌干脆移除了](https://android.googlesource.com/platform/hardware/interfaces/+/4497a5fe338c4a19dc31312641b2caa8454eb24e)。

### 小结
在直通模式和绑定模式中，`*-impl.so` 库文件通过 `HIDL_FETCH_I***` 方法来加载传统 HAL，因此厂商也可把所有的实现放入 impl 中，如 health 和 bluetooth 的默认实现，在 HIDL_FETCH_IHealth 返回的是自己的实例。纯绑定式中，厂商的实现就都在 service 当中了。

## 服务的注册和获取
服务注册或获取服务端实例过程中，都会传递一个布尔值 getStub：
1. getStub 为 true 时，不会去读 manifest.xml 中指定 transport 类型
2. getStub 为 false 时，则会读取 manifest.xml 中 transport 类型

### 服务的注册
上面也提到了，服务的注册方法有两个，`defaultPassthroughServiceImplementation()` 由绑定模式使用；`registerAsService()` 由纯绑定模式使用。因直通模式并没有 service deamon，因此系统启动时，并不会进行注册。

#### 绑定模式
绑定模式调用 `defaultPassthroughServiceImplementation()` 方法，在其调用链中会调用 `getService()` 方法，并传递 getStub 为 true。getService 会首先获取 hwservicemanager 代理对象，请求 hwservicemanager 进程查询所要注册的 HIDL 服务的 transport 类型(通过读取 /vendor/manifest.xml 文件)。因为传递的 getStub 为 ture，所以这里获取到的 transport 类型在注册时并不起什么作用，将始终通过 `getPassthroughServiceManager()` 方法获取一个 PassthroughServiceManager 对象，调用其 `get(const hidl_string& fqName, const hidl_string& name)` 方法来获取所要注册的 HIDL 服务对象(如图所示)，最后调用 registerReference 和 registerAsService 完成服务的注册。

![Get HIDL Service](/media/get_hidl_service.png "get hidlservice")

#### 纯绑定模式
纯绑定式，使用不到绑定模式前面的那些，直接 registerAsService，注册到 hwservicemanager。

#### 参考
详见：[AndroidO Treble架构下Hal进程启动及HIDL服务注册过程](https://blog.csdn.net/yangwen123/article/details/79854267)，就不贴代码了。

### 服务的查询获取
获取服务时的 getService 方法过程中，传递的 getStub 为 false，因此根据指定的 transport 类型来选择接口对象获取方式：
- 为 passthrough 时，使用 `getPassthroughServiceManager()` 方法从本进程地址空间中获取
- 为 hwbinder 时，先使用 `defaultServiceManager()` 方法获取 hwservicemanager 的代理对象，然后从 hwservicemanager 中查询获取

#### passthrough
直通模式下客户端去获取服务，和绑定模式注册时服务时对 HIDL 服务的获取过程是一致的。  

`getPassthroughServiceManager()`，返回一个 PassthroughServiceManager 对象，这个 PassthroughServiceManager 类是 `system/libhidl/transport/ServiceManagement.cpp` 的一个内部类。

~~直通模式因事先没有被注册到 hwservicemanager 中去，在客户端申请服务时，才会一并注册到 hwservicemanager，若并没有客户端申请该服务，那么 hwservicemanager 中就不会存在该服务，直通模式最后获取到的是同一进程中的实例，不是一个代理对象。~~

#### hwbinder
在绑定模式和纯绑定模式下，`getService()` 时，调用的是 libhidl 库中的 `defaultServiceManager()`，通过 binder 返回的是 HwServiceManager 实例，最终远程调用 hwservicemanager daemon 中的方法，获取到代理对象

#### 参考
详见：[AndroidO Treble 架构下 HIDL 服务查询过程](https://blog.csdn.net/yangwen123/article/details/79868548)

## 参考
* [Android Treble架构解析](https://blog.csdn.net/xiaosayidao/article/details/75577940)
* [HwServiceManager 学习](http://qinyuyin.gitlab.io/2018-07-04/)
* [Android O Treble 架构 - HIDL源代码分析](http://zhoujinjian.cc/2018/09/28/Android%20O%20Treble%20%E6%9E%B6%E6%9E%84%20-%20HIDL%E6%BA%90%E4%BB%A3%E7%A0%81%E5%88%86%E6%9E%90/index.html#%EF%BC%88%E5%9B%9B%EF%BC%89%E3%80%81Android-O-Treble-%E4%B9%8B-hwservicemanager-%E6%B7%BB%E5%8A%A0%E6%9C%8D%E5%8A%A1%EF%BC%88add%EF%BC%89%E8%BF%87%E7%A8%8B)



