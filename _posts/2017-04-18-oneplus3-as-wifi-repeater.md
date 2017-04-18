---
layout:     post
title:      使用一加3做 WIFI 中继器
category:
    - Android
tags:
    - Openwrt-x86
---

隔壁学校的 wifi 网络不错，但是因为离得远，信号差，只能在窗户边能连得上。买了一个 360 wifi 中继器，但速度掉的厉害，而用手机直接连接网速倒是正常，就想着把手机作为 wifi 中继器。记得自己的第一台 android 手机，中兴 v880 当时是支持 wifi 中继的，一边连着 wifi，一边扩展 wifi 信号，后来才知道那算是中兴特有的。找了一圈，并没有找到这样的 APP，fqrouter2 倒是有这个功能，但是作者已经停止维护，在我手机上直接启动失败。参考 fqrouter2 的文章和脚本终于让 oneplus3 STA+AP 一起工作了。

## 使用一加3做 wifi 中继器脚本配置

* ONEPLUS A3000
* 系统 cm-13.0, Android 6.0.1
* root 权限 
* iw iwlist wpa_cli 等二进制文件

一加3 采用的是[QCA6164A](https://www.qualcomm.com/products/vive/chipsets) wifi 芯片，支持 802.11ac，最高有 434M 带宽。

系统本身自带的便携式 WLAN 热点功能，只能分享移动数据的网络，不能够做为一个 wifi repeater，开启时自动关闭 wifi 连接和 wpa_supplicant进程，并开启 hostapd 进程来提供 AP。 但系统支持 [WIFI Direct](https://developer.android.com/training/connect-devices-wirelessly/wifi-direct.html) 功能，也就是说设备在连接着 wifi 的时，可以开启一个热点，其它设备可以通过这个热点加入到 P2P group 中。但是 WIFI Direct 不支持手动设置密码，连接外网等。

查看网卡设备信息
```
root@oneplus3:/data/local/tmp # iw phy
Wiphy phy3
    max # scan SSIDs: 10
    max scan IEs length: 500 bytes
    max # sched scan SSIDs: 0
    max # match sets: 0
    Retry short limit: 7
    Retry long limit: 4
    Coverage class: 0 (up to 0m)
    Device supports roaming.
    Device supports T-DLS.
    Supported Ciphers:
        * WEP40 (00-0f-ac:1)
        * WEP104 (00-0f-ac:5)
        * TKIP (00-0f-ac:2)
        * 00-40-96:254
        * 00-40-96:255
        * CCMP-128 (00-0f-ac:4)
        * WPI-SMS4 (00-14-72:1)
        * CMAC (00-0f-ac:6)
    Available Antennas: TX 0 RX 0
    Supported interface modes:
         * IBSS
         * managed
         * AP
         * P2P-client
         * P2P-GO
    Band 1:
        Capabilities: 0x9072
            HT20/HT40
            Static SM Power Save
            RX Greenfield
            RX HT20 SGI
            RX HT40 SGI
            No RX STBC
            Max AMSDU length: 3839 bytes
            DSSS/CCK HT40
            L-SIG TXOP protection
        Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
        Minimum RX AMPDU time spacing: 16 usec (0x07)
        HT Max RX data rate: 72 Mbps
        HT TX/RX MCS rate indexes supported: 0-7
        Bitrates (non-HT):
            * 1.0 Mbps
            * 2.0 Mbps
            * 5.5 Mbps
            * 11.0 Mbps
            * 6.0 Mbps
            * 9.0 Mbps
            * 12.0 Mbps
            * 18.0 Mbps
            * 24.0 Mbps
            * 36.0 Mbps
            * 48.0 Mbps
            * 54.0 Mbps
        Frequencies:
            * 2412 MHz [1] (20.0 dBm)
            * 2417 MHz [2] (20.0 dBm)
            * 2422 MHz [3] (20.0 dBm)
            * 2427 MHz [4] (20.0 dBm)
            * 2432 MHz [5] (20.0 dBm)
            * 2437 MHz [6] (20.0 dBm)
            * 2442 MHz [7] (20.0 dBm)
            * 2447 MHz [8] (20.0 dBm)
            * 2452 MHz [9] (20.0 dBm)
            * 2457 MHz [10] (20.0 dBm)
            * 2462 MHz [11] (20.0 dBm)
            * 2467 MHz [12] (20.0 dBm)
            * 2472 MHz [13] (20.0 dBm)
            * 2484 MHz [14] (disabled)
    Band 2:
        Capabilities: 0x9072
            HT20/HT40
            Static SM Power Save
            RX Greenfield
            RX HT20 SGI
            RX HT40 SGI
            No RX STBC
            Max AMSDU length: 3839 bytes
            DSSS/CCK HT40
            L-SIG TXOP protection
        Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
        Minimum RX AMPDU time spacing: 16 usec (0x07)
        HT Max RX data rate: 72 Mbps
        HT TX/RX MCS rate indexes supported: 0-7
        VHT Capabilities (0x000003b2):
            Max MPDU length: 11454
            Supported Channel Width: neither 160 nor 80+80
            RX LDPC
            short GI (80 MHz)
            TX STBC
        VHT RX MCS set:
            1 streams: MCS 0-7
            2 streams: MCS 0-7
            3 streams: MCS 0-7
            4 streams: MCS 0-7
            5 streams: MCS 0-7
            6 streams: MCS 0-7
            7 streams: MCS 0-7
            8 streams: MCS 0-7
        VHT RX highest supported: 0 Mbps
        VHT TX MCS set:
            1 streams: MCS 0-7
            2 streams: MCS 0-7
            3 streams: MCS 0-7
            4 streams: MCS 0-7
            5 streams: MCS 0-7
            6 streams: MCS 0-7
            7 streams: MCS 0-7
            8 streams: MCS 0-7
        VHT TX highest supported: 0 Mbps
        Bitrates (non-HT):
            * 6.0 Mbps
            * 9.0 Mbps
            * 12.0 Mbps
            * 18.0 Mbps
            * 24.0 Mbps
            * 36.0 Mbps
            * 48.0 Mbps
            * 54.0 Mbps
        Frequencies:
            * 4920 MHz [184] (disabled)
            * 4940 MHz [188] (disabled)
            * 4960 MHz [192] (disabled)
            * 4980 MHz [196] (disabled)
            * 5040 MHz [8] (disabled)
            * 5060 MHz [12] (disabled)
            * 5080 MHz [16] (disabled)
            * 5180 MHz [36] (23.0 dBm)
            * 5200 MHz [40] (23.0 dBm)
            * 5220 MHz [44] (23.0 dBm)
            * 5240 MHz [48] (23.0 dBm)
            * 5260 MHz [52] (23.0 dBm) (radar detection)
            * 5280 MHz [56] (23.0 dBm) (radar detection)
            * 5300 MHz [60] (23.0 dBm) (radar detection)
            * 5320 MHz [64] (23.0 dBm) (radar detection)
            * 5500 MHz [100] (disabled)
            * 5520 MHz [104] (disabled)
            * 5540 MHz [108] (disabled)
            * 5560 MHz [112] (disabled)
            * 5580 MHz [116] (disabled)
            * 5600 MHz [120] (disabled)
            * 5620 MHz [124] (disabled)
            * 5640 MHz [128] (disabled)
            * 5660 MHz [132] (disabled)
            * 5680 MHz [136] (disabled)
            * 5700 MHz [140] (disabled)
            * 5720 MHz [144] (disabled)
            * 5745 MHz [149] (30.0 dBm)
            * 5765 MHz [153] (30.0 dBm)
            * 5785 MHz [157] (30.0 dBm)
            * 5805 MHz [161] (30.0 dBm)
            * 5825 MHz [165] (30.0 dBm)
            * 5852 MHz [170] (disabled)
            * 5855 MHz [171] (disabled)
            * 5860 MHz [172] (disabled)
            * 5865 MHz [173] (disabled)
            * 5870 MHz [174] (disabled)
            * 5875 MHz [175] (disabled)
            * 5880 MHz [176] (disabled)
            * 5885 MHz [177] (disabled)
            * 5890 MHz [178] (disabled)
            * 5895 MHz [179] (disabled)
            * 5900 MHz [180] (disabled)
            * 5905 MHz [181] (disabled)
            * 5910 MHz [182] (disabled)
            * 5915 MHz [183] (disabled)
            * 5920 MHz [184] (disabled)
    Supported commands:
         * new_interface
         * set_interface
         * new_key
         * start_ap
         * new_station
         * set_bss
         * join_ibss
         * set_pmksa
         * del_pmksa
         * flush_pmksa
         * remain_on_channel
         * frame
         * frame_wait_cancel
         * set_channel
         * tdls_mgmt
         * tdls_oper
         * testmode
         * channel_switch
         * connect
         * disconnect
    Supported TX frame types:
         * IBSS: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
         * managed: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
         * AP: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
         * P2P-client: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
         * P2P-GO: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
    Supported RX frame types:
         * IBSS: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
         * managed: 0x40 0xd0
         * AP: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
         * P2P-client: 0x40 0xd0
         * P2P-GO: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
    WoWLAN support:
         * wake up on anything (device continues operating normally)
         * wake up on disconnect
         * wake up on magic packet
         * wake up on pattern match, up to 4 patterns of 6-64 bytes,
           maximum packet offset 0 bytes
         * can do GTK rekeying
         * wake up on GTK rekey failure
         * wake up on EAP identity request
         * wake up on 4-way handshake
         * wake up on rfkill release
    software interface modes (can always be added):
    valid interface combinations:
         * #{ managed } <= 3,
           total <= 3, #channels <= 2
         * #{ managed } <= 1, #{ IBSS } <= 1,
           total <= 2, #channels <= 1
         * #{ AP } <= 2,
           total <= 2, #channels <= 2
         * #{ P2P-client } <= 1, #{ P2P-GO } <= 1,
           total <= 2, #channels <= 2
         * #{ managed } <= 2, #{ AP } <= 1,
           total <= 3, #channels <= 2, STA/AP BI must match
         * #{ managed } <= 2, #{ P2P-client, P2P-GO } <= 2,
           total <= 4, #channels <= 2, STA/AP BI must match
         * #{ managed } <= 2, #{ P2P-GO } <= 1, #{ AP } <= 1,
           total <= 4, #channels <= 2, STA/AP BI must match
    Device supports HT-IBSS.
    Device supports scan flush.
```

该芯片是支持这些功能
```
Supported interface modes:
         * IBSS
         * managed
         * AP
         * P2P-client
         * P2P-GO
```

```
root@oneplus3:/ # iw dev
phy#0
    Interface p2p0
        ifindex 24
        wdev 0x2
        addr c2:ee:fb:d6:08:0d
        type managed
    Interface wlan0
        ifindex 23
        wdev 0x1
        addr c0:ee:fb:d6:08:0d
        ssid BIUBIU_5G
        type managed
```

网卡有两个 interface，默认启用了 p2p 接口，但开启系统的热点功能后
```
root@oneplus3:/ # iw dev
phy#1
    Interface wlan0
        ifindex 27
        wdev 0x100000001
        addr c0:ee:fb:d6:08:0d
        ssid ONEPLUS A3000
        type AP
```

p2p0 端口消失，只剩下了 wlan0 端口，查看 hostapd 进程的 cmdline
```
root@oneplus3:/ # cat /proc/11047/cmdline
/system/bin/hostapd -e /data/misc/wifi/entropy.bin /data/misc/wifi/hostapd.conf
```

先前的 wpa_supplicant 进程是
```
root@oneplus3:/ # cat /proc/11257/cmdline
/system/bin/wpa_supplicant -ip2p0- Dnl80211 -c/data/misc/wifi/p2p_supplicant.conf -I/system/etc/wifi/p2p_supplicant_overlay.conf -N -iwlan0 -Dnl80211 -c/data/misc/wifi/wpa_supplicant.conf -I/system/etc/wifi/wpa_supplicant_overlay.conf -O/data/misc/wifi/sockets -puse_p2p_group_interface=1 -e/data/misc/wi
fi/entropy.bin
```

wpa_supplicant 同时管理着 p2p0 wlan0 两个 interface，p2p0 interface 的状态
```
root@oneplus3:/data/local/tmp # ./wpa_cli -p /data/misc/wifi/sockets/ -i p2p0 status
wpa_state=DISCONNECTED
p2p_device_address=c2:ee:fb:d6:08:0d
address=c2:ee:fb:d6:08:0d
uuid=4227ede7-6911-52a9-987c-6ce45048dfe1
```

处于未连接状态，使用 [wpa_cli](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/android-7.1.2_r6/wpa_supplicant/README-P2P) 直接添加一个固定的 p2p 分组， wpa_cli 支持交互模式。进行此操作之前，备份一下 `/data/misc/wifi/p2p_supplicant.conf`，防止出错

```
root@oneplus3:/data/local/tmp # ./wpa_cli -p /data/misc/wifi/sockets/ -i p2p0
wpa_cli v2.5-devel-6.0.1
Copyright (c) 2004-2015, Jouni Malinen <j@w1.fi> and contributors

This software may be distributed under the terms of the BSD license.
See README for more details.



Interactive mode

> add_network
0
> set_network 0 mode 3
OK
> set_network 0 disabled 2
OK
> set_network 0 ssid "loopax"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> set_network 0 proto RSN
OK
> set_network 0 pairwise CCMP
OK
> set_network 0 psk "12345678"
OK
> save_config
OK
> list_network
network id / ssid / bssid / flags
0   loopax  any [DISABLED][P2P-PERSISTENT]
> p2p_group_add persistent=0
OK
<3>P2P-GROUP-STARTED p2p-p2p0-0 GO ssid="loopax" freq=5765 passphrase="12345678" go_dev_addr=c2:ee:fb:d6:08:0d [PERSISTENT]
> quit
```

此时，热点就起来了
```
root@oneplus3:/ # iw dev
phy#3
    Interface p2p-p2p0-0
        ifindex 33
        wdev 0x300000003
        addr c2:ee:fb:d6:88:0d
        ssid loopax
        type P2P-GO
    Interface p2p0
        ifindex 32
        wdev 0x300000002
        addr c2:ee:fb:d6:08:0d
        type managed
    Interface wlan0
        ifindex 31
        wdev 0x300000001
        addr c0:ee:fb:d6:08:0d
        ssid BIUBIU_5G
        type managed
```

起来了一个新的接口 p2p-p2p0-0，type 是 P2P-GO, 该接口状态
```
root@oneplus3:/data/local/tmp # ./wpa_cli -p /data/misc/wifi/sockets/ -i p2p-p2p0-0 status
bssid=c2:ee:fb:d6:88:0d
freq=5765
ssid=loopax
id=0
mode=P2P GO
pairwise_cipher=CCMP
group_cipher=CCMP
key_mgmt=WPA2-PSK
wpa_state=COMPLETED
ip_address=192.168.49.1
p2p_device_address=c2:ee:fb:d6:08:0d
address=c2:ee:fb:d6:88:0d
uuid=4227ede7-6911-52a9-987c-6ce45048dfe1
```


热点可以正常连接，但是不能够上网，也 ping 不通 IP，开启设备的网络转发 和 NAT
```
root@oneplus3:/ # echo 1 > /proc/sys/net/ipv4/ip_forward
root@oneplus3:/ # iptables -F
root@oneplus3:/ # iptables -P INPUT ACCEPT
root@oneplus3:/ # iptables -P FORWARD ACCEPT
root@oneplus3:/ # iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
```

这样 ip 就能 ping 的通了，但是 DNS 还是不正常，连接热点的设备手动设置 DNS 的话，就可以正常上网了。重启系统的 dnsmasq，让 DHCP 自动分配 DNS
```
root@oneplus3:/ # killall dnsmasq
root@oneplus3:/ # /system/bin/dnsmasq --no-resolv --no-poll --dhcp-authoritative --server=114.114.114.114 --dhcp-option-force=43,ANDROID_METERED --pid-file --dhcp-range=192
.168.49.2,192.168.49.254,1h
```

这样就是配置了一个完整的 wifi 中继了。 


再次开启中继只需
```
root@oneplus3:/data/local/tmp # ./wpa_cli -p /data/misc/wifi/sockets/ -i p2p0 p2p_group_add persistent=0
```

然后在配置网络转发，和 iptables、 dhcp。

默认两个接口是使用同样的 channel，但是也是可以指定频道的,如
```
root@oneplus3:/data/local/tmp # ./wpa_cli -p /data/misc/wifi/sockets/ -i p2p0 p2p_group_add persistent=0 freq=5825
```

获取 channel 信息
```
root@oneplus3:/ # iwlist wlan0 channel
wlan0     26 channels in total; available frequencies :
          Channel 01 : 2.412 GHz
          Channel 02 : 2.417 GHz
          Channel 03 : 2.422 GHz
          Channel 04 : 2.427 GHz
          Channel 05 : 2.432 GHz
          Channel 06 : 2.437 GHz
          Channel 07 : 2.442 GHz
          Channel 08 : 2.447 GHz
          Channel 09 : 2.452 GHz
          Channel 10 : 2.457 GHz
          Channel 11 : 2.462 GHz
          Channel 12 : 2.467 GHz
          Channel 13 : 2.472 GHz
          Channel 36 : 5.18 GHz
          Channel 40 : 5.2 GHz
          Channel 44 : 5.22 GHz
          Channel 48 : 5.24 GHz
          Channel 52 : 5.26 GHz
          Channel 56 : 5.28 GHz
          Channel 60 : 5.3 GHz
          Channel 64 : 5.32 GHz
          Channel 149 : 5.745 GHz
          Channel 153 : 5.765 GHz
          Channel 157 : 5.785 GHz
          Channel 161 : 5.805 GHz
          Channel 165 : 5.825 GHz
          Current Frequency:5.765 GHz (Channel 153)
```

可在 `/data/misc/dhcp/dnsmasq.leases` 文件中查看连接的客户端。

## 参考
* [无线中继启动的条件](http://fqrouter.tumblr.com/post/47259845553/%E6%97%A0%E7%BA%BF%E4%B8%AD%E7%BB%A7%E5%90%AF%E5%8A%A8%E7%9A%84%E6%9D%A1%E4%BB%B6)
* [使用手机做无线中继的可能性探寻](http://fqrouter.tumblr.com/post/43575459548/%E4%BD%BF%E7%94%A8%E6%89%8B%E6%9C%BA%E5%81%9A%E6%97%A0%E7%BA%BF%E4%B8%AD%E7%BB%A7%E7%9A%84%E5%8F%AF%E8%83%BD%E6%80%A7%E6%8E%A2%E5%AF%BB)
* [联想P770手机（MTK6577）无线中继脚本配置方法](http://fqrouter.tumblr.com/post/44298169558/%E8%81%94%E6%83%B3p770%E6%89%8B%E6%9C%BAmtk6577%E6%97%A0%E7%BA%BF%E4%B8%AD%E7%BB%A7%E8%84%9A%E6%9C%AC%E9%85%8D%E7%BD%AE%E6%96%B9%E6%B3%95)
* [wifi repeater start script](https://github.com/fqrouter/fqrouter/blob/master/manager/wifi.py)
* [PATCH](http://lists.shmoo.com/pipermail/hostap/2012-November/026931.html)
