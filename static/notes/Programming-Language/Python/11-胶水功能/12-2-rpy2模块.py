import rpy2.robjects as robjects


# 获取 R 对象

## 变量
a_py = robjects.r("c('a','b','c')")
pi_py = robjects.r('pi')
print(a_py, pi_py, sep='\n')

### .rx()相当于[]，.rx2()相当于[[]]
tmp = robjects.r("list(a = matrix(1:10, nrow = 2), b = 'Hello')")
print(tmp)
print(tmp.names)
print(tmp.rx('a'))
print(tmp.rx(1))
print(tmp.rx2(1))
print(tmp.rx2('a').rx(1, 1)) # first element of 'a'
print(tmp.rx2('a').rx(1, True)) # first row of 'a

## 函数

### 自定义函数
robjects.r('''
           f <- function(r){pi * r}
           ''')
t3 = robjects.r['f'](3)
print(t3)

### 用于导入 R 包的模块
from rpy2.robjects.packages import importr

#### 例1：tidyverse包
importr('tidyverse')

rpaste = robjects.r['str_c'] # 注意，直接调用 R 中的对象要用方括号[]
joined_string = rpaste(robjects.IntVector([1,2,3]), collapse = ';')
print('joined_string: ', joined_string)

#### 例2：data.table包
importr('data.table')

rcode = '''
dt <- tibble(key = letters[1:10], value = 1:10) %>% setDT()
dt[key > 'e', value := value^2]
str_c(dt$value, collapse = ', ')
'''
string = robjects.r(rcode)
print(string)


# 执行 R 代码（一个大字符串），以返回值作为对象，通过 robjects.r() 获取

float_money = 201200131013.03 # 要传入的参数
'main({})'.format(float_money) # 包含参数的字符串

## 组合 R 代码和输入参数
r_script = '''
## 本程序将阿拉伯数字金额转换为大写人民币形式

han_list = c("零" , "壹" , "贰" , "叁" , "肆", "伍" , "陆" , "柒" , "捌" , "玖")


divide <- function(num){
  integer <- floor(num)
  fraction <- round((num - integer)*100)
  c(integer, fraction) %>% return()
}


fraction_to_rmb <- function(fraction){
  a <- fraction %/% 10
  b <- fraction %% 10
  if (a^2 + b^2 == 0) {
    return('整')
  } else if (a == 0 & b != 0) {
    return(str_c('零', han_list[b + 1], '分'))
  } else if (a != 0 & b == 0) {
    return(str_c(han_list[a + 1], '角'))
  } else {
    return(str_c(han_list[a + 1], '角', han_list[b + 1], '分'))
  }
}


# 输出整数部分的函数
integer_to_rmb <- function(integer){
  string <- integer %>% as.character()
  n <- str_length(string)
  m <- (n + 7)/8 # 8位一组来操作，拆分成 m 组
  s <- ''
  for (i in 1:m) {
    if (i < m) {
      s[i] <- str_sub(string, -8*i, (7 - 8*i)) %>% 
        eight_to_rmb()
    } else {
      s[i] <- str_sub(string, 1, (7 - 8*m)) %>% 
        eight_to_rmb()
    }
  }
  # 将每组返回的字符串连接起来
  rmb <- ''
  for (i in m:1) {
    rmb <- str_c(rmb, s[i])
  }
  # 用正则表达式处理连续的多个零
  rmb <- rmb %>% str_replace_all('零+','零') %>% # 连续多个零变成一个
    str_replace_all('零万', '万') %>% # 万和亿前的末位零删掉
    str_replace_all('零亿', '亿') %>%
    str_replace('^壹什', '什') %>% # 开头不会读作“壹什”
    str_sub(1, -2) # 去掉个位的“亿”
  return(rmb)
}


## 处理8位数字的函数
eight_to_rmb <- function(string){
  n <- str_length(string)
  if (n == 8) { # 8位满时
    front <- str_sub(string, 1, 4) #前4位
    behind <- str_sub(string, 5, 8) # 后4位
    if (str_sub(string, 1, 8) == '00000000') {
      return('零') # 8位皆0不要“亿”
    } else if (front == '0000') {
      return(str_c('零', four_to_rmb(behind), '亿')) # 4位皆0不要“万”
    } else {
      return(str_c(four_to_rmb(front), '万', four_to_rmb(behind), '亿'))
    }
  } else if (n > 4) { # 不足8位（数字最前的若干位）
    front <- str_sub(string, 1, n - 4)
    behind <- str_sub(string, n - 3, n)
    return(str_c(four_to_rmb(front), '万', four_to_rmb(behind), '亿'))
  } else {# 不足4位
    return(str_c(four_to_rmb(string), '亿'))
  }
}


## 处理4位数字的函数
four_to_rmb <- function(string){
  n <- str_length(string)
  s <- ''
  for (i in 1:n) {
    s[i] <-  str_sub(string, i, i)
  }
  dt <- tibble(seq = n:1, num = s) %>% setDT()
  dt[, han_character := han_list[num %>% as.integer() + 1]] # 中文大写
  dt[, magnitude := ''] # 单位
  dt[seq == 2, magnitude := '什']
  dt[seq == 3, magnitude := '佰']
  dt[seq == 4, magnitude := '仟']
  dt[num == '0', magnitude := ''] # 数字为0时，十百千单位要去掉
  # 组合数字与单位
  dt[, rmb := str_c(han_character, magnitude)]
  return(dt$rmb %>% str_c(collapse = ''))
}


## 主体函数
main <- function(float_money){
  # 首先将金额分为整数部分和小数部分
  integer <- divide(float_money)[1]
  fraction <- divide(float_money)[2]
  # 用两个函数分别处理整数分布和小数部分
  rmb <- str_c(integer_to_rmb(integer), 
               '圆', 
               fraction_to_rmb(fraction))
  return(rmb)
}
'''+'main({})'.format(float_money)

## 获取输出
money_zh = robjects.r(r_script)
print(type(money_zh), ':', money_zh)


# 执行 R 脚本
robjects.r.source('.\\demo.r')
x = robjects.r('x') #获取脚本里的全局变量
y = robjects.r('y')
print(x) 
print(y) 

# Python 与 R 的对象转换

## Python 对象转换为 R 对象
'''
以下函数将 python 的数据结构转换为 R 的相应数据结构
robjects.StrVector() # 字符串向量
robjects.IntVector() # 整数向量
robjects.FloatVector() # 浮点数向量
robjects.complexVector() # 复数向量
robjects.FactorVector() # 因子向量
robjects.BoolVector() # 布尔向量
robjects.ListVector() # 列表型
'''

print(robjects.FactorVector(['a','a','b','c'])) # 字符串向量
print(robjects.FloatVector([1.2, 2.3])) # 浮点数向量
print(robjects.DataFrame({'a':[1,2],'b':[3,4]})) # 数据框
df = robjects.DataFrame({'a':[1,2],'b':[3,4]})



testmatrix = robjects.IntVector([1, 2, 3, 4]) # 整型向量
print(robjects.r['matrix'](testmatrix, nrow = 2))
a = robjects.r['matrix'](robjects.r('1:10'), nrow = 2)
print(a)
# Python 中没有 1:10 这样的写法，range(10)是一个供遍历的对象
# 所以要生成连续向量时，用 R 的语法更简便。


## R 对象转换为 Python 对象
a = robjects.r('c(1, 2, 3)')
print(a)
print(str(a), type(str(a)), len(str(a))) 
print(tuple(a), type(tuple(a)))
print(list(a), type(list(a)))

b = robjects.r('matrix(1:6, 2, 3)')
print(b)
print(tuple(b))
print(list(b))
