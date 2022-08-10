

[TOC]

# Data Structure

## Range

Range 是一种迭代器，不自动展开为数组，有利于节省内存

### 创建

`1:5`，`UnitRange{Int64}`

`1:2:9`，`StepRange{Int64}`，可由`range(start, end, step, length)`创建

#### `range()`

注意 `range()` 符合多重分发，实际上有多个函数

```julia
julia> range(1, length=100)
1:100

julia> range(1, stop=100)
1:100

julia> range(1, step=5, length=100)
1:5:496

julia> range(1, step=5, stop=100)
1:5:96

julia> range(1, 10, length=101)
1.0:0.09:10.0

julia> range(1, 100, step=5)
1:5:96

julia> range(stop=10, length=5)
6:10

julia> range(stop=10, step=1, length=5)
6:1:10

julia> range(start=1, step=1, stop=10)
1:1:10
```

### `Range -> Vector`

1. **`[Range...]`**
2. **`collect(range)`**
3. `Vector(range)`
4. `[x for x in Range]`

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

`Vector{T}`，即 `Array{T, 1}`，默认为纵向（用于构造 Matrix 时）

`Matrix{T}`，即 `Array{T, 2}`



与字符串不同，数组是可变的，其元素可以被 reassignment

### 构造

#### 数组字面量 `T[]`

- 一维 Vector 元素用**逗号**分隔
- 二维 Matrix，**空格**分隔不同的列（行方向上的分隔），**分号**或**换行**分隔不同的行（列方向上的分隔）
- 数据类型写在 `[]` 之前
- `[]` 中可以是 Range 的展开：`Range...`

```julia
julia> Bool[0, 1, 0, 1]
4-element Vector{Bool}:
 0
 1
 0
 1

julia> [1:3...]
3-element Vector{Int64}:
 1
 2
 3

julia> [[1, 2], [3, 4]] # 并非矩阵，而是Vector的Vector
2-element Vector{Vector{Int64}}:
 [1, 2]
 [3, 4]

julia> Float64[[1 2]
         [3 4]]
2×2 Matrix{Float64}:
 1.0  2.0
 3.0  4.0

julia> [[1, 2] [3, 4]]
2×2 Matrix{Int64}:
 1  3
 2  4

julia> [1:3 4:6] # 空格分隔列
3×2 Matrix{Int64}:
 1  4
 2  5
 3  6

julia> [[1,2] [3;4] [5;6]] # 此时 , ; 均可
2×3 Matrix{Int64}:
 1  3  5
 2  4  6

julia> [[1 2]; [3 4]; [5 6]]
3×2 Matrix{Int64}:
 1  2
 3  4
 5  6

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

#### 推导式

`[f(x, y, ...) for x in rangeX, y in rangeY, ...]` 可以构建多维数组

```julia
julia> [x^2 for x in 1:2]
2-element Vector{Int64}:
 1
 4

julia> [n*m for n in 1:3, m in 1:2] # 构建 N*M 维矩阵
3×2 Matrix{Int64}:
 1  2
 2  4
 3  6
```

`f(x, y) for x in rangeX for y in rangeY` 交叉遍历 x 和 y，返回类型为 Base.Interators.Flatten

使用 `[]` 或 `collect()` 对其展开的结果是**一维**的向量 

```julia


julia> [x * y for x in 1:2 for y in 1:3]
6-element Vector{Int64}:
 1
 2
 3
 2
 4
 6
```

还可以在推导式的最后加入条件

```julia

julia> Float64[x^2 for x in 1:4 if isodd(x)]
2-element Vector{Float64}:
 1.0
 9.0

julia> [x*y for x in 1:2, y in 1:3 if iseven(y)]
2-element Vector{Int64}:
 2
 4
```

#### 全同数组

##### `fill(x, dims)`

`fill(x, dims::Tuple)`
`fill(x, dims...)`

按照 dims 的结构填充每个元素为 x

```julia
fill(1, 3) # [1, 1, 1]

fill(1.0, (2, 3))
fill(1.0, 2, 3)
# 2×3 Matrix{Float64}:
#  1.0  1.0  1.0
#  1.0  1.0  1.0
```

##### `fill!(A, x)`

将想要的元素填充到数组的每一个元素上

可以先用 `Array{T}(undef, dims...)`，创建全为 `undef`（undefined）元素的数组，然后使用 `fill!(A, x)` 填充，相当于 `x * ones(T, dims…)`

```julia
julia> Vector{Int}(undef, 2) # 所得两个数是随机的
2-element Vector{Int64}:
  0
 33

julia> my_matrix_π = Matrix{Float64}(undef, 2, 2) |>
                     m -> fill!(m, 3.14) # 完全等价于3.14ones(2, 2)
2×2 Matrix{Float64}:
 3.14  3.14
 3.14  3.14
```

##### `zeros()`/`ones()`

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

##### `trues()`/`flases()`

创建元素均为 true/flase 的数组

#### 重复

`repeat()`

1. `repeat(A::AbstractArray, counts::Integer...)`

```julia
julia> repeat([1, 2, 3], 2)
6-element Vector{Int64}:
 1
 2
 3
 1
 2
 3

julia> repeat([1, 2, 3], 2, 3) # 第一个参数纵向复制，第二个参数横向复制
6×3 Matrix{Int64}:
 1  1  1
 2  2  2
 3  3  3
 1  1  1
 2  2  2
 3  3  3
```

2. `repeat(A::AbstractArray; inner=ntuple(Returns(1), ndims(A)), outer=ntuple(Returns(1), ndims(A)))`

```julia
julia> repeat(1:2, inner=2)
4-element Vector{Int64}:
 1
 1
 2
 2

