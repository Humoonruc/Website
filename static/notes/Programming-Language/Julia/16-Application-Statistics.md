## Statistics

### Statistics.jl

#### `count()`

对一个迭代器中满足条件的元素计数

`count([f=identity,] itr; init=0) -> Integer`

计算 `itr` 中函数 `f` 返回 `true` 的元素数量。如果 `f` 被省略，则计算 `itr` 中的 `true` 元素的数量（应该是布尔值的集合）。 `init` 可选地指定开始计数的值，因此也确定输出类型。

#### `DataStructures.counter()` 频数统计

接收 dict, sequence, generator 等，返回一个 Accumulator 对象，可以像 Dict 一样访问

#### `maximum()/minimum()/extrema()` 极值

`extrema(itr)`返回 `(mimimum(itr), maximum(itr))`

#### `sum()` 求和

`sum([f,] itr; [init])`

#### `cumsum()`/`cumprod()`

#### `mean()`/`median()`/`cor()`/`var()`/`std()`/`quantile(itr, x)`

都返回 Float

> `using Statistics`

`mean([f, ]itr)::Float`

`median(itr)::Float` 

#### `mode()`

> `using StatsBase`

`mode(itr)`

### Random.jl

#### `rand()`

`rand([rng=GLOBAL_RNG], [S], [dims...])` 从范围 S 中随机选择一个（数），S 默认为 Float64 的 [0, 1) 均匀分布. 如果只有一个整数参数，会将其作为 dims

即`rand(n)`会生成随机数向量

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

#### `randn()` 

**正态分布**随机数

#### `seed!(k)`

设定随机数种子

> 必须先导入 `using Random:seed!`
>
> [Random Numbers · The Julia Language](https://docs.julialang.org/en/v1/stdlib/Random/)

```julia
my_seed = seed!(123)
rand(my_seed, 3)
```

#### `randsubseq()` 伯努利抽样

Return a vector consisting of a random subsequence of the given array A, where each element of A is included (in order) with independent probability p. Technically, this process is known as "Bernoulli sampling" of A.

####   `shuffle(A)`

Random permutation elements of A

### StatsBase.jl

#### Weight Vectors

[Weight Vectors · StatsBase.jl (juliastats.org)](https://juliastats.org/StatsBase.jl/stable/weights/)

权重向量，这是 StatsBase.jl 自行规定的一种数据结构，一般用`weights()`即可

#### Sampling from Population

抽样函数

`sample([rng], a, [wv::AbstractWeights], n::Integer; replace=true, ordered=false)`

权重向量省略时，默认等权重

```julia
using StatsBase
using DataStructures

seqs = ["a", "b", "c", "d"]
w = weights([1, 2, 3, 4])
result = sample(seqs, w, 1000000; replace=true, ordered=false)
counter(result)
```

### Distributions.jl

```julia
using Distributions
```

#### `Normal(μ, σ)`/`Gamma()`/`Bernoulli(x)`/`Laplace()`

创建正态/伽马/伯努利/拉普拉斯分布

#### `params(D)`

返回分布的参数

#### `pdf(D, x)`/`cdf(D, x)`

D 分布在 x 处的概率密度（Probability density function）/累积概率密度（Cumulative density function，即分布函数）

#### `rand(D, N)` 

构建分布 D 的一个容量为 N 的样本

```julia
x = rand(Normal(2, 0.5), 10000) # 由正态分布构建一个样本
histogram(x; normalize = :pdf, legend = false, opacity = 0.5) # 绘制直方图
plot!(D; linewidth = 2, xlabel = "x", ylabel = "pdf(x)") # 与正态分布的概率密度曲线对照
```

### Distributed.jl

`@distributed`, `pmap`, `addprocs`

### StatsPlots.jl

#### `plot(D)` 

绘制一个分布的概率密度图

#### `plot(D; func = cdf)` 

绘制一个分布的分布函数（累积密度函数）

```julia
using Distributions
using StatsPlots
using Pipe


Ds = Gamma.([2, 9, 7.5, 0.5], [2, 0.5, 1, 1]) # 生成4个Gamma分布

labels = @pipe params.(Ds) .|> # 返回各分布的参数
               string("Gamma", _) |> # 字符串连接
               reshape(_, 1, :) # 变形为 1 行的矩阵，因为plot()接受行向量作为标签

plot(Ds;
    xaxis=("x", (0, 20)), yaxis=("pdf(x)", (0, 0.5)), labels=labels,
    linewidth=2, legend=:topright
)

plot(Ds;
    func=cdf,
    xaxis=("x", (0, 20)), yaxis=("cdf(x)", (0, 1.05)), labels=labels,
    linewidth=2, legend=:bottomright
)

# 以下代码同样能绘制累积概率密度函数
cdfs = [x -> cdf(D, x) for D in Ds]
plot(cdfs;
    xaxis=("x", (0, 20)), yaxis=("cdf(x)", (0, 1.05)), labels=labels,
    linewidth=2, legend=:bottomright
)
```



