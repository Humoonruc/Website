# BatchInstall.py
# 第三方库自动安装脚本

import os

libs = {'beautifulsoup4', 'django', 'docopt',
        'flask', 'itchat', 'matplotlib', 'numpy',
        'pillow', 'sklearn', 'networkx', 'openpyxl',
        'pandas', 'pprint', 'pyopengl', 'PyPDF2',
        'pyperclip', 'pyqt5', 'python-docx', 'pygame',
        'requests', 'selenium', 'sympy', 'werobot',
        'wheel', 'wxpy'}


def getTxt():
    return open("常用库.txt", "r").read()


words = getTxt().split(',')

try:
    for word in words:
        os.system("pip install " + str(word))
        print("{}安装成功".format(word))
    for lib in libs:
        os.system("pip install " + lib)
        print("{}安装成功".format(lib))
except:
    print('Failed Somehow')
