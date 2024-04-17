## ss-plugins.sh (Note: If an unexpected error occurs when running the script, please execute the ./ss-plugins.sh script to upgrade the script。)

## Download and install:
``` bash
wget -N --no-check-certificate -c -t3 -T60 -O ss-plugins.sh https://git.io/fjlbl
chmod +x ss-plugins.sh
./ss-plugins.sh
```

&nbsp;

```
Usage:
  ./ss-plugins.sh [options...] [args...]

Available Options:
  install          Install
  uninstall        Uninstall
  update           Update
  start            Start
  stop             Stop
  restart          Restart
  status           Check status
  script           Update script
  show             Visualize configuration
  log              View log files
  catcfg           View original configuration files
  uid              Add a new uid user (Cloak)
  cert             Apply for certificates for .cf .ga .gq .ml .tk (90 days)
  link             Generate a new SS:// link using the newly added uid (Cloak)
  scan             Generate a scannable QR code in the current terminal using the ss:// link
  help             Print help information and exit
```

&nbsp;

```shell
Here are the relevant directories：

  SS-libev Installation Directory：/usr/local/bin
  SS-libev Startup File：/etc/init.d/shadowsocks-libev
  SS-libev Configuration File：/etc/shadowsocks/config.json
    
  SS-rust Installation Directory：/usr/local/bin
  SS-rust Startup File：/etc/init.d/shadowsocks-rust
  SS-rust Configuration File：/etc/shadowsocks/config.json
    
  Go-ss2 Installation Directory：/usr/local/bin
  Go-ss2 Startup File：/etc/init.d/go-shadowsocks2
  Go-ss2 Configuration File：/etc/shadowsocks/config.json

  rabbit-tcp Configuration File: /etc/rabbit-tcp/config.json
  caddy Installation Directory: /usr/local/caddy
  caddy Configuration File: /usr/local/caddy/Caddyfile

  nginx Binary File: /usr/sbin/nginx
  nginx Configuration File: /etc/nginx/nginx.conf

  SS-libev Log File: /var/log/shadowsocks-libev.log
  SS-rust Log File: /var/log/shadowsocks-rust.log
  Go-ss2 Log File: /var/log/go-shadowsocks2.log
  kcptun Log File: /var/log/kcptun.log
  cloak Log File: /var/log/cloak.log
  rabbit-tcp Log File: /var/log/rabbit-tcp.log
  caddy Error Log File: /var/log/caddy-error.log
  caddy Access Log File: /var/log/caddy-access.log
  nginx Error Log File: /var/log/nginx-error.log
  nginx Access Log File: /var/log/nginx-access.log

  acme.sh Installation Directory: ~/.acme.sh
  acme.sh Generated Certificate Directory: ~/.acme.sh xxx.xxx(domain)/

  Cloudflare API Storage Path: /root/.cloudflare/apiInfo
  Other Plugin Executable Binary Directory: /usr/local/bin
```

&nbsp;

1. ### Main Menu

```shell
 Shadowsocks-libev一 One-Click Management Script [v1.0.0]

  1. BBR
  2. Install
  3. Uninstall

 Current Status: Installed and Running

Please enter a number [1-3]:
```

&nbsp;

2. ### Optional plugins and plugin options:


~~~shell
  1. v2ray-plugin
      1. ws
      2. wss
      3. quic
      4. grpc
  2. kcptun
  3. simple-obfs
      1. http
      2. tls
  4. goquiet
  5. cloak
  6. mos-tls-tunnel
      1. tls
      2. wss
  7. rabbit-tcp
  8. simple-tls
      1. v0.3.4
      2. v0.4.7
      3. latest
  9. gost-plugin
      1. ws
      2. wss
      3. tls
      4. xtls
      5. quic
      6. http2
      7. grpc
 10. xray-plugin
      1. ws
      2. wss
      3. quic
      4. grpc
 11. qtun
 12. gun
      1. grpc-with-tls
      2. grpc-without-tls


### Note:

When using CDN, please change the CloudFlare "SSL/TLS"-"Overview" tab to "Full" or "Full (Strict)" mode (the former does not validate the server certificate, while the latter does), otherwise, opening your domain in a browser will prompt an error "too many redirects". Additionally, when using CDN + gRPC, please enable gRPC in the CloudFlare "Network" tab.
~~~

&nbsp;

3. ### Brief installation steps - animation preview, taking ss + v2ray-plugin as an example：

![01-v2ray-plugin](./example.gif)

&nbsp;

4. ### After the installation is completed, the terminal configuration is shown below, taking ss + kcptun as an example：