julia> repeat(1:2, outer=2)
4-element Vector{Int64}:
 1
 2
 1
 2

# inner 和 outer 的第一个分量都是纵向复制，第二个分量都是横向复制
julia> repeat([1 2; 3 4], inner=(2, 1), outer=(1, 3)) 
4×6 Matrix{Int64}:
 1  2  1  2  1  2
 1  2  1  2  1  2
 3  4  3  4  3  4
 3  4  3  4  3  4
```

#### 拷贝

数组是可变对象，直接 `=` 赋值只是起了一个别名。要想拷贝一份一模一样的，必须用 `copy()`/`deepcopy()`，后者为深拷贝（对嵌套数组）

#### 随机数数组

##### `rand()`/`randn()`

构造随机数组，前者为 `[0, 1)` 均匀分布，后者为标准正态分布

### Convert

#### 数组变形

##### `reshape()`

`reshape(A, dims...) -> AbstractArray`
`reshape(A, dims) -> AbstractArray`

##### 矩阵与向量的相互转化

- 向量->矩阵
  - `reshape(vec, Matrix_dims)`

```julia

julia> reshape(Vector(1:16), (4, 4)) # 等价于reshape(Vector(1:16), 4, 4)
4×4 Matrix{Int64}:
 1  5   9  13
 2  6  10  14
 3  7  11  15
 4  8  12  16
```

- 矩阵->向量，一列一列的展开
  - `A[:]`
  - `reshape(A, length(A))`

```julia
a = [1 2; 3 4; 5 6]
a[:] # [1, 3, 5, 2, 4, 6]
reshape(a, 6) # [1, 3, 5, 2, 4, 6]
```



#### iterator -> Vector

`[iterator...]`

`collect(iterator)`

#### Range -> Vector

`Vector(range)`

#### Int -> Vector

`digits(n; base=10)` 将各位数字排列成各位数字的向量，个位在前高位在后

```julia
digits(4, base=2) # [0, 0, 1]
digits(123) # [3, 2, 1]
```

#### DataFrame -> Matrix

`Matrix(df)`

### `[]`选择器

#### Int/Vector{Int}/Range

- Vector
  - 单值索引 `[k]`
  - `end` 关键字
  - Range 索引 `[n1:n2]`
  - 整数向量索引 `[[1, 2, 3]]`
  - `:`表示所有值，建立整个 Vector 的副本
- Matrix
  - 一元索引 `[k]` 将其作为一个按列展开的大 Vector 检索
  - 二元索引 `[i, j]`，`:`表示该维度上的所有值
  - 一个维度上使用单值索引时，切片所得只有一行或一列，自动退化为 Vector；**若不想退化，哪怕只有一行、一列，也要用 Range 索引**
  - `CartesianIndices()` 返回对矩阵 `[i, j]` 对的索引

```julia
julia> A = [1 2 3; -3 -2 1; 3 -1 2; 4 5 6]
4×3 Matrix{Int64}:
  1   2  3
 -3  -2  1
  3  -1  2
  4   5  6

julia> A[2, :]
3-element Vector{Int64}:
 -3
 -2
  1

julia> A[2:2, :]
1×3 Matrix{Int64}:
 -3  -2  1

julia> CartesianIndices(A)
4×3 CartesianIndices{2, Tuple{Base.OneTo{Int64}, Base.OneTo{Int64}}}:
 CartesianIndex(1, 1)  CartesianIndex(1, 2)  CartesianIndex(1, 3)
 CartesianIndex(2, 1)  CartesianIndex(2, 2)  CartesianIndex(2, 3)
 CartesianIndex(3, 1)  CartesianIndex(3, 2)  CartesianIndex(3, 3)
 CartesianIndex(4, 1)  CartesianIndex(4, 2)  CartesianIndex(4, 3)

julia> [index[1] for index in CartesianIndices(A)]
4×3 Matrix{Int64}:
 1  1  1
 2  2  2
 3  3  3
 4  4  4

julia> [index[2] for index in CartesianIndices(A)]
4×3 Matrix{Int64}:
 1  2  3
 1  2  3
 1  2  3
 1  2  3
```

#### BitVector

```julia
julia> a = [1, 2, 3, 4, 5]
5-element Vector{Int64}:
 1
 2
 3
 4
 5

julia> a.>2
5-element BitVector:
 0
 0
 1
 1
 1

julia> a[a.>2]
3-element Vector{Int64}:
 3
 4
 5
