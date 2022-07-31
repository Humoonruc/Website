[TOC]

# 函数

## 函数结构

### 定义

#### 完整形式

```julia
function foo(x)
	return x^2
end
```

#### 仿数学形式

```julia
foo(x) = x^2
```

这种形式与数学中函数的写法几乎一模一样

#### 匿名函数

1. 单行

```julia
a -> a^2
```

2. 多行，需要复合表达式（`begin...end`或`()`包起来）或 `do` 块
   1. `begin...end`的多行语句不需要末尾加 `;`
   2. `()` 是 `;` 链的多行形式，必须用 `;` 分隔各行
   3. `do`块封装一个匿名函数，作为前面函数的第一个参数


```julia
using Statistics

const discard_outliers = (X, threshold) -> (
    n = length(X);
    X̄ = mean(X);
    SST = sum((X .- X̄) .^ 2);
    σ = √(SST / (n - 1));
    @show σ std(X);
    X[X.-X̄.<threshold*σ]
)

discard_outliers([1:100..., 10000], 3)
```

`open(f, args...)`

```julia
open("myfile.txt", "w") do io
    write(io, "Hello world!")
end;
```

​         



表示比较的匿名函数的简写形式：

`x -> x == a` 可以简写为 `==(a)`， `>`、`<`、`∈`同理

> `==(a)` 是一元函数 `x -> ==(x, a)` 的语法糖，这种写法可以匹配管道
>
> ```julia
> words .|> rearrange .|> ==("aabb")
> ```



匿名函数**可以修改外部变量**



匿名函数改变代码风格

```julia
const foo = x -> (
    t = √(x + 2);
    return t^x
)
# 这样写函数定义有 js 那味儿了：end 关键字可以滚了


1:10000 |> X ->
    (
        n = length(X);
        X̄ = mean(X);
        SST = sum((X .- X̄) .^ 2);
        σ = √(SST / (n - 1));
        @show σ std(X);
        X[@. abs(X - X̄) < 1σ]
    ) .|>
    (x -> x^(1 // 4)) .|>
    log |>
    sum
# 这样写管道有 R 那味儿了，再复杂的逻辑都给你串联无数行直到天荒地老
```

### 返回值

#### 多个返回值

在同一行内用逗号分隔，默认返回元组，即 `return a, b` 等价于 `return (a, b)`

```julia
function add_multiply(x, y)
	addition = x + y
	multiplication = x ∗ y
	return addition, multiplication
end

# 可以解构赋值
return_1, return_2 = add_multiply(1, 2)

# 也可以用一个 tuple 接收
all_returns = add_multiply(1, 2)
typeof(all_returns) # Tuple{Int64, Int64}
```

#### 返回值的类型

用 `::` 指定。

```julia
julia> function g(x, y)::Int8
           return x * y
       end;

julia> typeof(g(1, 2))
Int8
```



### 参数

#### 默认参数



#### 关键字参数

有时候参数太多记不住顺序，用关键词参数就不怕顺序错了。

位于常规参数之后，用`;`隔开，可以有默认值

调用时若不使用其默认值，则必须给出参数名，即 `key = value` 形式

```julia
julia> function f5(x; y=2)
           return x + y, x - y
       end
f5 (generic function with 1 method)

julia> f5(2)
(4, 0)

julia> f5(2, y=4)
(6, -2)

julia> f5(2, 4)
ERROR: MethodError: no method matching f5(::Int64, ::Int64)
Closest candidates are:
  f5(::Any; y) at REPL[1]:1
Stacktrace:
 [1] top-level scope
   @ REPL[4]:1
```

#### 设置参数类型

`参数名::类型名`，其中类型也可以是抽象类型，以适应更广的需要

```julia
function f6(x::Int64, y::Int64)
  return x + y, x - y
end
```



```julia
julia> f6(1, 2)
(3, -1)

julia> f6(1.2, 2)
ERROR: MethodError: no method matching f6(::Float64, ::Int64)
Closest candidates are:
  f6(::Int64, ::Int64) at REPL[4]:1
Stacktrace:
 [1] top-level scope
   @ REPL[6]:1
```

#### 可以修改参数的函数

函数末尾加`!`，警告用户这个函数具有副作用

#### 不定长参数

用最后一个参数后面加三个点 `args...` 表示，可以将 iterator 展开

调用时，`args...`接收一个 iterator（通常是向量，元组或 Range）并将其转化为逗号分隔的参数序列

```julia
julia> my_collection = [1, 2, 3]
3-element Vector{Int64}:
 1
 2
 3

julia> +(my_collection...) # 相当于下面的形式
6

julia> +(my_collection[1], my_collection[2], my_collection[3])
6
```

### Docstrings

文档字符串 docstrings，紧邻类声明、函数定义、宏定义，可以是一行或多行

- 函数原型描述，主要是有哪些普通参数、默认参数、关键字参数，等等。缩进四个空格，会被自动识别为 julia 代码

- 简述与详述

