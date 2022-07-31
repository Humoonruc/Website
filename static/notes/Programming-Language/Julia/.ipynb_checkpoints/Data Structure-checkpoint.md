

[TOC]

# Data Structure

以下数据结构都可以用 `for` 遍历

## Tuple

### Tuple

可以包含多种类型的数据的、不可变的容器，可以用小括号或 `tuple()` 显式定义

创建只有一个元素的 tuple 时，必须在这个元素后面加上逗号

```julia
julia> tuple(1)
(1,)
```

可以用 `[]` 索引访问

```julia
map((x, y, z) -> x^y + z, 2, 3, 1) # 9
```



### Named Tuple

命名元组 NamedTuple，可以用 `.name` 访问

```julia
julia> x = (a=1, b=2)
(a = 1, b = 2)

julia> typeof(x)
NamedTuple{(:a, :b), Tuple{Int64, Int64}}

julia> x
(a = 1, b = 2)

julia> x.a
1

julia> x[1]
1
```

为了减少 named tuple 定义的代码长度，可以在使用已经有 name 的变量时，在参数前加 `;`

```julia
i = 1
f = 3.14
s = "Julia"
my_quick_namedtuple = (; i, f, s) # (i = 1, f = 3.14, s = "Julia")
```





## Range

`1:5`，`UnitRange{Int64}`

`1:2:9`，`StepRange{Int64}`，可由`range(start, end, step, length)`创建

#### 展开 Range为 Vector

1. `collect()`，`collect()`还能将 Tuple、String 等转化为 Vector
2. `Vector()`
3. `[x for x in Range]`

```julia
julia> collect(1:2:9)
5-element Vector{Int64}:
 1
 3
 5
 7
 9

julia> collect("abc") # 注意，collect()将String转化为Char的Vector
3-element Vector{Char}:
 'a': ASCII/Unicode U+0061 (category Ll: Letter, lowercase)
 'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)
 'c': ASCII/Unicode U+0063 (category Ll: Letter, lowercase)
```



## Arrays

数组可以包含不同类型的对象，此时数组的类型为它们的最小公共父类型

```julia
julia> myarray = ["text", 1, :symbol] # 公共父类型为 Any
3-element Vector{Any}:
  "text"
 1
  :symbol
```

Vector{T}，即 Array{T, 1}，默认为纵向（用于构造 Matrix 时）

Matrix{T}，即 Array{T, 2}

### 通用构造函数

#### `Vector()`/`Matrix()`

先创建全为 `undef`（undefined）元素的数组，然后使用 `fill!()` 将想要的元素填充到数组的每一个元素上

```julia
julia> Vector{Int}(undef, 2) # 所得两个数是随机的
2-element Vector{Int64}:
  0
 33

julia> my_matrix_π = Matrix{Float64}(undef, 2, 2) |>
                     m -> fill!(m, 3.14)
2×2 Matrix{Float64}:
 3.14  3.14
 3.14  3.14
```

特别地，`Matrix()` 可以接收一个 DataFrame，从中提取数据部分。

```julia
julia> A = diagm(ones(Int, 3))
3×3 Matrix{Int64}:
 1  0  0
 0  1  0
 0  0  1

julia> name = ["a", "b", "c"]
3-element Vector{String}:
 "a"
 "b"
 "c"

julia> df = DataFrame(A, name)
3×3 DataFrame
 Row │ a      b      c
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      0      0
   2 │     0      1      0
   3 │     0      0      1

julia> Matrix(df)
3×3 Matrix{Int64}:
 1  0  0
 0  1  0
 0  0  1
```



#### 数组字面量 `[]`

- 一维 Vector 元素用逗号分隔
- 二维 Matrix，空格代表行方向上的分隔，分号和换行代表列方向上的分隔
- 数据类型写在 `[]` 之前

