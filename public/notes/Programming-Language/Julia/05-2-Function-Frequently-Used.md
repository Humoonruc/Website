[TOC]

# 常用函数

## Language

`methodswith()` 查看能接收某种数据结构作为参数的所有方法

## 数值与类型判断

#### `isequal(x, y)`

  `x` 和 `y` 的**值与类型**是否完全相同（正0和负0被认为是不同的）

## Math

### 数学常量

`π`

`ℯ` **\euler TAB**

`im` 虚数单位 $i$

### 算数函数

| 函数             | 描述                                                |
| :--------------- | :-------------------------------------------------- |
| `sqrt(x)`, `√x`  | `x` 的平方根                                        |
| `cbrt(x)`, `∛x`  | `x` 的立方根                                        |
| `hypot(x,y)`     | 当直角边的长度为 `x` 和 `y`时，直角三角形斜边的长度 |
| `exp(x)`         | 自然指数函数在 `x` 处的值                           |
| `expm1(x)`       | 当 `x` 接近 0 时的 `exp(x)-1` 的精确值              |
| `ldexp(x,n)`     | `x*2^n` 的高效算法，`n` 为整数                      |
| `log(x)`         | `x` 的自然对数                                      |
| `log(b,x)`       | 以 `b` 为底 `x` 的对数                              |
| `log2(x)`        | 以 2 为底 `x` 的对数                                |
| `log10(x)`       | 以 10 为底 `x` 的对数                               |
| `log1p(x)`       | 当 `x`接近 0 时的 `log(1+x)` 的精确值               |
| `exponent(x)`    | `x` 的二进制指数                                    |
| `significand(x)` | 浮点数 `x` 的二进制有效数（也就是尾数）             |



| 函数            | 描述                                             |
| :-------------- | :----------------------------------------------- |
| `abs(x)`        | `x` 的模                                         |
| `abs2(x)`       | `x` 的模的平方                                   |
| `sign(x)`       | 表示 `x` 的符号，返回 -1，0，或 +1               |
| `signbit(x)`    | 表示符号位是 true 或 false                       |
| `copysign(x,y)` | 返回一个数，其值等于 `x` 的模，符号与 `y` 一致   |
| `flipsign(x,y)` | 返回一个数，其值等于 `x` 的模，符号与 `x*y` 一致 |



| 函数                                              | 描述                                                         |
| :------------------------------------------------ | :----------------------------------------------------------- |
| `div(x,y, r::RoundingMode=RoundToZero)`, `x÷y`    | 截断除法，无论任何类型相除的结果都会省略小数部分，剩下整数部分（向 0 靠近） |
| `fld(x,y)`，等价于 `floor(Int, x/y)`              | 向下取整除法（向 -Inf 靠近）<br />当 x 与 y 一正一负且不能整除时，`floor()` 与 `div()` 的结果不同 |
| `cld(x,y)`，等价于 `ceil(Int, x/y)`               | 向上取整除法                                                 |
| `rem(x,y, r::RoundingMode=RoundToZero)`，` x % y` | 取余，与 `div()` 配对；满足 `x == div(x,y)*y + rem(x,y)`；符号与 `x` 一致 |
| `mod(x,y)`                                        | 取模，与 `fld()` 配对；满足 `x == fld(x,y)*y + mod(x,y)`；符号与 `y` 一致<br />当 x 与 y 一正一负且不能整除时，取余与取模的结果不同 |
| `mod1(x,y)`                                       | 偏移 1 的 `mod`；若 `y>0`，则返回 `r∈(0,y]`，若 `y<0`，则 `r∈[y,0)` 且满足 `mod(r, y) == mod(x, y)` |
| `mod2pi(x)`                                       | 对 2pi 取模；`0 <= mod2pi(x) < 2pi`                          |
| **`divrem(x,y)`**                                 | 返回 `(div(x,y),rem(x,y))`，很高效                           |
| `fldmod(x,y)`                                     | 返回 `(fld(x,y),mod(x,y))`                                   |
| `gcd(x,y...)`                                     | `x`, `y`,... 的**最大公约数**                                |
| `lcm(x,y...)`                                     | `x`, `y`,... 的**最小公倍数**                                |

### 三角函数

接收弧度值

### 舍入函数