```

例：筛选出第三列的值大于2的那些行

```julia
A = [1 2 3; -3 -2 1; 3 -1 2; 4 5 6]
filter_row = >(2).(A[:, 3])
A[filter_row, :]
```

#### `DataFrames.Not()`

该函数返回一个独特的对象，用于反选，表示除参数以外的所有行/列

Not 接受 Int（可以是多个，用逗号间隔）/Vector{Int}/Range

```julia
A[Not(2, 3), :]
A[Not([2, 3]), :]
```



### Meta 信息

`eltype()` 返回元素类型

`length()` 返回元素总数

`isempty()`判断数组是否为空，即长度是否为0，等价于 `length(arr)==0`

`ndims()` 返回维度个数

`size()` 以 tuple 方式返回每个维度的 size

`size(matrix, dim_index)` 返回相应维度的 size

`eachindex(A)` 一个访问 `A` 中每一个位置的高效迭代器

### 矩阵运算

#### 基本运算

`+` 加，`-` 减，两个 size 相同的矩阵对应元素加减可以省略 `.`

`*` 数乘和矩阵乘法

`.*` 对应元素相乘（哈达马积）

`⊗` (**\otimes TAB**) 克罗内克积 `using Kronecker`

```julia
using Kronecker
[1, 1, 1] ⊗ [1 2; 3 4]
```

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

#### LinearAlgebra 包

```julia
using LinearAlgebra
```

`dot(x, y)` 点积

`diag(A)` 提取主对角线元素

`diagm(Vector)` 由 Vector 构建对角矩阵

```julia
A = diagm(ones(Int, 3))
```

`I(k)` 表示k 阶单位阵的一个对象，可以参与各种矩阵运算；传给 `Matrix()`就能生成相应矩阵

`Matrix{T}(I, m, n)`, `m` 行 `n` 列的主对角线为 1 的矩阵

`eigen(A)` 返回对矩阵特征值和特征向量的封装，用`.`提取

`UpperTriangular(A)`/`LowerTriangular(A)` 上/下三角矩阵

### 增删改查

#### 改

对数组元素重新赋值即可

#### 增

##### `push!(vector, new_element)`

添加一个元素到末尾

##### `pushfirst!() `

在开头添加元素

##### `append!(vector, [new_element1, new_element2, ...])`

添加一个数组中的多个元素（不是嵌套）

##### `insert(vector, new_element, index)`

在特定位置插入元素，返回操作结束的向量

#### 删

##### `pop!(vector)`

删除并返回最后一个元素

##### `popfirst!(vector)`

删除并返回第一个元素

##### `splice!(vector, index)`

删除并返回指定位置的元素

##### `deleteat!(vector, index)`

删除指定位置的元素，返回操作结束的向量

#### 查

返回 Index 的函数

##### `findfirst()`/`findlast()`/`findall()`

最常用的方法，第一个参数是函数，第二个参数是数组

对于向量返回整数，对于矩阵返回 `CartesianIndex{2}`，可以用索引获得各分量

##### `findnext()`/`findprev()`

##### `findmax()`/`findmin()`

`findmax(f, domain)`，第二个参数为定义域，寻找 f 作用于 domain 后的极值，返回 tuple `(极值, 极值对应的index或key)`

##### `argmax(itr)`/`argmin(itr)`

返回 iterator 中最大/最小元素的 index or key

### 排序

`sort(v; alg::Algorithm=defalg(v), lt=isless, by=identity, rev::Bool=false, order::Ordering=Forward)`

`lt` 为比较算法，`by` 为一种映射函数，`rev` 设定是否逆序

> `by` 参数将 v 转变为另一个数组，然后根据按个数组的排序次序，来排列最初的 v 数组。by(v) 是 v 排序的依据，因此用 by 这个单词。

`sort()` 返回排好序的副本，不改变原对象，`sort!()` 才改变

`sortperm()` 返回用于排序的索引，即`v[sortperm(v)] == sort(v)`

```julia
julia> v = randn(5)
5-element Array{Float64,1}:
  0.297288
  0.382396
 -0.597634
 -0.0104452
 -0.839027

julia> p = sortperm(v)
5-element Array{Int64,1}:
 5
 3
 4
 1
 2

julia> v[p]
5-element Array{Float64,1}:
 -0.839027
 -0.597634
 -0.0104452
  0.297288
  0.382396
```

### 串联

`[]` 中使用空格和`;`进行横/纵向串联

> 注意，`,` 不能起到串联的作用，例：
>
> ```julia
> julia> a = [1, 2, 3];
> julia> b = [4, 5, 6];
> 
> julia> [a, b] # a和b作为两个整体，组建了一个嵌套向量
> 2-element Vector{Vector{Int64}}:
> [1, 2, 3]
> [4, 5, 6]
> 
> julia> [a; b] # 这才是向量的串联
> 6-element Vector{Int64}:
> 1
> 2
> 3
> 4
> 5
> 6
> 
> julia> [1:3, 4:6] # 两个 Rnage 对象组建了一个向量
> 2-element Vector{UnitRange{Int64}}:
> 1:3
> 4:6
> ```

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

### 遍历

见 [遍历数组#推导式](Vectorization.ipynb)

利用推导式，一般形式为 `out_exp_res for out_exp in input_list if condition`

1. 返回类型为 Base.Generator，可以传递给函数

```{julia}
typeof(n*m for n in 1:3, m in 1:2)
```

```{julia}
sum(1/n^2 for n in 1:1000)
```

2. 推导式用 `[]` 或 `collect()` 可以展开为数组

#### 遍历单向量

- `[f(x) for x ∈ iterator]`
- `[f(i) for i ∈ eachindex(iterator)]`
- `[f(i, x) for (i, x) ∈ enumerate(iterator)]`

> enumerate() 能自动将向量展开为 (i, x) 配对的向量 

```{julia}
#| tags: []
vector = ['a', 'b', 'c']
```

```{julia}
[x^2 for x ∈ vector]
```

```{julia}
[x^i for (i, x) ∈ enumerate(vector)]
```

```{julia}
function unique_in_order(arr)
    [x for (i, x) ∈ enumerate(arr) if (i == 1 || x ≠ arr[i-1])]
end

