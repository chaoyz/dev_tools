#!/usr/bin/python
# -*- coding: UTF-8 -*-

# description: check pid exist and send email.

import smtplib
from email.mime.text import MIMEText
from email.header import Header
import commands
import os

check_command = u"ps -ef | grep 'sh start.sh -m' | grep -v grep | wc -l"
smtp_server_addr = u'smtp.qq.com'
smtp_server_ssl_port = 465
smtp_server_user = u"123456@qq.com"
smtp_server_psw = u"123456"
sender = u"123456@qq.com"
receiver = [u"123456@qq.com"]
message_content = u'升级脚本已经完成！请进行下一步操作。'
message_from = u'123456@qq.com'
message_to = u'运维同事'
message_subject = u'升级通知'


def sendMail():
    message = MIMEText(message_content, 'plain', 'utf-8')
    message["From"] = Header(message_from, 'utf-8')
    message["To"] = Header(message_to, 'utf-8')
    message["Subject"] = Header(message_subject, 'utf-8')
    try:
        smtpObj = smtplib.SMTP_SSL(smtp_server_addr, smtp_server_ssl_port)
        smtpObj.login(smtp_server_user, smtp_server_psw)
        smtpObj.sendmail(sender, receiver, message.as_string())
        print u"send ok."
    except smtplib.SMTPException, e:
        print str(e)
        print u"send failed."
    finally:
        smtpObj.quit()

def createTmpFile(tmp_file_path):
   with open(tmp_file_path, "w+") as f:
            f.write("1") 

if __name__ == "__main__":
    # check tmp file exist or not
    tmp_file_path = u"./pidExist.log"
    if not os.path.exists(tmp_file_path):
        createTmpFile(tmp_file_path)
    stat, text = commands.getstatusoutput(check_command)
    count = int(text)
    processExist = 1
    hasSendMail = False;
    with open(tmp_file_path, 'r') as f:
        try :
            processExist = int(f.read());
        except Exception, e:
            # tmp file content error, 
            print "tmp file content error."
            createTmpFile(tmp_file_path)
        if count <= 0 and processExist > 0:
            sendMail()
            hasSendMail = True;
            print 'send mail.'
    if processExist > 0 and hasSendMail:
        with open(tmp_file_path, "w") as f:
            f.write("0")
