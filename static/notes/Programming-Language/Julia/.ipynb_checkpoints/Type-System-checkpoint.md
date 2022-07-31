[TOC]

# Type System

类型系统是 Julia 的精华

## 类型系统

### 类型的分类

- abstract type，定义行为
- concrete type，定义数据的存储方式
  - 原始类型
  - 复合类型

### 类型申明

`::`类型申明，有两大作用：

#### 检查表达式输出结果

1. 写在表达式最后
2. 不能检查赋值语句中`=`左边的全局变量（函数内没问题）

```julia
s = 'a'::String # 注意，String 检查的是 = 后面整个表达式的类型
```

报错，表明输出不是预想的 String

```julia
s = 'a'::Char
```

```julia
b = Int64(3.0::Float64) # 检查 3.0
```

```julia
b = convert(Int, 3.0)::Int64 # 检查 convert(Int, 3.0)
```

#### 提升程序性能

使用中，对类型的规范越细致，程序运行速度越快

```julia
function foo()
  x::Int8 = 1.0
  x
end
```

```julia
foo() # 自动将类型转换为了 Int8
```

### 查看类型

`typeof()`

`eltype()` 数组中元素的类型

`typemin()`/`typemax()`查看类型能够表达的最小/大值

`supertype()`/`supertypes()`/`subtypes()`查看类型之间的关系

`subtypetree()` 自定义函数，已在 startup.jl 中加载，查看树状子类型关系图

### `is..()` 判断类型

返回 `Bool`

`isodd()`/`iseven()` 判断奇偶数

`isinteger()` 判断是否为整数

`isfinite()`/`isinf()` 判断是否为无穷值

`isnan(x)` `x` 是否是 `NaN`

`isdigit(char)` 判断一个字符是否在 `'0':'9'` 的范围内

### Type Conversion

#### `convert(T, x)`/ `T()`

`Int64()`, `Float64()`, `UInt8()`, `BigInt()`, etc

```julia
convert(Float64, 1) 
```

```julia
float(3)
```

#### `parse(T, string; base)`

将一个 base 进制的字符串解析为 10 进制数字

#### `trunc([T,] x)`

`trunc([T,] x)` 截取整数部分（不论小数部分多大）
`trunc(x; digits::Integer= [, base = 10])`
`trunc(x; sigdigits::Integer= [, base = 10])`

#### `string()`

转换为字符串

#### `big()`

将数据类型升格为更大的类型，Int 变 BigInt，Float 变 BigFloat

### Type Unions

比如一个函数的输入可以是整数或字符串，如何进行类型申明？就要构造 type union

`Union{Types...}` 任何对象都不是它的实例

```julia
IntOrString = Union{Int64, String}
```
```julia
input_value = Union{Missing, Int64}
```

### Type Promotion

```julia
promote(1, 2.5, 1//2)
```

### 类型与性能

尽量保持变量类型的稳定，比如一个整数如果参与除法，就尽量在定义这个变量时将其声明为浮点型

```julia
x = 1.0
```
## Abstract Type



- 抽象类无法被实例化
  - 比如正多边形是正三角形和正方形的父类。后两者是具体类，有相应的数据储存格式，而前者只是一个用来说明后两者有某些共同行为的抽象类，在内存中没有具体实现，仅作为一种标记行为的工具。

  - 在处理抽象类型时，可以只关注特定的行为以及它们之间可能的交互。

  - 这就是传说中的鸭子类型，不管它里面放着什么数据，只要行为像鸭子，它就是鸭子。即根据行为而非计算机实现来标注类型。

- 具体类之间不能互为子类型（必然是类型层次结构中的叶子节点），只有抽象类可以作为其他类型的超类

- 抽象类一般用*斜体*表示

`Any` 是顶级类型，所有类都是它的子类





## Built-in Types

也被称为原始类型，相对于复合类型

### Number

#### Integer

##### 整数取值范围的上限

