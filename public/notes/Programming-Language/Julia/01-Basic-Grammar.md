

[TOC]

# Basic Grammar

## Variable

### `const` 关键字

声明为常量，不允许重新赋值

一般用于一些全局变量，对程序性能有利

### 变量名

自定义的 Type 和 Module 首字母大写，驼峰式

变量和函数首字母小写，蛇形

会就地修改参数的函数名后加 `!`



可以用希腊字母、中文等字符为变量命名，这非常 cool 😎

特别是，还接受上标和下标！！！

```julia
aₙ = 3 # a\_n+[TAB]
bᵞ = 5 # b\^gamma+[TAB]
```



### 变量赋值

Julia 支持解构赋值，一次性赋值多个变量

```julia
x, y, z = 1, [1:10; ], "A string"
```



## Expression & Statement

Julia 的表达式都有返回值

特别是赋值表达式，可以直接作为 return 的对象

`;`可以阻止一行代码在 REPL 中的输出，也可以将两行代码组合在一行内

## Blocks

### do 块

### let 块



## Operator

### 分类

二元 operator 本质上都是二元函数

#### 算数

| operator           |                                                              |
| ------------------ | ------------------------------------------------------------ |
| `+`                |                                                              |
| `-`                |                                                              |
| `*`                | 乘法，**数乘时可以省略`*`，连写数字与变量**，如`4x`；字符串的串联 |
| `/`                | **返回 float**                                               |
| `\`                | 反向除法                                                     |
| `÷` (`\div+[TAB]`) | 取整除法（向 0 靠近），**返回 int**                          |
| `^`                | 幂；字符串的复制                                             |
| `%`                | 取余。`x % y`等价于`rem(x, y)`                               |

#### 线性代数

- `⋅` (`\cdot<TAB>`) 点积运算符
  - `using LinearAlgebra`

- `⊗` (`\otimes<TAB>`) 克罗内克积运算符
  - `using Kronecker`



#### 赋值

**解构赋值**：左边为元组（可以省略括号），右边为任何类型的序列（string, vector, tuple, …）

交换赋值 `a, b = b, a`

#### 位

#### Logical

- `&&` 与
- `||` 或
- `!` 非

#### Relational

前面加`.`就是**关系运算符的向量版本**，可以分别比较数组中每个元素

##### 大小

`==` 适用于整数

`≈`(`\approx<TAB>`)适用于浮点数，等价于函数 `isapprox(a, b[;atol, rtol])`. 其中 `atol`参数为两数差的绝对 tolerance，`rtol` 为相对 tolerance. 返回 `b-a < max(atol, rtol * max(a, b)) `

```{julia}
isapprox(10, 10.01, atol=0.009) # false
isapprox(10, 10.01, atol=0.01) # true
isapprox(10, 10.01, rtol=0.0009) # false
isapprox(10, 10.01, rtol=0.001) #true
```



`!=`或`≠` (**\ne TAB**)

`>=`或`≥` (**\ge+[TAB]**)

`<=`或`≤` (`\le+[TAB]`)


大小运算符的链式比较

```julia
1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5 # true
```

链式比较可以避免条件嵌套

例：以下两种写法都比较繁冗

```julia
if 0 < x
    if x < 10
        println("x is a positive single-digit number.")
    end
end

if 0 < x && x < 10
    println("x is a positive single-digit number.")
end
```

可以改写为：

```julia
if 0 < x < 10
    println("x is a positive single-digit number.")
end
```

比较数组大小的规则为：从第一个元素开始比较，如果相等再比较第二个元素，依次类推

##### 种属

`isa`

##### 包含

`in` `∈` `∉`

##### 集合关系

两端的变量都应该是 Set

`⊆` (**\subseteq TAB**) 

`∩` (**\cap TAB**)

##### 是否同一

指向同一个对象（内存地址）

`≡` (**\equiv TAB**) 或 `===`

相等不一定同一，同一一定相等

```julia
a = "banana" 
b = "banana"
a ≡ b # true，内存中只有一个 banana

c = [1, 2, 3]
d = [1, 2, 3]
c ≡ d # false，内存中有两个 Vector

e = [1, 2, 3]
f = e
e ≡ f # true
```

不可变对象，有别名时不会发生变量拷贝；可变对象，有别名时会有数据拷贝。


特别地，对于 mutable struct，`==` 操作符的默认行为与 `≡`/`===` 一样，因为它不会判断组合类型如何才算相等，只能判断同一。

#### iterator 展开符号

`iterator...` 展开为逗号间隔的参数 args…，再传给其他函数

#### Type Annotation

类型标记 `::`

```julia
function returnfloat()
    x::Float64 = 100 # 在赋值表达式左边使用`::`，不能用于全局变量
    x
end

returnfloat()
```

子类标记 `<:`

表示前者是后者的子类型

判断类型 `isa` 

前者（一个 instance）是否属于后者的实例

### Operator Precedence

小括号 > 幂 > 乘除 > 加减

### Operators Overloading

```julia
import Base.+

function +(p1::Point, p2::Point)
   Point(p1.x + p2.x, p1.y + p2.y) 
end
```

```julia
import Base.<

function <(c1::Card, c2::Card)
    (c1.suit, c1.rank) < (c2.suit, c2.rank)
end
```


## Comment

单行 `#`

多行 `#= ... =#`