- 参数及类型描述列表

- 示例

  - 用 jldoctest 标注代码块可自动测试
  - 用 julia 标注则没有这个功能

- 公式用双反引号标识，内部要使用 Unicode 字符，形如
  
  ```markdown
  ``α=1``
  ```
  
  
  
  ````julia
  """
     foo(x)     
  
  abstract...
  
  生成的矩阵用于``AΩ=β``
  
  # Arguments
  - `n::Integer`: ...
  - `dim::Integer`: ...
  
  # Examples
  ```jldoctest
  julia> a = [1 2; 3 4] # 模拟输入
  2×2 Matrix{Int64}: # 模拟输出
   1  2
   3  4
  ```
  """
  function foo(x)
    ...
  end
  ````

## 变量作用域

如果全局变量是可变值（数组、字典等），则在函数体内可以直接修改这个变量。

```julia
const known = Dict(0 => 1, 1 => 1) # 声明为 const，不允许直接重新赋值

function example4()
    known[2] = 1
end

example4()

known # known中现在有了三个pair
```



如果全局变量是不可变值（字符串、数字等），要在函数体内对其重新赋值（相当于 R 中的 `<<-`），必须在函数中用 `global` 声明，即告诉编译器，这个变量名指的是那个全局变量，不要创建局部变量

```julia
been_called = false

function example2()
    global been_called
    been_called = true         
end

example2()

been_called
```

## 多态函数和泛型编程

同一段代码，可以处理多种类型和数量的参数

#### 相关概念

- 堕胎函数 polymorphic function
- 泛型编程 generic programming

#### 具体实现

- 多重分派 Multiple Dispatch，一个函数有多个方法，根据参数的数量和类型选择适用哪个方法
	- `method(foo)` 查看函数的所有方法
- 操作符重载 [Operators Overloading](Basic-Grammar.md#Operators%20Overloading)，一个操作符可以作用于多种参数
	- 比如 `sum()`，只要参数（序列）中的元素支持 `+()`，这个函数都适用，抽象程度很高。


## 高阶函数

### 映射 `map()`

`map(f, ...)`

#### 多元函数

`map()` 的第一个参数 f 可以是多元函数，除了 f，其他参数的长度应相等，对应元素参与计算；若长度不等，则在其中任何一个用完时停止。

```julia
julia> map(+, [1, 2, 3], [10, 20, 30, 400, 5000])
3-element Vector{Int64}:
 11
 22
 33
```

#### 字符串

`map()` 作用于字符串、且 f 返回单个字符时，会自动将字符串视为字符向量，对每个字符分别操作，最后返回合并在一起的新字符串

### 过滤器 `filter()`

`filter(f, a)`

返回集合`a`的副本，保留`f`为`true`的元素。函数 `f` 被传递一个参数。

### 归约 `reduce()`

串行连续操作

Julia 的 `reduce()` 只接收运算符，不接收函数，这就比其他语言弱很多。**当需要串行使用函数时，用 for 推导式**

`reduce(op, itr; [init])`，init 是关键字参数

```julia
julia> reduce(*, [2; 3; 4])
24

julia> reduce(*, [2; 3; 4]; init=-1)
-24
```

`foldl()` 保证从 itr 左端依次结合的 reduce

`foldr()` 保证从 itr 右端依次结合的 reduce

`reduce(f, A; dims=:, [init])`， dims 是关键字参数

```julia
julia> a = reshape(Vector(1:16), (4,4))
4×4 Matrix{Int64}:
 1  5   9  13
 2  6  10  14
 3  7  11  15
 4  8  12  16

julia> reduce(max, a, dims=2)
4×1 Matrix{Int64}:
 13
 14
 15
 16

julia> reduce(max, a, dims=1)
1×4 Matrix{Int64}:
 4  8  12  16
```



### `accumulate()`

`accumulate(op, A; dims::Integer, [init])`

返回累计数组



### `mapreduce()`

map 与 reduce 的混合，既有串行也有并行

`mapreduce(f, op, itrs...; [init])`

```julia
julia> mapreduce(x->x^2, +, [1:3;]) # == 1 + 4 + 9
14
```

## 闭包

## 函子 functor

Julia 的对象都像函数名一样可调用，被调用的对象被称为 functor

```julia

"""
多项式 a₀ + a₁x + a₂x² + ... 构造器
- coeff, 从0阶开始的系数向量
"""
struct Polynomial{R}
    coeff::Vector{R}
end


"""
求多项式的值，利用递归关系：
a₀ + a₁x + a₂x² + ... + aₙxⁿ = 
    (...((aₙx + aₙ₋₁)x + aₙ₋₂)x + ... + a₁)x + a₀
"""
function (p::Polynomial)(x)
    val = p.coeff[end]
    for coeff in p.coeff[end-1:-1:1]
        val = val * x + coeff
    end
    val
end


p = Polynomial([1, 10, 100])
# p(x) = 1 + 10x + 100x²

p(3) 
# 931
```