| 类型                                                         | 带符号？ | 比特数 | 最小值    | 最大值    |
| :----------------------------------------------------------- | :------- | :----- | :-------- | :-------- |
| [Int8](https://docs.julialang.org/en/v1/base/numbers/#Core.Int8) | ✓        | 8      | -2^7      | 2^7 – 1   |
| [UInt8](https://docs.julialang.org/en/v1/base/numbers/#Core.UInt8) |          | 8      | 0         | 2^8 – 1   |
| [Int16](https://docs.julialang.org/en/v1/base/numbers/#Core.Int16) | ✓        | 16     | -2^15     | 2^15 – 1  |
| [UInt16](https://docs.julialang.org/en/v1/base/numbers/#Core.UInt16) |          | 16     | 0         | 2^16 – 1  |
| [Int32](https://docs.julialang.org/en/v1/base/numbers/#Core.Int32) | ✓        | 32     | -2^31     | 2^31 – 1  |
| [UInt32](https://docs.julialang.org/en/v1/base/numbers/#Core.UInt32) |          | 32     | 0         | 2^32 – 1  |
| [Int64](https://docs.julialang.org/en/v1/base/numbers/#Core.Int64) | ✓        | 64     | -2^63     | 2^63 – 1  |
| [UInt64](https://docs.julialang.org/en/v1/base/numbers/#Core.UInt64) |          | 64     | 0         | 2^64 – 1  |
| [Int128](https://docs.julialang.org/en/v1/base/numbers/#Core.Int128) | ✓        | 128    | -2^127    | 2^127 – 1 |
| [UInt128](https://docs.julialang.org/en/v1/base/numbers/#Core.UInt128) |          | 128    | 0         | 2^128 – 1 |
| [Bool](https://docs.julialang.org/en/v1/base/numbers/#Core.Bool) | N/A      | 8      | false (0) | true (1)  |

整数类型值域的上限不足，是 Julia 一个非常突出的特点。这是为了速度优化而对数据进行严格分类的一种牺牲。

注意，integer 类型的取值范围是比较小的，因此如果程序中某个表达式需要处理的数值大小超过 $2^{64}$ 乃至 $2^{128}$，就会溢出。必须将数据转换为 Float 再计算。

转换的方法很灵活，运算过程中任何一个数是浮点数，结果都会是浮点数。

```julia
typemax(Int64) # 2^63 - 1
# 9223372036854775807
```

```julia
typemax(Float64)
# Inf
```

```julia
1000^21
# -9223372036854775808
```

```julia
Float64(1000)^21
# 1.0e63
```

```julia
(1000+0.0)^21
# 1.0e63
```

上述计算结果（大于 $2^{64}$ 乃至 $2^{128}$ 的浮点数）仍然可以被转换为整数，但必须用 `BigInt` 格式来储存。

转换函数为 `big()` 或 `BigInt()`，或使用 `convert(BigInt, x)`

```julia
x = BigInt(10212313131352519345963644753026192783913791739137917391739137)
```

```julia
convert(BigInt, Float64(1000)^21)
```


##### 进位制

前缀区分进制：

\- `0x` 十六进制

\- `0b` 二进制

\- `0o` 八进制



10 进制（数字）与其他进制（字符串）的互转

- `parse(type, str; base)` 将 base 进制的字符串解析为 10 进制整数
- `string(n; base, pad)` 将 10 进制整数转换为 base 进制的字符串，并补齐至 pad 长度
- 忽略 base 时，则是 10 进制数字与字符串的互转

```julia
parse(Int64, "FF"; base=16)
```

```julia
string(12; base=16, pad=2)
```

#### Floating-point

用科学计数法输入数字时，默认为浮点数（可能因为整数的值域太小了）

```julia
2e2
```

在计算机能够表达的浮点数集合中，越靠近零点，数值的分布越稠密；而远离零点时，则会变得越来越稀疏，精度也会越来越差。

##### NaN

not a number, 用 `isnan()` 检查是否 NaN

```julia
0/0 # NaN
```

```julia
typeof(NaN) # Float64
```

##### 无穷大

Julia 允许除数为 0，返回 Inf 或 -Inf，用 `isfinite()`, `isinf()` 检查是否无穷大

> 但不允许分子分母同时为0

```julia
isfinite(Inf) # false
```
```julia
isinf(-Inf) # true
```

#### 复数

```julia
1+im  |> typeof # Complex{Int64}
```

#### 有理数

`Rational{T<:Integer>}<:Real` 分子、分母必须都是整数

`numerator()`, `denominator()` 分别返回标准化的分子和分母

```julia
1 // 2 # 分数
```

```julia
typeof(1 // 2)
```

```julia
numerator(1//2)
```

```julia
denominator(1//2)
```

数学上等价的有理数，在 Julia 中表达形式唯一

- 分子与分母为不同整型时，Julia会通过必要的隐式转换，将两者的类型进行统一
- 创建的Rational数值在Julia内部会被约分为标准形式
- 确保分母不为负数
- 不允许分子、分母同时为 0
- 在 julia 底层，比较两个分数值是否相等时，是通过**校验分子与分母都相等**来实现的

```julia
UInt32(2)//Int64(10) # 统一为 Int64
```

```julia
typeof(UInt32(2) // Int64(10))
```

```julia
5//25
```

```julia
1//-2
```

```julia
5//0
```

```julia
0//0
```

```julia
2//3 == 6//9
```

```julia
5//8 * 3//12
```

```julia
6//5 / 10//7
```

#### 无理数

julia 有一些内置常数，如 ℯ (**\euler TAB**)

```julia
typeof(ℯ)
```

### Nothing

没有返回值的函数，返回 `nothing`，其 type 为 `Nothing`

### Missing

```julia
typeof(missing) # Missing
```

在包含 missing 的数组上调用归约函数会返回 missing，需要先用 `skipmissing()` 跳过缺失值

```julia
a = [1, missing]
```
```julia
typeof(a)
```

```julia
sum(a)
```

```julia
skipmissing(a)
```

```julia
skipmissing(a) |> sum
```

### Bool

true/false 参与数值计算会自动转化为 1/0

```julia
true == 1
```

```julia
false == 0
```

```julia
true == 2
```

```julia
Int64(true) # 1
```

```julia
Int64(false) # 0
```

```julia
Bool(1::Int64) # true
```

```julia
Bool(0) # false
```

```julia
Bool(10) # 非 1 和 0 的数值转换为 Bool 型会报错！这是 Julia 的一个特点
```

### Symbol

以`:`开始，可以和 String 相互转换

```julia
sym = :some_text
```

```julia
typeof(sym)
```

```julia
s = string(sym)
```

```julia
sym = Symbol(s)
```

但 Symbol 不能像 String 一样使用数字索引

### Char

#### 构造

字符的类型为 `Char`，父类型为 `AbstractChar`，形式为一对单引号 `'x'`，且其中只能有一个字符

```julia
typeof('x')
```

```julia
'x'
```

```julia
# 除了提示该字符的 Unicode 码值（16进制）外，还告知其在字符集中的分类
'￥'
```

也可以用 `Char(数字)` 创建字符

```julia
Char(0x78)
```

```julia
Char(120) # 10进制的120，对应16进制的78
```

```julia
Int('x')
```

#### 运算

字符之间的四则运算仅支持减法，返回二者编码之间的距离

```julia
'x' - 'a'
```

```julia
'x' - 23
```

```julia
'A' + 1
```

#### 判断分类

`isletter(c::AbstractChar)` 是否在 letter 类中

`isascii(c::Union(AbstractChar, AbstractString))` Char 是否在 ASCII 中，或 String 的所有字符是否都在 ASCII 中

`isnumber(c::AbstractChar)` 是否在 numeric 类中

`isdigit(c::AbstractChar)` 是否为 0-9 的数字

`isprint(c::AbstractChar)` 是否为可打印字符

`iscntrl(c::AbstractChar)` 是否为不可打印字符（如换行符、制表符）

`ispunct(c::AbstractChar)` 是否为标点符号

`isspace(c::AbstractChar)` 是否为白空格

`islowercase(c::AbstractChar)` 是否为小写字符

`isuppercase(c::AbstractChar)` 是否为大写字符

## 复合类型

不可变对象的字段如果是可变的（如数组），这个字段就仍然能被改写。

可变对象的所有字段都能被改写。

不可变对象更易于处理，但空间开销更大。

### 参数化复合类型

复合类型接收一些参数，这些参数对字段的类型进行了某种规定，并在实例化时具体确定。

```julia
abstract type Asset end
abstract type Investment <: Asset end
abstract type Equity <: Investment end

struct Stock <: Equity
    symbol::String
    name::String
end

# 参数类型
struct StockHolding{T <: Real} 
    stock::Stock
    quantity::T
end
```

实例化时，有可能出现 StockHolding{Int}，也有可能出现 StockHolding{Float}

```julia
stock = Stock("AAPL", "Apple, Inc.")
```
```julia
holding = StockHolding(stock, 100)
```

```julia
holding = StockHolding(stock, 100.00)
```

```julia
holding = StockHolding(stock, 100 // 3)
```

强制约定字段类型的一致性
```julia
struct StockHolding2{T<:Real,P<:AbstractFloat}
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end
```

```julia
holding = StockHolding2(stock, 100, 180.00, 18000.00)
```

```julia
abstract type Holding{P} end

mutable struct StockHolding3{T,P} <: Holding{P}
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end

mutable struct CashHolding{P} <: Holding{P}
    currency::String
    amount::P
    marketvalue::P
end
```

```julia
certificate_in_the_safe = StockHolding3(stock, 100, 180.00, 18000.00)
```

```julia
certificate_in_the_safe isa Holding{Float64}
```

```julia

```
