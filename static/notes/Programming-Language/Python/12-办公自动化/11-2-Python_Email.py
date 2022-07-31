import smtplib
from email.mime.text import MIMEText
# from email.utils import formataddr
from email.header import Header


# 第三方 SMTP 服务信息：
# 126 的 SMTP 服务器为 smtp.126.com，端口号25；
# 腾讯企业邮箱的服务器为 smtp.exmail.qq.com，端口号465
mail_host = "smtp.exmail.qq.com" 
server_port = 465 # 服务器端口
mail_sender = "b18500290@ucass.edu.cn" # 发件人邮箱账号
mail_pass = "johQnSMD37LB5edf" # 授权密码，非登录密码！网易的授权密码 hmfyx520，腾讯的 johQnSMD37LB5edf
mail_receiver = ['b18500290@ucass.edu.cn', "humoonruc@126.com"] # 收件人邮箱账号，可以是一个列表，发送给多人

# 主题与内容
title = '测试'  # 邮件主题
content = 'Python爬虫运行异常' # 邮件内容


def mail():
    try:
        msg = MIMEText(content, 'plain', 'utf-8') # 应用内容，格式，编码
        msg['From'] = Header("Python", 'utf-8') # 发件人姓名或昵称
        msg['To'] = Header("Me", 'utf-8') # 收件人姓名或昵称
        msg['Subject'] = Header(title, 'utf-8') # 应用邮件的标题

        # server = smtplib.SMTP(mail_host, server_port)  # 连接到126邮件服务器
        server = smtplib.SMTP_SSL(mail_host, server_port) # 连接到腾讯邮箱服务器
        server.login(mail_sender, mail_pass)  # 登陆
        server.sendmail(mail_sender, mail_receiver, msg.as_string()) # 发送
        server.quit() # 关闭连接
        print ("邮件发送成功")
    except smtplib.SMTPException as e:
        print(e)
        ret=False

mail()