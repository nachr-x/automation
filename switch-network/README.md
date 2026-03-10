## 介绍
Mac 作为主力机器，承担了我 80% 的娱乐时间和 100% 的开发工作。

我在 MacOS 上创建了两个账户，一个用于娱乐，一个用于开发，避免互相影响。

开发时经常用到 ChatGPT、Claude Code 等服务，这些服务需要纯净的美国住宅 IP。娱乐时访问Google、Youtube、Twitter 或者其他国外网站对 IP 纯净度没有太高要求，而且连接 HK 节点可以大幅下降RTT时延。

**因此，需要为 MacOS 的两个用户分别配置网络。** 但是 MacOS 不支持 Network Namespace，不同用户只能共享一个内核网络协议栈。

考虑到我有一个 Wi-Fi 网卡和一个 2.5G 有线网卡，可以给两个网卡配置不同的静态 IP，2.5G有线网卡IP走美国节点，Wi-Fi 网卡IP 走香港节点。

切换用户时，自动配置网卡优先级（默认路由），以满足不同用户的网络访问要求。而且只更改网卡优先级，没有更改 IP，切换用户后也不会中断已有的连接。 


## 配置
### 1. 准备执行脚本
```
sudo vim switch_network_order_by_user.sh
sudo chmod 755 switch_network_order_by_user.sh
sudo chown root:wheel switch_network_order_by_user.sh
```

先手动测一次：
```
sudo ./switch_network_order_by_user.sh
```

### 2. 写事件监听程序（Swift）
```
swiftc -O main.swift -o console-user-listener
sudo chown root:wheel console-user-listener
sudo chmod 755 console-user-listener 
```

### 3. 配置 LaunchDaemon
```
sudo vim /Library/LaunchDaemons/local.consoleuser.listener.plist
```

设置权限
```
sudo chown root:wheel /Library/LaunchDaemons/local.consoleuser.listener.plist
sudo chmod 644 /Library/LaunchDaemons/local.consoleuser.listener.plist
```

加载
```
sudo launchctl bootstrap system /Library/LaunchDaemons/local.consoleuser.listener.plist
sudo launchctl enable system/local.consoleuser.listener
sudo launchctl kickstart -k system/local.consoleuser.listener
```
验证（看日志）
```
sudo tail -f /var/log/consoleuser-listener.log /var/log/consoleuser-listener.err
```