unique_in_order("aabbccaa")
```

#### 平行遍历多向量

- `zip(v1, v2, ...)`
  - 返回类型为 Base.Iterators.Zip，可以用`collect(itr)`或`[itr...]`展开为 Vector{Tuple}

```{julia}
zip([1,2,3] , [4,5,6]) |> typeof
```

```{julia}
# 三种等价写法
[tuple for tuple in zip([1, 2, 3], [4, 5, 6])]
collect(zip([1, 2, 3], [4, 5, 6]))
[zip([1, 2, 3], [4, 5, 6])...]
```

```{julia}
[x + y for (x, y) in zip([1, 2, 3], [4, 5, 6])] 
```

#### 交叉遍历多向量

- `f(x, y) for x in iterator1 for y in iterator2`
  - 返回类型为 Base.Interators.Flatten，用 `[]` 或 `collect()` 展开后为 Vector
- `f(x, y, ...) for x in rangeX, y in rangeY, ...` 
  - 返回类型为 Base.Generator，用 `[]` 或 `collect()` 展开后为 Matrix
- `Iterators.product(v1, v2)`
  - 返回类型为 Base.Iterators.ProductIterator，展开后为 Matrix

```{julia}
[x + y for x in 1:3 for y in 1:2]
```

```{julia}
[x + y for x in 1:3, y in 1:2]
```

```{julia}
Iterators.product(1:3, 1:2) |> collect
```

```{julia}
[x + y for (x, y) in Iterators.product(1:3, 1:2)]
```

#### 遍历多维数组

1. `axes(A, dim)`

返回数组 A 在 dim 维度上的索引迭代器

```{julia}
"""
手写矩阵乘法
"""
function mygemm!(C, A, B)
    @inbounds @fastmath for m ∈ axes(A, 1), n ∈ axes(B, 2)
        Cmn = zero(eltype(C))
        for k ∈ axes(A, 2)
            Cmn += A[m, k] * B[k, n]
        end
        C[m, n] = Cmn
    end
end

A = rand(2, 4);
B = rand(4, 3);
C = zeros(2, 3);
```

```{julia}
mygemm!(C, A, B)
C
```

2. `CartesianIndices(A)`

以同样的 dims 返回 A 中各元素所有维度 index 的对象

```{julia}
CartesianIndices(ones(3, 3, 2))
```

```{julia}
A = [1 2 3; -3 -2 1; 3 -1 2; 4 5 6]
```

```{julia}
CartesianIndices(A)
```

```{julia}
[indices[1] for indices in CartesianIndices(A)] # 行索引
```

```{julia}
[indices[2] for indices in CartesianIndices(A)] # 列索引
```

```{julia}
[A[5-indices[1], indices[2]] for indices in CartesianIndices(A)]
```

```{julia}
[A[indices[1], 4-indices[2]] for indices in CartesianIndices(A)]
```

## Pair

Pair 是一种包含两个对象的数据结构，分别存储在字段 first 和 second

为了配合管道，也可以用函数 `first()`/`last()`

> 注意不是 `second()` 而是 `last()`

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

逻辑上都是键值对，但在不同语言中对应不同的数据结构

- R: 命名向量或命名 list
- Julia/Python: Dict
- JavaScript:  Map 或对象 `{}`



字典是**无序**的、可变的

### 创建 `Dict()`

key-value, 系统自动检测，使 key 和 value 为一种“最大公约数”式的类型（最“大”的类型是 Any），后续添加元素都会转化为创建 Dict 时约定的类型。如果无法转化，则报错。

> 如 4.0::Float 可以转化为 4::Int，但4.1不可以，所以不能添加 4.1 这种值。

**key 可以是各种类型，甚至元组**



#### 手动逐条构建

`Dict(pair1, pair2, ...)`

`Dict(Vector{Tuple})`

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
```

可以一开始就明确声明 Dict 中 key 和 value 的对象类型，

```julia
julia> df = Dict{String, Any}("one"=>1, "two"=>(2,))
Dict{String, Any} with 2 entries:
  "two" => (2,)
  "one" => 1
```

#### 使用推导式构建

```julia
Dict(i => f(i) for i = 1:10) 
```

可以按照一定的规则一次性生成大量键值对

#### `Dict(zip(v1, v2))`

用 `zip()` 将两个 Vector 组装为 iterator（`Base.Iterators.Zip{Tuple}`）, 再传给 `Dict()`

```julia
julia> A = ["one", "two", "three"];
julia> B = [1, 2, 3];
julia> name2number_map = Dict(zip(A, B))
Dict{String, Int64} with 3 entries:
  "two"   => 2
  "one"   => 1
  "three" => 3
```



```julia
chain1 = ['A', 'T', 'C', 'G']
chain2 = ['T', 'A', 'G', 'C']
const bases = Dict(zip(chain1, chain2))
# Dict('A' => 'T', 'T' => 'A', 'C' => 'G', 'G' => 'C')

"""
根据 DNA 的一条链返回另一条链

# Arguments
参数与返回值的类型为 String 或 Char
"""
function dnastrand(dna)
  # map(c -> bases[c], dna)
  collect(dna) .|> (c -> bases[c]) |> join
end

using Test
@testset "Example tests" begin
  @test dnastrand("AAAA") == "TTTT"
  @test dnastrand("ATTGC") == "TAACG"
  @test dnastrand("GTAT") == "CATA"
end
```

### 增删改查

#### 增删改

```julia
julia> d["Three"] =3 # 赋值添加新元素，修改旧元素
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

#### Lookup

Dict 的核心功能是查找（Lookup），即**根据 key 返回 value**，它的实现结构使查找速度非常快

- `dict[key]`
- `get(dict, "a", x)` 输出 dict 中 key 为 "a" 的 value，若不存在这个键则返回 x

#### reverse lookup

根据 value 返回 [keys]，如 `findall(isequal(value), dict)`

#### `findmax()`/`findmin()`

作用于 Dict，返回 (key, value)

```julia
julia> dict1 = Dict(100=>"X", 220 => "Y")
Dict{Int64,String} with 2 entries:
 100 => "X"
 220 => "Y"
 
