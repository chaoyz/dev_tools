# check_process
检查进程是否存在，若发现不存在则发送邮件，简单的检测工具。

# 配置&使用
1. 编辑文件check_process.py
2. 修改配置项
    - check_command 需要检查的命令例如："ps -ef | grep 'sh start.sh -m' | grep -v grep | wc -l" 检查sh start.sh -m是否在运行
    - smtp_server_addr 使用的smtp服务器地址
    - smtp_server_ssl_port 连接smtp服务器地址的ssl端口
    - smtp_server_user 使用smtp服务的用户登录名
    - smtp_server_psw 使用smtp服务的用户密码
    - sender 邮件发送人
    - receiver 邮件接收人
    - message_content 发送邮件内容
    - message_from 邮件发送人
    - message_to 邮件接收人
    - message_subject 邮件主题
3. 将文件check_process.py放到root目录下，设置crontab定时执行，系统安装crontab后执行crontab -e编辑，填写*/5 * * * * /usr/bin/python /root/check_process.py >> /tmp/check_process.log