~~~shell
 Shadowsocks configuration information:

Address: 66.66.66.66
Port: 6666
Password: bc1xQkj3
Encryption: aes-256-gcm
Plug-in: kcptun
Plugin options:
Plug-in parameters: -l %SS_LOCAL_HOST%:%SS_LOCAL_PORT% -r %SS_REMOTE_HOST%:%SS_REMOTE_PORT% --crypt aes --key 0EP4edcP --mtu 1350 --sndwnd 1024 --rcvwnd 1024 --mode fast2 --datashard 10 - -parityshard 3 --dscp 46 --nocomp true

Mobile phone parameters : crypt=aes;key=0EP4edcP;mtu=1350;sndwnd=1024;rcvwnd=1024;mode=fast2;datashard=10;parityshard=3;dscp=46;nocomp=true

 SS QR code: ./ss-plugins.sh scan < ss://links >
 SS  Link : ss://YWVzLTI1Ni1nY206YmMxeFFrajM=@66.66.66.66:6666/?plugin=kcptun%3bcrypt%3daes%3bkey%3d0EP4edcP%3bmtu%3d1350%3bsndwnd%3d1024%3brcvwnd%3d1024%3bmode%3dfast2%3bdatashard%3d10%3bparityshard%3d3%3bdscp%3d46%3bnocomp%3dtrue
~~~

&nbsp;

![Stargazers over time](https://starchart.cc/loyess/Shell.svg)

&nbsp;

This script is adapted from various great masters, so it is of a so-so level and is convenient for your own use.

It supports linux-amd64, and some supports linux-arm64 (aarch64). Don’t try the others. It supports CentOS6+ | Ubuntu16.04+ | Debian9+. If other lower versions are supported, please try it yourself. It is recommended to use the latest version。

The domain name to be used by ~~v2ray-plugin can be obtained from [freenom.com](https://www.freenom.com). To apply, you need to attach an agent. Please fill in the information of which country the agent is based on. Otherwise, the application may not be possible. ~~ (It seems to be invalid. Those who have an account can still register)

In addition, the generated ss:// link does not support the import of plug-in parameters and needs to be copied and pasted manually. When using the kcptun plug-in, this link only supports import on mobile phones.

&nbsp;

**Related downloads：**

- [shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)
- [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
- [go-shadowsocks2](https://github.com/shadowsocks/go-shadowsocks2)
- [shadowsocks-windows](<https://github.com/shadowsocks/shadowsocks-windows>)
- [shadowsocks-android](<https://github.com/shadowsocks/shadowsocks-android>)
- [v2ray-plugin](<https://github.com/shadowsocks/v2ray-plugin>)
- [v2ray-plugin (teddysun)](<https://github.com/teddysun/v2ray-plugin>)
- [v2ray-plugin-android](<https://github.com/shadowsocks/v2ray-plugin-android>)
- [v2ray-plugin-android (teddysun)](<https://github.com/teddysun/v2ray-plugin-android>)
- [kcptun](https://github.com/xtaci/kcptun)
- [kcptun-android](https://github.com/shadowsocks/kcptun-android)
- [simple-obfs](https://github.com/shadowsocks/simple-obfs)
- [simple-obfs-android](https://github.com/shadowsocks/simple-obfs-android)
- [GoQuiet](https://github.com/cbeuw/GoQuiet)
- [GoQuiet-android](https://github.com/cbeuw/GoQuiet-android)
- [GoQuiet-android (Support Android10)](https://github.com/notsure2/GoQuiet-android)
- [Cloak](https://github.com/cbeuw/Cloak)
- [Cloak-android](https://github.com/cbeuw/Cloak-android)
- [mos-tls-tunnel](https://github.com/IrineSistiana/mos-tls-tunnel)
- [mostunnel-android](https://github.com/IrineSistiana/mostunnel-android)
- [rabbit-tcp](https://github.com/ihciah/rabbit-tcp)
- [rabbit-plugin](https://github.com/ihciah/rabbit-plugin)
- [simple-tls](https://github.com/IrineSistiana/simple-tls)
- [simple-tls-android](https://github.com/IrineSistiana/simple-tls-android)
- [gost-plugin](https://github.com/maskedeken/gost-plugin)
- [gost-plugin-android](https://github.com/maskedeken/gost-plugin-android)
- [xray-plugin](https://github.com/teddysun/xray-plugin)
- [xray-plugin-android](https://github.com/teddysun/xray-plugin-android)
- [qtun](https://github.com/shadowsocks/qtun)
- [gun](https://github.com/Qv2ray/gun)
