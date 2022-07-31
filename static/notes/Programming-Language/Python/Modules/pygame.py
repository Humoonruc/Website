#!/usr/bin/env python
# coding: utf-8

# # pygame

# In[1]:

import time
import pygame
import random
import os

# In[2]:


def play_music(file):
    pygame.mixer.init()
    pygame.mixer.music.load(file)
    pygame.mixer.music.play()
    time.sleep(10)
    pygame.mixer.music.stop()


# In[3]:


def shuffle_play():
    dir_list = os.listdir(
        r"C:\Users\humoo\OneDrive\ICT\Website\static\notes\Programming-Language\Python\Modules\music"
    )
    random.shuffle(dir_list)
    file = r"C:\Users\humoo\OneDrive\ICT\Website\static\notes\Programming-Language\Python\Modules\music/" + random.choice(
        dir_list)
    play_music(file)


# In[4]:


def specific_play():
    file = r"C:\Users\humoo\OneDrive\ICT\Website\static\notes\Programming-Language\Python\Modules\music/杭州-西子夜.mp3"
    play_music(file)


# In[5]:


def display():
    print("本程序由 Humoon 制作")


# In[8]:


def main():
    display()
    while True:
        time.sleep(1)
        task_time = time.strftime("%H:%M:%S")
        print("\r当前系统时间为", task_time, end="")
        if task_time == "11:51:00":
            specific_play()
            break
        if task_time == "16:00:00":
            shuffle_play
            break


# In[9]:

main()
