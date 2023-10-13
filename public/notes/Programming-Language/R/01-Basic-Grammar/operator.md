[TOC]

## Operator

[R 基础运算 | 菜鸟教程 (runoob.com)](https://www.runoob.com/r/r-basic-operators.html)

### 赋值运算符

`<-` 不能修改作用域以外的变量，赋值**有返回值**

`<<-` **可以修改作用域以外的变量**，赋值**有返回值**

`=`，赋值没有返回值

### 数学运算符

`+`

`-`

`*`

`/`

`^`/`**` 乘方

`%/%` 整除

`%%` 取余，可以小数对小数取余，如 `5.4 %% 2.3`的结果为 0.8

### 关系运算符

- `>` `<` `>=` `<=` `==` `!=`

判断值的关系，自动将两边数据转换为同样的数据类型。如比较`1`和`1L`，前者为 double，后者为 integer，自动都转换为 double 再比较

```R
1==1L # TRUE
```

- `identical(x, y)`

判断是否严格相等（除了数值，数据类型也要一样）

```R
identical(1, 1L) # FALSE
```

- `all.equal(a, b)` 或 `dplyr::near(a, b)` 判断两个浮点数[^比较浮点数]是否相等。`all.equal()`的容忍误差 (tolerence) 为 1.5e-8

[^比较浮点数]: 电脑运算浮点数有误差，如 `sqrt(2)^2==2` 返回 `FALSE`，所以比较浮点数是否相等不能使用 `==`

```R
sin(pi) == 0 # FALSE
all.equal(sin(pi), 0) # TRUE

sqrt(2)^2 == 2 
## [1] FALSE

identical(sqrt(2)^2, 2)
## [1] FALSE

all.equal(sqrt(2)^2, 2)
## [1] TRUE

dplyr::near(sqrt(2)^2, 2)
## [1] TRUE
```



### 逻辑运算符

- `&` / `magrittr::and()` 向量化与

- `|` / `magrittr::or()` 向量化或

- `!` / `magrittr::not()` 向量化非

- `xor(x, y)` 向量化异或。若x、y均为T或F，返回F；若x、y一为F一为T，返回T

- `&&` 单值与

短路运算，只要前一个表达式为 FALSE，后面的表达式就不会再计算，直接返回 FALSE

```R
# 替代 if 表达式：
num < 0 && return(FALSE) # 只有 num<0 时才会返回，否则 do nothing
```

- `||` 单值或

短路运算，只要前一个表达式为 TRUE，后面的表达式就不会再计算，直接返回 TRUE

### 包含运算符

`%in%`/ `magrittr::is_in()`

该运算符是向量化的，会检查 x 向量中**每个**元素是否包含于 y，返回一个**与 x 长度相同**的逻辑向量。

当 x 中某元素在 y 中时，返回 T；不在 y 中时，返回 F