```julia
julia> Bool[0, 1, 0, 1]
4-element Vector{Bool}:
 0
 1
 0
 1

julia> [1, 2, 3, [4, 5]]
4-element Vector{Any}:
 1
 2
 3
  [4, 5]

julia> [[1, 2], [3, 4]] # 并非矩阵，而是Vector的Vector
2-element Vector{Vector{Int64}}:
 [1, 2]
 [3, 4]

julia> [[1 2]
         [3 4]]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> Float64[[1 2]
         [3 4]]
2×2 Matrix{Float64}:
 1.0  2.0
 3.0  4.0

julia> [1;2;3] # 只有一列时，Matrix 退化为 Vector
3-element Vector{Int64}:
 1
 2
 3

julia> [[1, 2] [3, 4]]
2×2 Matrix{Int64}:
 1  3
 2  4

julia> [ones(Int, 2, 2) zeros(Int, 2, 2)]
2×4 Matrix{Int64}:
 1  1  0  0
 1  1  0  0

julia> [zeros(Int, 2, 2)
         ones(Int, 2, 2)]
4×2 Matrix{Int64}:
 0  0
 0  0
 1  1
 1  1

julia> [ones(Int, 2, 2) [1; 2]
         [3 4] 5]
3×3 Matrix{Int64}:
 1  1  1
 1  1  2
 3  4  5
```

#### 数组推断（array comprehension） 

```julia
julia> [x^2 for x in 1:2]
2-element Vector{Int64}:
 1
 4

julia> [x * y for x in 1:2 for y in 1:3]
6-element Vector{Int64}:
 1
 2
 3
 2
 4
 6

julia> Float64[x^2 for x in 1:4 if isodd(x)]
2-element Vector{Float64}:
 1.0
 9.0
```

#### `reshape()`通过改变形状构造

`reshape(A, dims...) -> AbstractArray`
`reshape(A, dims) -> AbstractArray`

```julia
julia> reshape(Vector(1:16), (4, 4)) # 等价 reshape(Vector(1:16), 4, 4)
4×4 Matrix{Int64}:
 1  5   9  13
 2  6  10  14
 3  7  11  15
 4  8  12  16

julia> reshape([1 2;3 4], 4)
4-element Vector{Int64}:
 1
 3
 2
 4
```

#### `copy()`

拷贝一份

#### `zeros()`/`ones()`

`zeros([T=Float64,] dims::Tuple)`，将所有元素初始化为 0

`ones([T=Float64,] dims::Tuple)`，将所有元素初始化为 1

```julia
julia> my_vector_zeros = zeros(3)
3-element Vector{Float64}:
 0.0
 0.0
 0.0

julia> my_matrix_ones = ones(Int64, 3, 2)
3×2 Matrix{Int64}:
 1  1
 1  1
 1  1
```

#### `trues()`/`flase()`

创建元素均为 true/flase 的数组

#### `rand()`/`randn()`

构造随机数组

### 一维数组 Vector

#### 索引和切片

单值索引 `[k]`，Range 索引 `[n1:n2]`

`end` 关键字

#### 添加元素

`push!(vector, new_element)`，添加一个元素

`append!(vector, [new_element1, new_element2, …])`，添加多个元素

`insert(vector, new_element, index)`，在特定位置插入元素

#### 删除元素

`pop!(vector)`，删除最后一个元素

`popfirst!(vector)`，删除第一个元素

`splice!(vector, index)`，删除指定位置的元素

#### 排序

`sort(v; alg::Algorithm=defalg(v), lt=isless, by=identity, rev::Bool=false, order::Ordering=Forward)`

`lt` 为比较算法，`by` 为一种映射函数，`rev` 设定是否逆序

> `by` 参数将 v 转变为另一个数组，然后根据按个数组的排序次序，来排列最初的 v 数组。by(v) 是 v 排序的依据，因此用 by 这个单词。

`sort()` 不改变原对象，`sort!()` 才改变

#### 串联

`[]` 中使用空格和`;`进行横/纵向串联

`cat()` 沿着指定的 dims 串联输入的数组

`vcat()`垂直串联， `cat(...; dims=1)` 的缩写

`hcat()` 水平串联， `cat(...; dims=2)` 的缩写  

```julia
julia> cat(ones(2), zeros(2), dims=1)
4-element Vector{Float64}:
 1.0
 1.0
 0.0
 0.0

julia> cat(ones(2), zeros(2), dims=2)
2×2 Matrix{Float64}:
 1.0  0.0
 1.0  0.0
```

#### 维度

`length()` 返回元素总数

`ndims()` 返回维度个数

`size(array)` 以 tuple 方式返回每个维度的 size

`size(array, dim_index)` 返回相应维度的 size

### 二维数组 Matrix

#### 索引和切片

一元索引 `[k]` 将其作为一个大 Vector 按顺序检索

二元索引 `[i, j]`，`:`表示该维度上的所有值

可以利用索引筛选行、列