julia> findmin(dict1)
("X", 100)
```

### 判断

#### `haskey(dict, key)`/`∈(pair, dict)`



### Iterator

Dict 本身作为 iterator，每个元素（直接遍历的单位）都是 Pair

但也可以借助 tuple，直接遍历 key 和 value

```julia
julia> d = Dict('a' => 1, 'b' => 2, 'c' => 3)
Dict{Char, Int64} with 3 entries:
  'a' => 1
  'c' => 3
  'b' => 2

julia> [p for p ∈ d] # p 都是 pair
3-element Vector{Pair{Char, Int64}}:
 'a' => 1
 'c' => 3
 'b' => 2

julia> ["$k: $v" for (k, v) ∈ d] # (k, v) 取出了 key 和 value
3-element Vector{String}:
 "a: 1"
 "c: 3"
 "b: 2"
```

`keys(dict)` ， `values(dict)`， `pairs(dict)` 可以获得这些 iterator

要注意，`keys(dict)` 和 `values(dict)` 不是 Vector，要用 `[iterator...]` 语法才能转化为 Vector

### 合并

#### `merge()`

合并两个 Dict，若有重复的键，后面 Dict 的 value 覆盖前面 Dict



## Tuple

元组是不可变的，不能修改其元素

### 创建和索引

可以包含多种类型的数据的、不可变的容器，可以用小括号或 `tuple()` 显式定义

创建只有一个元素的 tuple 时，必须在这个元素后面加上逗号，否则编译器会将其视为无括号的单个元素

```julia
julia> tuple(1,)
(1,)
```

可以用 `[n]` 索引访问

### Named Tuple

NamedTuple，命名元组，很像 R 中具有 names 属性的向量

#### 创建

1. 最简单的 `(name1 = value1, name2 = value2, ...)`

为了缩短定义的代码长度，在使用已经有 names 的 values 时，可以在 names 前加 `;`

```julia
i = 1
f = 3.14
s = "Julia"

# 一般 tuple
(i, f, s) # (1, 3.14, "Julia") 

# named tuple
my_quick_namedtuple = (; i, f, s) # (i = 1, f = 3.14, s = "Julia")
```



2. `NamedTuple{names[, T]}(args::Tuple)` 

```julia
NamedTuple{(:i, :f, :s)}((i, f, s))
```



3. `NamedTuple(itr)`/`(; itr...)`，很像 Dict 的构造

```julia
keys = (:a, :b, :c)
values = (1, 2, 3)

NamedTuple(zip(keys, values))
(; zip(keys, values)...)
```

#### Index and Subset

除了数字索引，还可以使用 Symbol 索引，以及用 `.name` 访问

```julia
julia> x = (a=1, b=2)
(a = 1, b = 2)

julia> typeof(x)
NamedTuple{(:a, :b), Tuple{Int64, Int64}}

julia> x[1]
1

julia> x.a
1

julia> x[:a]
1

julia> x[(:a,)] # subset
(a = 1,)
```

#### Iterator

```julia
julia> keys(x)
(:a, :b)

julia> values(x)
(1, 2)

julia> collect(x)
2-element Vector{Int64}:
 1
 2

julia> pairs(x)
pairs(::NamedTuple) with 2 entries:
  :a => 1
  :b => 2

julia> collect(pairs(x))
2-element Vector{Pair{Symbol, Int64}}:
 :a => 1
 :b => 2
```

#### 合并

`merge(...)`

合并两个命名元组，若有重复的键，后者的 value 覆盖前者

## Set

若要删掉重复元素，只保留独特元素，已经有了 `unique()` 函数

```julia
julia> s = Set([1, 3, 2, 2]) # 集合无序
Set{Int64} with 3 elements:
  2
  3
  1

julia> var_site = Set{String}(["Google","Runoob","Taobao"])
Set{String} with 3 elements:
  "Google"
  "Taobao"
  "Runoob"
```

`push!(set, x)` 添加元素

`in(x, set)` 是否存在

`issubset(s1, s)`

`intersect(s1, s2)` 求交集

`union(s1, s2)` 求并集

`setdiff(s1, s2)` 在 s1 中不在 s2 中





## String

字符串的类型为 `String`，父类型为 `AbstractString`

内存中储存的字符串是不可变的（不能对其中某个字符 reassignment），只能通过变形赋值在内存中建立一个新的字符串（变量名可以仍为旧名，旧字符串被垃圾回收）

### 构造

#### 一对或三对双引号

```julia
# 用一对双引号或三对双引号
# 出于习惯，多行字符串通常用三对双引号
julia> typeof("x")
String
julia> typeof("""x""")
String

