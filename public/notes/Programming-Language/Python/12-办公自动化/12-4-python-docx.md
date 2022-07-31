# python-docx 模块

```python
'''
这个模块的主要作用是
（1）解决一些办公自动化问题，比如大量相似文件的填写。
样式主要靠自己在 word 中设置好，用 Python 微调；程序最大的作用是文字的填充。
（2）本脚本中的 getText() 函数自动获取 word 中的所有文本非常好用。
'''

import os, random, time, re, json, docx

import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
importr('tidyverse')

import requests
from bs4 import BeautifulSoup
from multiprocessing import Pool

import logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
# logging.basicConfig(filename='myProgramLog.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
# logging.disable(logging.CRITICAL)


def getText(filename):
    '''
    该函数可以获得一个 docx 文档的所有文本
    '''
    doc = docx.Document(filename)
    fullText = []
    for para in doc.paragraphs:
        fullText.append('    ' + para.text) # 加缩进
    return '\n\n'.join(fullText) # 加空行


def grammar():
    # 打开一个 docx 文件
    doc = docx.Document('demo.docx') 
    len(doc.paragraphs) # 段落数
    doc.paragraphs[0].text
    len(doc.paragraphs[1].runs) # 一个段落中的 run 对象数
    doc.paragraphs[1].runs[0].text
    doc.paragraphs[1].runs[1].text
    doc.paragraphs[1].runs[2].text
    doc.paragraphs[1].runs[3].text
    
    # 读取 docx 文件，获得完整文本
    FullText = getText('demo.docx')
    print(FullText)

    # 设置样式
    doc.paragraphs[0].style # 获得样式
    doc.paragraphs[0].style = 'Normal' # 设置样式

    # 设置属性
    doc.paragraphs[1].runs[1].underline = True
    doc.paragraphs[1].runs[2].italic = True
    doc.save('restyled.docx')

    # 创建一个docx文件并写入
    doc = docx.Document()
    doc.add_heading('Header 0', 0) # 标题0，即title样式
    doc.add_heading('Header 1', 1) # 标题1，即一个#
    doc.add_paragraph('Hello World!', 'Normal') # 第二个参数是样式
    paraObj1 = doc.add_paragraph('second para') # 该函数不仅写文件，还自动返回 paragraph 对象
    paraObj2 = doc.add_paragraph('third para')
    paraObj1.add_run('This text is being added to the 2nd para.')
    doc.save('helloworld.docx')


if __name__ == "__main__":
    logging.debug('Start of program\n')
    grammar()
    logging.debug('\nEnd of program')
```