# ssh免输入密码脚本
日常远程登录测试机输入账号密码很麻烦，写了这个脚本用来快速免密码登录测试机，在mac和centos下经过测试
# 安装
1. 保存文件到/usr/local/bin目录，并添加权限
 - curl https://github.com/chaoyz/dev_tools/tree/master/02_linux/ssh_quick_login/myssh > /usr/local/bin/myssh
 - curl https://github.com/chaoyz/dev_tools/tree/master/02_linux/ssh_quick_login/sshautologin.sh > /usr/local/bin/sshautologin.sh
 - chmod +x /usr/local/bin/myssh
 - chmod +x /usr/local/bin/sshautologin.sh
2. 修改测试机登录账号和密码，vim /usr/local/bin/myssh
![图片1](https://github.com/chaoyz/dev_tools/raw/master/images/02_linux_ssh_quick_login.png)
3. 保存退出即可

# 使用方法
## 使用方法一
命令行输入myssh，弹出对话框选择对应服务器即可：

![图片1](https://github.com/chaoyz/dev_tools/raw/master/images/02_linux_ssh_quick_login_2.png)
## 使用方法二
当配置服务器较多的时候可以在命令行后面输入一个参数，脚本会根据参数匹配服务器信息，例如我这里输入"myssh 24"显示如下：

![图片1](https://github.com/chaoyz/dev_tools/raw/master/images/02_linux_ssh_quick_login_3.png)