# 若字符串中本来就有双引号，则需要对其转义，或最外层用三对双引号
julia> s = """Contains "quote" characters"""
"Contains \"quote\" characters"
```

#### `repeat()`

```julia
julia> repeat(".:Z:.", 10)
".:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:."
```

#### `String()`

接收 Vector{Char}，返回将其连接起来的 String

### 类型转换

#### `string(n, base, pad)` 数字转字符串

```julia
julia> string(328, base = 8, pad = 6) # 位数不足pad时补0
"000510"
```

#### `parse(type, str; base=10)` 字符串转数字

```julia
julia> parse(Int64, "3043", base=5) # 将5进制数值3043转为Int64整型的十进制数
398
```

#### `tryparse()`

如果无法转换，不报 ERROR，而是返回 `nothing`

### 转换大小写

#### `uppercase()`/`lowercase()` 字符全部大/小写

#### `titlecase()` 所有单词首字母大写

`titlecase(s::AbstractString; [wordsep::Function], strict::Bool=true) -> String`

- strict为true，单词非首字母的其他字母小写
- 不设置 wordsep 时，非字母都被视为单词的间隔符，包括表示缩写的单撇
  - 为解决这个问题，可以将间隔符设为空格

```julia
str = "How can mirrors be real if our eyes aren't real"
titlecase(str, wordsep=isspace) # isspace 是函数
# 如果wordsep默认，'是单词分隔符，后面的 t 会大写
using Pipe
@pipe split(str) .|> uppercasefirst |> join(_, ' ') # 等价
# "How Can Mirrors Be Real If Our Eyes Aren't Real"
```



#### `uppercasefirst()`/`lowercasefirst()` 字符串首字母大/小写

### 规模 size

`length()` 字符数

`sizeof()` 字节数

### 索引 index

`[]`可取得 string 中的任意字符，索引表示字节数，可以是数字（从 1 开始），也可以是关键字 `end`

```julia
julia> str = "Hello, world."
"Hello, world."
julia> str[1]
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)
julia> str[8]
'w': ASCII/Unicode U+0077 (category Ll: Letter, lowercase)

julia> str[end]
'.': ASCII/Unicode U+002e (category Po: Punctuation, other)
julia> str[end-1]
'd': ASCII/Unicode U+0064 (category Ll: Letter, lowercase)
julia> str[end÷2]
',': ASCII/Unicode U+002c (category Po: Punctuation, other)
```



#### 多字节字符问题

当其中存在 UTF-8 字符时，码值大于等于 `0x80` 的字符为多字节字符（有的甚至是 4 字节），连续字符的有效索引位置（字节数）并不是连续的。 

```julia
julia> s = "\u2200x\u2203y"
"∀x∃y"
julia> length(s)
4
julia> sizeof(s)
8
julia> lastindex(s) # lastindex()返回最大索引值（字节数）
8

julia> s[1]
'∀': Unicode U+2200 (category Sm: Symbol, math)

julia> s[2]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] getindex_continued(s::String, i::Int64, u::UInt32)
   @ Base .\strings\string.jl:233
 [3] getindex(s::String, i::Int64)
   @ Base .\strings\string.jl:226
 [4] top-level scope
   @ REPL[28]:1

julia> s[4]
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
julia> s[5]
'∃': Unicode U+2203 (category Sm: Symbol, math)
julia> s[8]
'y': ASCII/Unicode U+0079 (category Ll: Letter, lowercase)
```

- `firstindex()` 返回第一个字符的索引值

- `lastindex()`返回最后一个字符的索引值
- `nextind()`
- `prevind()`

为此，需要使用函数 `nextind(str::AbstractString, i::Integer, n::Integer=1) -> Int`/`prevind()`，从索引 i 开始向后/前寻找 next 字符的有效 index

- `n = 1` 时，获得 `i` 位置之后/前首个 Unicode 字符的有效索引位置
- `n > 1` 时，相当于 `n = 1` 时的多次操作
- `n = 0` 时，会判断 `i` 是否为 Unicode 字符的有效起始索引，如果有效，会返回 `i` 值，否则报 StringIndexError（无效索引）或 BoundsError（越界）异常。  

```julia
julia> i1 = nextind(s, 0) # i取0，n默认取1
1
julia> i2 = nextind(s,i1) # 以前一个有效索引为参数
4
julia> i3 = nextind(s,i2) # 以前一个有效索引为参数
5
julia> i4 = nextind(s,i3) # 以前一个有效索引为参数
8
julia> i5 = nextind(s,i4) # 以前一个有效索引为参数
9
julia> i5> lastindex(s) # 判断获得的索引是否越界
true # 已经超出s实际的字符长度
julia> s[i1], s[i2], s[i3], s[i4] # 以获得各有效索引提取字符
('∀', 'x', '∃', 'y')

julia> nextind(s, 3, 0) # 判断3是否为有效索引位置
ERROR: StringIndexError: invalid index [3], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] nextind(s::String, i::Int64, n::Int64)
   @ Base .\strings\basic.jl:559
 [3] top-level scope
   @ REPL[48]:1

julia> nextind(s, 4, 0) # 判断4是否为有效索引位置
4 # 有效，返回该值
```

### 遍历 map

#### `1:length()/lastindex()`

由单字节字符组成的 `string`，可以用 `length()` 或 `lastindex()` 遍历

````julia
julia> for i = 1:length(str)
         print(str[i])
       end
H e l l o ,   w o r l d .

# 这种遍历都不适用包含多字节字符的string
julia> for i = 1:length(s)
         print(s[i])
       end
∀ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] getindex_continued(s::String, i::Int64, u::UInt32)
   @ Base .\strings\string.jl:233
 [3] getindex(s::String, i::Int64)
   @ Base .\strings\string.jl:226
 [4] top-level scope
   @ .\REPL[56]:2
````

#### `eachindex()`

包含多字节字符的 `string`，要遍历只能用 `eachindex()`

```julia
julia> for i in eachindex(s)
         println(i, " is ", s[i]) # println()相比print()自动换行
       end
1 is ∀
4 is x
5 is ∃
8 is y
```

#### 将 string 作为迭代器

字符串也是可迭代数集的一种，可以基于迭代器，采用元素迭代的方式进行遍历  

```julia
julia> for c in s # 或 for c = s 或 for c∈s，∈符号的左边只能是char
         println(c)
       end
