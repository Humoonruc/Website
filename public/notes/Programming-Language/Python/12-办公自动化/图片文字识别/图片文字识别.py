#!/usr/bin/env python
# coding: utf-8

# ## 安装命令：pip install easyocr

# ## 导入相关包

# In[1]:

import easyocr
import pandas as pd
import os

# ## 实例化 easyocr

# In[2]:

reader = easyocr.Reader(['ch_sim', 'en'], gpu=False)
reader.readtext("eat.png", detail=0)

# ## 遍历文件夹下所有图片并识别文字

# In[3]:

files_path = 'C:\\Users\\Humoonruc\\OneDrive\\ICT\\Website\\static\\notes\\Programming-Language\\Python\\12-办公自动化\\图片文字识别'
file = os.listdir(files_path)
# f = file[0]
li = []
for f in file:
    real_url = os.path.join(files_path, f)
    result = reader.readtext(real_url, detail=0)
    s = ' '.join(result)
    li.append(s)
li

# ## 识别结果存储到excel

# In[5]:


def process(li):
    lis = []
    for s in li:
        s1 = s.replace(':  ', ':').replace(': ', ':')
        dic = {}
        each = s1.split()
        dic['姓名'] = each[0].split(':')[1]
        dic['身份证号码'] = each[1].split(':')[1]
        dic['电话'] = each[2].split(':')[1]
        dic['现住址'] = each[3].split(':')[1]
        lis.append(dic)
    df = pd.DataFrame(lis)
    return df


# In[9]:

res = process(li)
print(len(res))
ind = range(1, len(res) + 1)
res.index = ind
res.to_excel(r'C:\Users\cherich\Desktop\infos.xlsx')
