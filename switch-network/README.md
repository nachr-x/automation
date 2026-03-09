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