∀
x
∃
y
```



### 切片 Slice

`[from:to]`提取器，内部使用范围索引

- 左右闭区间，与 js 不同
- from > to，结果将会是空字符串 
- `str[:]`建立了一个 `str` 的副本



注意：表达式 **`str[k]`** 和 **`str[k:k]`** 给出的结果是不同的。**若使用一个数字的索引，提取出来的将是 char 而非 string**；用 range 作为索引，提取出来的才是字符串。

```julia
julia> "abc"[2:2]
"b"

julia> "abc"[2]
'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)
```

### 串联 concatenation

#### `*` 和 `^`

也可以用 `*` 连接字符串（`*`在数学上常表示不满足交换律的运算）

`c^k` 表示 k 个字符 c 的串联

```julia
julia> "abc" * "def"
"abcdef"

julia> greet * ", " * whom * ".\n"
"Hello, World.\n"

julia> 'a' * "bc" # 可以串联 char 和 string
"abc"

julia> broadcast(*, "ab", 'c', 'd', "ef")
"abcdef"

julia > 'A' * 'a'^5
"Aaaaaa"


julia> function towerbuilder(n)
         map(k -> (" "^(n - k)) * ("*"^(2k - 1)) * (" "^(n - k)), 1:n)
       end
towerbuilder (generic function with 1 method)

julia> towerbuilder(5)
5-element Vector{String}:
 "    *    "
 "   ***   "
 "  *****  "
 " ******* "
 "*********"
```

#### `string(s1, s2, ...)`

接收多个字符串

#### `join(iterator)`

接收字符串数组

 `join([io::IO,] iterator [, delim [, last]])`

`delim` 默认为 `""`

```julia
julia> join(["abc","def"])
"abcdef"

julia>  join(["apples", "bananas", "pineapples"], ", ", " and ")
"apples, bananas and pineapples"
```

如果 `join()` 接收 String 而非 Vector{String}，由于 String 也是 iterator，所以也能运行，将其拆分为 Char 再 join

```julia
julia> join("bitcoin", "***")
"b***i***t***c***o***i***n"
```

特别是，`join()` 接收的 iterator 可以是数字等类型，自动将其转换为 String 再拼接。

### 插值 interpolation

为避免冗长的串联，Julia 允许字符串插值

`$` 后面紧跟的变量被展开插入到字符串中

```julia
julia> greet = "Hello"
"Hello"

julia> whom = "World"
"World"

julia> "$greet, $whom."
"Hello, World."

julia> "1 + 2 = $(1 + 2)"
"1 + 2 = 3"

julia> v = [1,2,3]
3-element Vector{Int64}:
 1
 2
 3

julia> "v: $v"
"v: [1, 2, 3]"
```

如果字符串中一定要使用 `$`，需要将其转义 `\$`



但这种方式相比字符串串联，对性能有一定损害

### 格式化输出

```julia
using Printf
@printf("Expect %.3f\n", x)
```



### 比较

默认遵循字典次序

### 判断前后缀

`startwith(s, prefix)`/`endwith(s, suffix)`

### 匹配

#### `occursin()`

`occursin(needle::Union{AbstractString,AbstractPattern,AbstractChar}, haystack::AbstractString) -> Bool`

确定 `needle` 是否是 `haystack` 的子字符串。

如果 `needle` 是正则表达式，则为检查 `haystack` 是否包含匹配项。

这个函数用起来比 `match()` 方便，因为它返回 Bool，很直接

#### `contains()`/`startswith()`/`endwith`

前一个参数是 `haystack::AbstractString`，后一个参数是 `needle`

```julia
contains("China", "Ch") # true
```

### 查找

`findfirst(needle, haystack)`，查找单个字符或子串，返回值为 range 对象（即使 `needle` 的长度为 1 ，如 `3:3`）

`findlast()`

`findnext()`，还可以接受第三个参数 start

`findprev()`

`findall()`

如果搜索失败，返回 nothing 对象

```julia
julia> s
"∀x∃y"

julia> findfirst("∃y", s)
5:8

julia> s[5:8]
"∃y"
```

### 分割 split

#### `collect()`

`collect(String)::Vector{Char}`

拆分字符串为字符向量

#### `split()`

`split(str::AbstractString, [chars]; limit::Integer=0,keep::Bool=true)`

- str是待分割字符串
- chars是Char、String或正则表达式的对象，描述分隔的依据，**如果不指定，则默认为空格**，但需注意chars表达的内容一定要在str中能够找到，否则不会出现预期的结果
- 另外两个参数是可选的键值参数，分别用于限定结果的数量以及设定是否保留空的内容



分割的结果虽然是 Array，但不是 String 的 Array，而是 SubString 的 Array，需要使用构造方法 `String()` 将该类型转化为 `String` 类型

```julia
julia> a = split("hi 1 hello 2 hey 3 world", r"\d")
4-element Vector{SubString{String}}:
 "hi "
 " hello "
 " hey "
 " world"

julia> a[1]
"hi "

julia>  dump(a[1])
SubString{String}
  string: String "hi 1 hello 2 hey 3 world"
  offset: Int64 0
  ncodeunits: Int64 3

julia> String(a[1])
"hi "

julia> typeof(ans)
String
```

### 提取 extract

#### `match()` 匹配一次

`match(r::Regex, s::AbstractString[, idx::Integer[, addopts]])`

在 `s` 中搜索正则表达式 `r` 的第一个匹配项，可选的 `idx` 参数指定开始搜索的索引。

返回一个包含匹配项的 `RegexMatch`对象（匹配失败则返回 nothing），结构如下：

```julia
RegexMatch <: Any
  match::SubString{String}
  captures::Array{Union{SubString{String}, Nothing},1}
  offset::Int64
  offsets::Array{Int64,1}
  regex::Regex
