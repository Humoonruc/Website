# PyPDF2 模块

本模块的主要用途仍然是办公自动化： （1）多个pdf文件的合并、拆分，对部分页面的抽取和删除 （2）提取一部分pdf的文本

``` {.python}
import os, random, time, re, json, docx, PyPDF2

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

def main():
    pdfFileObj = open('meetingminutes.pdf', 'rb') # 二进制读
    pdfReader = PyPDF2.PdfFileReader(pdfFileObj)
    print(pdfReader.numPages) # 页数
    pageObj = pdfReader.getPage(0) # 读第一页
    print(pageObj.extractText()) # 提取字符串

    # 利用已有的 pdf 组织新的 pdf
    # 合并两个 pdf
    pdf1File = open('meetingminutes.pdf', 'rb')
    pdf2File = open('meetingminutes2.pdf', 'rb')
    pdf1Reader = PyPDF2.PdfFileReader(pdf1FileObj)
    pdf2Reader = PyPDF2.PdfFileReader(pdf2FileObj)
    pdfWriter = PyPDF2.PdfFileWriter()

    for pageNum in range(pdf1Reader.numPages):
        pageObj = pdf1Reader.getPage(pageNum)
        pdfWriter.addPage(pageObj)

    for pageNum in range(pdf2Reader.numPages):
        pageObj = pdf2Reader.getPage(pageNum)
        pdfWriter.addPage(pageObj)

    pdfOutputFile = open('combinedminutes.pdf', 'wb')
    pdfWriter.write(pdfOutputFile)
    pdfOutputFile.close()
    pdf1File.close()
    pdf2File.close()

    # page1 = PyPDF2.PdfFileReader(打开文件的句柄).getPage(n) 是一个页面对象
    # page2 是另一个页面对象
    # page1.mergePage(page2) 可以将两个页面重叠起来，通常用于添加水印
    # PyPDF2.PdfFileWriter().addPage(重叠起来的页面对象) 便将新页面加入了一个 PdfFileWriter 对象，这个对象便可以使用 .write(文件句柄) 保存成一个pdf了
    # 最后关闭所有的读文件句柄和写文件句柄


if __name__ == "__main__":
    logging.debug('Start of program\n')
    main()
    logging.debug('\nEnd of program')
```