| 函数          | 描述                   | 返回类型                                                     |
| :------------ | :--------------------- | :----------------------------------------------------------- |
| `round(x)`    | `x` 舍到最接近的整数   | `typeof(x)`，由于 x 经常是浮点数，所以返回也是浮点数，如 `2.0`<br />下同 |
| `round(T, x)` | `x` 舍到最接近的整数   | `T`，代码虽然多了一点点，但确保了返回值的类型（一般为 Int），有助于良好的性能<br />下同 |
| `floor(x)`    | `x` 向 `-Inf` 舍入     | `typeof(x)`                                                  |
| `floor(T, x)` | `x` 向 `-Inf` 舍入     | `T`                                                          |
| `ceil(x)`     | `x` 向 `+Inf` 方向取整 | `typeof(x)`                                                  |
| `ceil(T, x)`  | `x` 向 `+Inf` 方向取整 | `T`                                                          |
| `trunc(x)`    | `x` 向 0 取整          | `typeof(x)`                                                  |
| `trunc(T, x)` | `x` 向 0 取整          | `T`                                                          |

#### `clamp(x, lo, hi)`

Return `x` if `lo <= x <= hi`. If `x > hi`, return `hi`. If `x < lo`, return `lo`. 





## Iterator

#### `digits()`

`digits([T<:Integer], n::Integer; base::T = 10, pad::Integer = 1)`

接收一个数，返回其各位数字组成的 Vector，但排序方式是低位在前，高位在右

#### `max()`/`min()` and `maximum()/minimum()`

前一组接收用逗号隔开的若干个数，后一组接收数的 iterator

`maximum([f, ]itr)`

#### `extrema(itr)`

返回 tuple `(minimum(), maximum())`，很高效

需要解构赋值，如 `lowest, highest = extrema(numbers)`

#### `unique()/allunique()`

`unique([f, ]itr)` 返回 `f(x)` 不重复的元素，构成 array

`allunique(itr)->Bool` itr 中的元素是否没有重复的（distinct）

#### `all([f, ]itr)`

注意参数要封装为 itr，不能是逗号间隔的若干变量直接传入 `all()`——这一点与很多语言不同

#### `isempty()`

判断数组是否为空，即长度是否为0，等价于 `length(arr)==0`

#### `indentity()`

返回参数。这个函数一般与一些必须接收函数参数的泛函搭配使用

#### `first()`/`last()`

- `first(itr, n::Integer)`，itr 的前 n 个元素

- `last(itr, n::Integer)`，itr 的前 n 个元素

## 统计

#### `rand()`/`randn()`

`rand([rng=GLOBAL_RNG], [S], [dims...])` 从范围 S 的**均匀分布**中选一个随机数，S 默认为 Float64 的 [0, 1). 如果只有一个整数参数，会将其作为 dims

```julia
julia> rand(3)
3-element Vector{Float64}:
 0.819711826945006
 0.5348092806182642
 0.21127109286422108

julia> rand(1.0:10.0)
4.0

julia> rand(2:2:20, 3)
3-element Vector{Int64}:
  2
 18
  2

julia> rand((42, "Julia", 3.14))
"Julia"

julia> rand(Dict(:one => 1, :two => 2))
:two => 2

julia> rand(1.0:3.0, (2, 2))
2×2 Matrix{Float64}:
 1.0  3.0
 3.0  1.0
```



`randn()` 为**正态分布**随机数

`seed!(k)`设定随机数

> 必须先导入 `using Random:seed!`
>
> [Random Numbers · The Julia Language](https://docs.julialang.org/en/v1/stdlib/Random/)

```julia
my_seed = seed!(123)
rand(my_seed, 3)
```

#### `count()`

对一个迭代器中满足条件的元素计数

`count([f=identity,] itr; init=0) -> Integer`

计算 `itr` 中函数 `f` 返回 `true` 的元素数量。如果 `f` 被省略，则计算 `itr` 中的 `true` 元素的数量（应该是布尔值的集合）。 `init` 可选地指定开始计数的值，因此也确定输出类型。

#### `DataStructures.counter()` 频数统计

接收 dict, sequence, generator 等，返回一个 Accumulator 对象，可以像 Dict 一样访问

#### `sum()`

`sum([f,] itr; [init])`

#### `cumsum()`/`cumprod()`

#### `mean()`/`median()`/`var()`/`std()`

都返回 Float

> `using Statistics`

`mean([f, ]itr)::Float`

`median(itr)::Float` 