```

 `.match` 记录匹配的子串整体内容，`.captures` 记录捕捉到的各分组子串内容，即match字段中的字符串里符合圆括号内正则表达式的子串，相当于正则模式中对应的各个组（Group）；若捕捉结果为空，该字段将为nothing，而offsets值会为0（无效值）。`.offset`记录匹配的子串整体在原字符串中的偏移，`offsets`记录捕捉到的各分组子串的偏移，`.regex`记录原始正则表达式的内容  

 ```julia
julia> rx = r"a(.)a"
r"a(.)a"

julia> m = match(rx, "cabac")
RegexMatch("aba", 1="b") 
# 结果已经给出了基本的提取信息：符合模式的子串整体内容，和()捕捉到的内容

julia> typeof(m)
RegexMatch

julia> dump(m)
RegexMatch
  match: SubString{String}
    string: String "cabac"
    offset: Int64 1
    ncodeunits: Int64 3
  captures: Array{Union{Nothing, SubString{String}}}((1,))
    1: SubString{String}
      string: String "cabac"
      offset: Int64 2
      ncodeunits: Int64 1
  offset: Int64 2
  offsets: Array{Int64}((1,)) [3]
  regex: Regex
    pattern: String "a(.)a"
    compile_options: UInt32 0x040a0002
    match_options: UInt32 0x40000000
    regex: Ptr{Nothing} @0x000000001c46e9d0

julia> m.match
"aba"

julia> m.captures
1-element Vector{Union{Nothing, SubString{String}}}:
 "b"

julia> match(rx, "cabac", 3) === nothing
true
 ```

#### `eachmatch() `匹配多次

将每个匹配部位处得到的 RegexMatch 封装在一个迭代器中 

```julia
julia> n = eachmatch(r"cq(\d)", "apcq1apcq2apcq3")
Base.RegexMatchIterator(r"cq(\d)", "apcq1apcq2apcq3", false)

julia> for i in n
         println(i)
       end
RegexMatch("cq1", 1="1")
RegexMatch("cq2", 1="2")
RegexMatch("cq3", 1="3")
```

#### 最佳实践

如果仅需要最终的匹配内容，而不需要RegexMatch结构，可以使用以下的命令实现  

`collect(m.match for m in eachmatch(r, s))  `

```julia
julia> collect(m.match for m in eachmatch(r"cq(\d)", "apcq1apcq2apcq3"))
3-element Vector{SubString{String}}:
 "cq1"
 "cq2"
 "cq3"
```

若无法提取，则会返回零元素的数组  

### 替换 replace

##### `replace()`

`replace(str::AbstractString, pattern => rpl; count) `

- str为原字符串
- pattern是Char、String或正则表达式类型（描述欲替换内容的模式）
- rpl是用于替换的新内容，可以是String、Char或一个函数对象，当rpl为一个函数时，pattern匹配的子串内容s会被rpl（s）的计算结果所代替
- count为可选，用于指定从左到右需要替换的个数，不设置时会将所有匹配上的内容替换，否则会替换掉count个内容
- 注意，**从 pattern 到 rpl 的符号是 `=>`，而非表示匿名函数的 `->`**

```julia
julia> s = replace(str, "o"=>"p")
"Hellp, wprld."

julia> s = replace(str, 'o'=>'p'; count=1)
"Hellp, world."

julia> replace(str, r"o"=>uppercase)
"HellO, wOrld."
```

#### `map(f, string)`

注意：`f` 必须返回 `Char`，才能使用 `f` 更换 `string` 的每一个字符。

### 删除头尾字符

#### `strip`/`lstrip`/`rstrip` 删除头尾空格或指定字符

`strip([pred=isspace,] str::AbstractString) -> SubString`
`strip(str::AbstractString, chars) -> SubString`

从 `str` 中删除前导和尾随字符，这些字符由 `chars` 指定或函数 `pred` 返回 `true`。

默认行为是删除前导和尾随空格和分隔符。

可选的 `chars` 参数指定要删除的字符：它可以是单个字符、向量或字符集。

```julia
julia> strip("{3, 5}\n", ['{', '}', '\n'])
"3, 5"
```

#### `chop` 删除头尾指定数量的字符

`chop(s::AbstractString; head::Integer = 0, tail::Integer = 1)`

从 `s` 中删除前 `head` 个和后 `tail` 个字符。如果请求删除的字符多于 `length(s)`，则返回一个空字符串。

```julia
julia> a = "March"
"March"

julia> chop(a)
"Marc"

julia> chop(a, head = 1, tail = 2)
"ar"

julia> chop(a, head = 5, tail = 5)
""
```

#### `chomp(s::AbstractString)` 删除尾部单个换行符

### 头尾字符补齐位数

#### `lpad()`/`rpad()`

`lpad(s, n::Integer, p::Union{AbstractChar,AbstractString}=' ') -> String`

Stringify `s` and pad the resulting string on the left with `p` to make it `n` characters (in [`textwidth`](vscode-file://vscode-app/c:/Program Files/Microsoft VS Code/resources/app/out/vs/code/electron-browser/workbench/workbench.html)) long. If `s` is already `n` characters long, an equal string is returned. Pad with spaces by default.

## 正则表达式

`Regex` 类

### 构造

常规字符串加前缀 `r`，或 `Regex(s::AbstractString)`（内部的特殊标识符都要转义）

```julia
julia> a = r"^\s*(?:#|$)"
r"^\s*(?:#|$)"

julia> typeof(a)
Regex
```



`i`后缀，忽略大小写