```julia
julia> a = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> a[:, 1] .> 2 # 注意返回的类型，不是一般的 Vector{Int64}
2-element BitVector:
 0
 1

julia> a[a[:, 1].>2, :]
1×2 Matrix{Int64}:
 3  4
```

若切片所得只有一行或一列，自动退化为 Vector



#### Basic  运算

`+` 加，`-` 减，`*` 数乘和矩阵乘法，`.*` 对应元素相乘（哈达马积）

`'` /`transpose()`转置

`inv()`求逆

`A\b` 求解线性方程组 $\boldsymbol{Ax=b}$

```julia
using Statistics

julia> names(Statistics)
14-element Vector{Symbol}:
 :Statistics
 :cor
 :cov
 :mean
 :mean!
 :median
 :median!
 :middle
 :quantile
 :quantile!
 :std
 :stdm
 :var
 :varm

julia> D = [1 2;3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> mean(D, dims=1)
1×2 Matrix{Float64}:
 2.0  3.0

julia> mean(D, dims=2)
2×1 Matrix{Float64}:
 1.5
 3.5
```

#### LinearAlgebra.jl

```julia
using LinearAlgebra
```

`dot(x, y)` 点积

`diag(A)` 提取主对角线元素

`diagm(Vector)` 由 Vector 构建对角矩阵

`eigen(A)` 返回对矩阵特征值和特征向量的封装，用`.`提取

`UpperTriangular(A)`/`LowerTriangular(A)` 上/下三角矩阵

## Pair

Pair 是一种包含两个对象的数据结构，分别存储在字段 first 和 second

为了配合管道，也可以用函数 `first()`/`last()`

> 注意不是 `seconde()` 而是 `last()`

```julia
julia> my_pair = "Julia" => 42
"Julia" => 42

julia> my_pair.first
"Julia"

julia> my_pair.second
42

julia> first(my_pair) 
"Julia"

julia> last(my_pair)
42
```

##   Dict

key-value, 系统自动检测，使 key 和 value 为一种“最大公约数”式的类型（最“大”的类型是 Any），后续添加元素都会转化为创建 Dict 时约定的类型。如果无法转化，则报错。

> 如 4.0::Float 可以转化为 4::Int，但4.1不可以，所以不能添加 4.1 这种值。

字典是无序的、可变的

#### 基本操作

```julia
julia> d = Dict("one"=>1, "two"=>2) # 传入一些 Pair 表示的键值对
Dict{String, Int64} with 2 entries:
  "two" => 2
  "one" => 1

julia> Dict([("one", 1), ("two", 2)]) # 等价写法，传入 Vector{Tuple}
Dict{String, Int64} with 2 entries:
  "two" => 2
  "one" => 1

julia> print(d)
Dict("two" => 2, "one" => 1) # 字典的无序性

julia> d["one"] # 索引
1

julia> d["Three"] =3 # 添加新元素
3

julia> d
Dict{String, Int64} with 3 entries:
  "Three" => 3
  "two"   => 2
  "one"   => 1

julia> delete!(d, "one") # !表示就地改动，不创造新变量
Dict{String, Int64} with 2 entries:
  "Three" => 3
  "two"   => 2

julia> d["four"]=4.0
4.0

julia> d # 新元素自动转换，与已有value的数据类型保持一致
Dict{String, Int64} with 3 entries:
  "Three" => 3
  "two"   => 2
  "four"  => 4 

julia> "two" in keys(d)
true
```

可以一开始就明确声明 Dict 中 key 和 value 的对象类型，

```julia
julia> df = Dict{String, Any}("one"=>1, "two"=>(2,))
Dict{String, Any} with 2 entries:
  "two" => (2,)
  "one" => 1
```

构建时可以使用表达式

```julia
Dict(i => f(i) for i = 1:10)
```

#### `Dict(zip(v1, v2))`

由两个 Vector 构建 Dict

```julia
julia> A = ["one", "two", "three"];
julia> B = [1, 2, 3];
julia> name2number_map = Dict(zip(A, B))
Dict{String, Int64} with 3 entries:
  "two"   => 2
  "one"   => 1
  "three" => 3
```

#### `get(dict, "a", x)` 

输出 dict 中 key 为 "a" 的 value，若不存在这个键则返回 x

## Set

```julia
julia> s = Set([1, 3, 2, 2]) # 集合无序
Set{Int64} with 3 elements:
  2
  3
  1
```

`issubset(s1, s)`

`intersect(s1, s2)` 求交集

`union(s1, s2)` 求并集
