[TOC]

# Estimation

这里只包含了作为 Simulation 部分前置的代码，有些意义不大的回归和图表就不写了

## Data Processing

### Import Modules


```julia
using JSON, CSV, JLD # IO
using DataFrames # Data Processing
using LinearAlgebra, Statistics, Kronecker # Math
using Pipe # Programming

using RCall # Use R for regression and visualization
R"""
library(tidyverse)
library(data.table)
library(magrittr)
library(ivreg)
"""
```




    RObject{StrSxp}
     [1] "ivreg"      "magrittr"   "data.table" "forcats"    "stringr"   
     [6] "dplyr"      "purrr"      "readr"      "tidyr"      "tibble"    
    [11] "ggplot2"    "tidyverse"  "stats"      "graphics"   "grDevices" 
    [16] "utils"      "datasets"   "methods"    "base"      




### Read Data


```julia
# 标量
const scalars = JSON.parsefile("../data/scalar.json")
```




    Dict{String, Any} with 3 entries:
      "theta" => Any[3.6, 8.28, 12.86]
      "N"     => 19
      "beta"  => 0.21221




```julia
# 国家代码表
const country_table = CSV.read("../data/country_code.csv", DataFrame);
println(country_table)
```

    [1m19×3 DataFrame[0m
    [1m Row [0m│[1m id    [0m[1m code    [0m[1m name           [0m
    [1m     [0m│[90m Int64 [0m[90m String3 [0m[90m String15       [0m
    ─────┼────────────────────────────────
       1 │     1  AL       Australia
       2 │     2  AU       Austria
       3 │     3  BE       Belgium
       4 │     4  CA       Canada
       5 │     5  DK       Denmark
       6 │     6  FI       Finland
       7 │     7  FR       France
       8 │     8  GE       Germany
       9 │     9  GR       Greece
      10 │    10  IT       Italy
      11 │    11  JP       Japan
      12 │    12  NE       Netherlands
      13 │    13  NZ       New Zealand
      14 │    14  NO       Norway
      15 │    15  PO       Portugal
      16 │    16  SP       Spain
      17 │    17  SW       Sweden
      18 │    18  UK       United Kingdom
      19 │    19  US       United States



```julia
# 用于回归的数据
const regression_data =  CSV.read("../data/regression_data.csv", DataFrame)
describe(regression_data) # 22个变量
```




<div class="data-frame"><p>22 rows × 7 columns</p><table class="data-frame"><thead><tr><th></th><th>variable</th><th>mean</th><th>min</th><th>median</th><th>max</th><th>nmissing</th><th>eltype</th></tr><tr><th></th><th title="Symbol">Symbol</th><th title="Float64">Float64</th><th title="Real">Real</th><th title="Float64">Float64</th><th title="Real">Real</th><th title="Int64">Int64</th><th title="DataType">DataType</th></tr></thead><tbody><tr><th>1</th><td>import_country</td><td>10.0</td><td>1</td><td>10.0</td><td>19</td><td>0</td><td>Int64</td></tr><tr><th>2</th><td>export_country</td><td>10.0</td><td>1</td><td>10.0</td><td>19</td><td>0</td><td>Int64</td></tr><tr><th>3</th><td>unknown1</td><td>90.0</td><td>90</td><td>90.0</td><td>90</td><td>0</td><td>Int64</td></tr><tr><th>4</th><td>trade</td><td>-4.59988</td><td>-10.698</td><td>-4.467</td><td>0.0</td><td>0</td><td>Float64</td></tr><tr><th>5</th><td>trade_prime</td><td>-4.59985</td><td>-12.533</td><td>-4.888</td><td>3.758</td><td>0</td><td>Float64</td></tr><tr><th>6</th><td>dist1</td><td>0.130194</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>7</th><td>dist2</td><td>0.149584</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>8</th><td>dist3</td><td>0.238227</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>9</th><td>dist4</td><td>0.0498615</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>10</th><td>dist5</td><td>0.221607</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>11</th><td>dist6</td><td>0.210526</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>12</th><td>border</td><td>0.0803324</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>13</th><td>r_and_d</td><td>1.90675e-17</td><td>-7.642</td><td>0.0</td><td>7.642</td><td>0</td><td>Float64</td></tr><tr><th>14</th><td>human_capital</td><td>1.23016e-18</td><td>-0.618</td><td>0.0</td><td>0.618</td><td>0</td><td>Float64</td></tr><tr><th>15</th><td>density</td><td>-4.92066e-18</td><td>-5.103</td><td>0.0</td><td>5.103</td><td>0</td><td>Float64</td></tr><tr><th>16</th><td>labor</td><td>8.61115e-18</td><td>-4.391</td><td>0.0</td><td>4.391</td><td>0</td><td>Float64</td></tr><tr><th>17</th><td>wage</td><td>-2.46033e-18</td><td>-1.502</td><td>0.0</td><td>1.502</td><td>0</td><td>Float64</td></tr><tr><th>18</th><td>common_language</td><td>0.0914127</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>19</th><td>both_in_EU</td><td>0.277008</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>20</th><td>both_in_EFTA</td><td>0.0443213</td><td>0</td><td>0.0</td><td>1</td><td>0</td><td>Int64</td></tr><tr><th>21</th><td>distance</td><td>3.54259</td><td>0.0</td><td>1.475</td><td>12.338</td><td>0</td><td>Float64</td></tr><tr><th>22</th><td>edu_year</td><td>9.24526</td><td>6.52</td><td>9.35</td><td>12.09</td><td>0</td><td>Float64</td></tr></tbody></table></div>




```julia
# 价格数据
const price_table = CSV.read("../data/price.csv", DataFrame)
first(price_table, 1) |> println # 变量更多，打印一行
```

    [1m1×51 DataFrame[0m
    [1m Row [0m│[1m country [0m[1m good1    [0m[1m good2     [0m[1m good3   [0m[1m good4    [0m[1m good5     [0m[1m good6   [0m[1m good7    [0m[1m good8    [0m[1m good9      [0m[1m good10    [0m[1m good11   [0m[1m good12    [0m[1m good13   [0m[1m good14   [0m[1m good15    [0m[1m good16   [0m[1m good17  [0m[1m good18   [0m[1m good19     [0m[1m good20    [0m[1m good21   [0m[1m good22     [0m[1m good23     [0m[1m good24   [0m[1m good25    [0m[1m good26   [0m[1m good27   [0m[1m good28    [0m[1m good29   [0m[1m good30   [0m[1m good31   [0m[1m good32   [0m[1m good33   [0m[1m good34   [0m[1m good35   [0m[1m good36   [0m[1m good37   [0m[1m good38   [0m[1m good39   [0m[1m good40   [0m[1m good41   [0m[1m good42   [0m[1m good43   [0m[1m good44   [0m[1m good45   [0m[1m good46    [0m[1m good47   [0m[1m good48   [0m[1m good49    [0m[1m good50    [0m
    [1m     [0m│[90m Int64   [0m[90m Float64  [0m[90m Float64   [0m[90m Float64 [0m[90m Float64  [0m[90m Float64   [0m[90m Float64 [0m[90m Float64  [0m[90m Float64  [0m[90m Float64    [0m[90m Float64   [0m[90m Float64  [0m[90m Float64   [0m[90m Float64  [0m[90m Float64  [0m[90m Float64   [0m[90m Float64  [0m[90m Float64 [0m[90m Float64  [0m[90m Float64    [0m[90m Float64   [0m[90m Float64  [0m[90m Float64    [0m[90m Float64    [0m[90m Float64  [0m[90m Float64   [0m[90m Float64  [0m[90m Float64  [0m[90m Float64   [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64   [0m[90m Float64  [0m[90m Float64  [0m[90m Float64   [0m[90m Float64   [0m
    ─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       1 │       1  0.161989  -0.315302  0.45165  0.646735  0.0922889  0.43822  0.118827  0.622043  -0.0777937  -0.188575  0.477017  -0.194214  0.375716  0.287735  -0.250431  0.113991  1.58363  0.609464  -0.0553954  0.0287407  0.195737  -0.0803136  -0.0521194  0.297005  -0.530498  0.127746  0.279552  0.0591923  0.108435  0.108435  0.108435  0.184829  -1.35004  0.264176  0.126379  0.331579  0.296428  0.564149  0.135232  0.612413  0.233926  0.189977  0.316423  0.205896  0.291221  0.0577282  0.685799  0.499404  -0.139205  -0.198938


### Data Transforming


```julia
"""
`select(df, args...)` 永远返回 DataFrame，有时候计算起来不方便
所以自定义一个 `extract(df, args...)`，返回多列 Matrix 或单列 Vector
"""
function extract(df::DataFrame, var)
    M = select(df, var) |> Matrix
    size(M, 2) > 1 ? M : reshape(M, length(M))
end
```




    extract



#### scalar.json


```julia
const N = scalars["N"]
```




    19




```julia
const β = scalars["beta"]
```




    0.21221




```julia
const θₛ= scalars["theta"] # 三种方法估计出的 θ 值
```




    3-element Vector{Any}:
      3.6
      8.28
     12.86



#### regression_data.csv

##### 进出口国 index


```julia
# 这两个变量不从文件读取也可以
index_n = extract(regression_data, :import_country); # 本质上是 (1:N) ⊗ ones(Int, N)，或 repeat(1:N, inner=N)
index_i = extract(regression_data, :export_country); # 本质上是 ones(Int, N) ⊗ (1:N)，或 repeat(1:N, outer=N)
```

##### 双边贸易数据


```julia
# 对数标准化的制造业双边贸易数据 ln(Xni/Xnn)
normalized_trade = extract(regression_data, :trade);

# ln(X'ni/X'nn), (26)式等号的左边
normalized_trade_prime = extract(regression_data, :trade_prime);

# 由 ln(X'ni) 的定义计算 (12) 式的左边 ln (Xni/Xn)/(Xii/Xi)
# 可将其视为 country n's normalized import share from country i
normalized_trade_share = -(normalized_trade_prime - normalized_trade) * β / (1 - β) + normalized_trade;
# size相同的向量的加减法，以及向量与标量的数乘，在Julia运算符重载中都有原生定义，不必写成广播形式
```

##### 地理虚拟变量


```julia
# 这批变量需要的计算较少，保留变量名则很重要，所以用select()返回DataFrame

# 六档距离，说明见P21
dist = select(regression_data, 6:11)

# 是否 share border/language
border = select(regression_data, :border);
language =  select(regression_data, :common_language);

# 是否在同一个 RTA 中（欧共体EEC是EU的前身，EFTA是欧自联）
RTA = select(regression_data, :both_in_EU, :both_in_EFTA); 

# 横向合并 distance, border, language, RTA 等虚拟变量
geography_dummy = hcat(dist, border, language, RTA);
first(geography_dummy, 5) |> println # 注意，六档距离只需要 5 个 dummy variable，后面回归需要时会删除 dist1
```

    [1m5×10 DataFrame[0m
    [1m Row [0m│[1m dist1 [0m[1m dist2 [0m[1m dist3 [0m[1m dist4 [0m[1m dist5 [0m[1m dist6 [0m[1m border [0m[1m common_language [0m[1m both_in_EU [0m[1m both_in_EFTA [0m
    [1m     [0m│[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64  [0m[90m Int64           [0m[90m Int64      [0m[90m Int64        [0m
    ─────┼─────────────────────────────────────────────────────────────────────────────────────────────
       1 │     1      0      0      0      0      0       0                1           0             0
       2 │     0      0      0      0      0      1       0                0           0             0
       3 │     0      0      0      0      0      1       0                0           0             0
       4 │     0      0      0      0      0      1       0                1           0             0
       5 │     0      0      0      0      0      1       0                0           0             0


##### 对数标准化的国家特征变量

这些变量用于估计原文 5.2 节中的回归模型


```julia
# 以下 5 个变量的数值都是对数标准化的，即 ln(varᵢ/varₙ)
# 分别是(1)R&D存量 R, (2)平均受教育年限 H（衡量 human capital）
# (3)人口密度, (4)制造业劳动力数量 L, (5)经过教育调整的美元工资 w
r_and_d = extract(regression_data, :r_and_d);
human_capital = extract(regression_data, :human_capital);
density = extract(regression_data, :density);
labor = extract(regression_data, :labor);
wage = extract(regression_data, :wage);
```

##### 距离


```julia
# 国家首都之间的对数距离
ln_distance = extract(regression_data, :distance) .|> log;
```

##### 国家虚拟变量


```julia
# 进口国（目的地国）虚拟变量的矩阵
destination_matrix = Matrix{Int64}(I, N, N) ⊗ ones(Int, N);
# 出口国（来源国）虚拟变量的稀疏矩阵
source_matrix = ones(Int, N) ⊗ Matrix{Int64}(I, N, N);
```


```julia
# (28)式中的来源国虚拟变量 S_i-S_n
source_dummy = source_matrix - destination_matrix;
# 这个减法决定了 source_dummy 和 destination_dummy 在(30)式中是不对称的

# (29)式中的目的地国虚拟变量 m_n
destination_dummy = destination_matrix;
```


```julia
# 以其中一个虚拟变量为基准，用其他虚拟变量与这个基准的相对差异，作为回归模型的自变量
# 然后与虚拟变量名一起封装为 DataFrame

# DataFrame()的第一个参数是矩阵，第二个参数是列名向量
relative_source_dummy = DataFrame(
    source_dummy[:, 1:(N-1)] .- source_dummy[:, N],# 以美国（第19列）为基准，前18列都减去19列
    "S" .* string.(1:(N-1))
);

relative_destination_dummy = DataFrame(
  destination_dummy[:, 1:(N-1)] .- destination_dummy[:, N],
  "m" .* string.(1:(N-1)) # 列名
);
```

#### price.csv

50种商品的对数标准化价格 $\ln p_n(j)$（以美国为基准）


```julia
ln_p_Mat = extract(price_table, Not(:country));
```

相对价格 $r_{ni}(j)=\ln p_n(j)-\ln p_i(j)$


```julia
# 求对应每一行 (n, i) 的50种产品相对价格
ln_pₙ_Mat = ln_p_Mat ⊗ ones(Int, N)
ln_pᵢ_Mat = ones(Int, N) ⊗ ln_p_Mat
rₙᵢ_Mat = ln_pₙ_Mat - ln_pᵢ_Mat;

# 另一种写法：对 n, i 交叉遍历
# rₙᵢ_Mat = vcat([ln_p_Mat[n:n, :] - ln_p_Mat[i:i, :] for n ∈ 1:N for i ∈ 1:N]...)
```

各行第二大的 $r_{ni}(j)$，作为作为 $\ln d_{ni}$ 的代理变量


```julia
function max2(vector)
  sorted = vector |> sort |> reverse # 此处不要改变原矩阵，拷贝一份
  sorted[2] 
end

ln_dₙᵢ = @pipe mapslices(max2, rₙᵢ_Mat; dims=2) |> reshape(_, N^2);
# dims=2，沿列的方向依次应用函数，即函数的参数总是一行
```

用 50 种商品对数标准化价格的平均值作为各国价格指数 $\ln p_n$ 的代理变量


```julia
ln_p_index = @pipe mapslices(mean, ln_p_Mat; dims=2) |> reshape(_, N);
```

由 (13)式: $D_{ni}$ = ln(pᵢ) - ln(pₙ) + ln(dₙᵢ)


```julia
Dₙᵢ = [ln_p_index[i] - ln_p_index[n] for n ∈ 1:N for i ∈ 1:N] + ln_dₙᵢ;
```

#### delete invalid observations

删掉 `n==i` 的无用行，保留342行

> 这些行很多变量的标准化值都等于0，属于无效数据


```julia
valid_index = index_n .!= index_i;
# 这里可见提取 index_n 和 index_i 为向量的重要性
# 若 index_n 和 index_i 均为单列矩阵，则返回也是 Bool 型的单列矩阵
# 不 reshape 成向量，就无法作为 DataFrame 的行选择器
```


```julia
# destinations and sources index
index_n_valid = index_n[valid_index]
index_i_valid = index_i[valid_index]

# ln(X'ni/X'nn)
normalized_trade_prime_valid = normalized_trade_prime[valid_index]

# ln (Xni/Xn)/(Xii/Xi)
normalized_trade_share_valid = normalized_trade_share[valid_index]

# price_measure = exp(Dₙᵢ)，用于 Figure 2
Dₙᵢ_valid = Dₙᵢ[valid_index]
price_measure = exp.(Dₙᵢ_valid) 

# ln_distance
ln_distance_valid = ln_distance[valid_index];

# 距离、边界、语言、RTA等虚拟变量
geography_dummy_valid = geography_dummy[valid_index, :]; 

# 国家虚拟变量
relative_source_dummy_valid = relative_source_dummy[valid_index, :];
relative_destination_dummy_valid = relative_destination_dummy[valid_index, :];
country_dummy_valid = hcat(relative_source_dummy_valid, relative_destination_dummy_valid);
first(country_dummy_valid, 1) |> print
```

    [1m1×36 DataFrame[0m
    [1m Row [0m│[1m S1    [0m[1m S2    [0m[1m S3    [0m[1m S4    [0m[1m S5    [0m[1m S6    [0m[1m S7    [0m[1m S8    [0m[1m S9    [0m[1m S10   [0m[1m S11   [0m[1m S12   [0m[1m S13   [0m[1m S14   [0m[1m S15   [0m[1m S16   [0m[1m S17   [0m[1m S18   [0m[1m m1    [0m[1m m2    [0m[1m m3    [0m[1m m4    [0m[1m m5    [0m[1m m6    [0m[1m m7    [0m[1m m8    [0m[1m m9    [0m[1m m10   [0m[1m m11   [0m[1m m12   [0m[1m m13   [0m[1m m14   [0m[1m m15   [0m[1m m16   [0m[1m m17   [0m[1m m18   [0m
    [1m     [0m│[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m[90m Int64 [0m
    ─────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       1 │    -1      1      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      1      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0

## Section 3








### Figure I


```julia
lowest, highest = exp.(normalized_trade_share_valid) |> extrema
```




    (3.70330780199431e-5, 0.35848984394233474)




```julia
# 标准化贸易份额的最大值
println(highest)
```

    0.35848984394233474



```julia
# 横跨近四个数量级
log10(highest/lowest)
```




    3.9858870464473295



### Figure II


```julia
# 相关系数 correlation
cor(Dₙᵢ_valid, normalized_trade_share_valid)
```




    -0.40417825378100086



### Table II

略

### 用 (12) 式估计 $\theta$

以 $\ln (Xni/Xn)/(Xii/Xi)$ 为被解释变量，以 $D_{ni}$ 为解释变量，估计出来的系数是 $-\theta$，因此 $\theta$ 值还要取一个负号。

#### Moments Estimation

最简单的一阶矩估计


```julia
x_center = mean(Dₙᵢ_valid)
y_center = mean(normalized_trade_share_valid)
θ = y_center / x_center
```




    -8.27592961561157



$\therefore  \theta=8.28$

## Section 5.3

这部分唯一的用途在于展示 $\theta=12.86$ 这个值，对 Simulation 部分其实没什么影响


### IV Estimation

估计一个模型：以 $\ln (X_{ni}'/X_{nn}')$ 为被解释变量，以 geography_dummies 为工具变量，包括距离、边界、语言、RTA 等，以 source & destination dummies 为外生解释变量，解释内生变量 $D_{ni}$


统计、计量部分，调用生态非常完善的 R 语言


```julia
# R 不支持 Unicode 字符，部分变量要先换个名字
Dni_valid = Dₙᵢ_valid;

# 将 julia 变量转变为 R 变量，便于多次使用
# 为了回归，geography_dummy_valid 去掉 dist1 列
R"""
normalized_trade_prime_valid <- $normalized_trade_prime_valid
geography_dummy_valid <- ($geography_dummy_valid)[, -1]
country_dummy_valid <- $country_dummy_valid
Dni_valid <- $Dni_valid
""";
```


```julia
# 组织数据框
R"""
TSLS_data <- cbind(normalized_trade_prime_valid, Dni_valid, geography_dummy_valid, country_dummy_valid)
head(TSLS_data, 3)
"""
```




    RObject{VecSxp}
      normalized_trade_prime_valid Dni_valid dist2 dist3 dist4 dist5 dist6 border
    1                       -7.410 0.4218053     0     0     0     0     1      0
    2                      -10.074 0.3989645     0     0     0     0     1      0
    3                       -5.826 0.4690127     0     0     0     0     1      0
      common_language both_in_EU both_in_EFTA S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11
    1               0          0            0 -1  1  0  0  0  0  0  0  0   0   0
    2               0          0            0 -1  0  1  0  0  0  0  0  0   0   0
    3               1          0            0 -1  0  0  1  0  0  0  0  0   0   0
      S12 S13 S14 S15 S16 S17 S18 m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
    1   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
    2   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
    3   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
      m15 m16 m17 m18
    1   0   0   0   0
    2   0   0   0   0
    3   0   0   0   0





```julia
# IV Regression 的公式
R"""
formula_exogenous <- colnames(country_dummy_valid) %>% str_c(collapse = " + ")
formula_instrument <- colnames(geography_dummy_valid) %>% str_c(collapse = " + ")
formula <- str_c(
  "normalized_trade_prime_valid ~ Dni_valid + ", formula_exogenous, " | ",
  formula_instrument, " + ", formula_exogenous
)
"""
```




    RObject{StrSxp}
    [1] "normalized_trade_prime_valid ~ Dni_valid + S1 + S2 + S3 + S4 + S5 + S6 + S7 + S8 + S9 + S10 + S11 + S12 + S13 + S14 + S15 + S16 + S17 + S18 + m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 + m11 + m12 + m13 + m14 + m15 + m16 + m17 + m18 | dist2 + dist3 + dist4 + dist5 + dist6 + border + common_language + both_in_EU + both_in_EFTA + S1 + S2 + S3 + S4 + S5 + S6 + S7 + S8 + S9 + S10 + S11 + S12 + S13 + S14 + S15 + S16 + S17 + S18 + m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 + m11 + m12 + m13 + m14 + m15 + m16 + m17 + m18"





```julia
# IV Regression 结果
R"""
fit_iv_3 <- ivreg(formula = formula, data = TSLS_data)
summary(fit_iv_3, test = TRUE)
"""
```




    RObject{VecSxp}
    
    Call:
    ivreg(formula = formula, data = TSLS_data)
    
    Residuals:
         Min       1Q   Median       3Q      Max 
    -4.03108 -0.87353 -0.07295  0.91475  5.54823 
    
    Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
    (Intercept)   2.690744   1.021376   2.634 0.008860 ** 
    Dni_valid   -12.862154   1.736076  -7.409 1.27e-12 ***
    S1           -1.842036   0.330782  -5.569 5.65e-08 ***
    S2           -1.314255   0.336172  -3.909 0.000114 ***
    S3           -4.478607   0.398783 -11.231  < 2e-16 ***
    S4           -0.904355   0.324455  -2.787 0.005649 ** 
    S5           -1.987282   0.339413  -5.855 1.24e-08 ***
    S6           -0.116991   0.323000  -0.362 0.717454    
    S7            1.468290   0.327295   4.486 1.03e-05 ***
    S8            1.982772   0.353079   5.616 4.42e-08 ***
    S9           -2.055326   0.330982  -6.210 1.74e-09 ***
    S10           1.167665   0.349046   3.345 0.000925 ***
    S11           5.101323   0.453382  11.252  < 2e-16 ***
    S12          -2.475357   0.343273  -7.211 4.43e-12 ***
    S13           0.247988   0.512895   0.484 0.629084    
    S14          -1.556102   0.337816  -4.606 6.03e-06 ***
    S15           0.932966   0.446422   2.090 0.037460 *  
    S16           0.219792   0.327012   0.672 0.502017    
    S17          -0.097743   0.334265  -0.292 0.770172    
    S18           1.245900   0.336963   3.697 0.000258 ***
    m1           -4.379061   0.516788  -8.474 1.04e-15 ***
    m2           -2.373090   0.526655  -4.506 9.44e-06 ***
    m3           -0.762720   0.625382  -1.220 0.223560    
    m4           -1.195235   0.470969  -2.538 0.011654 *  
    m5           -0.886755   0.508505  -1.744 0.082197 .  
    m6           -0.634263   0.469543  -1.351 0.177761    
    m7            0.461957   0.485230   0.952 0.341834    
    m8            0.638974   0.524368   1.219 0.223956    
    m9           -0.455004   0.508776  -0.894 0.371863    
    m10          -0.867693   0.520670  -1.666 0.096645 .  
    m11           3.217836   0.772093   4.168 4.02e-05 ***
    m12           0.455939   0.522336   0.873 0.383415    
    m13           0.621791   0.672382   0.925 0.355825    
    m14           0.008904   0.469333   0.019 0.984876    
    m15           1.569687   0.564966   2.778 0.005803 ** 
    m16          -1.578771   0.488795  -3.230 0.001374 ** 
    m17           0.990810   0.469322   2.111 0.035575 *  
    m18           1.106633   0.483976   2.287 0.022910 *  
    
    Diagnostic tests:
                     df1 df2 statistic  p-value    
    Weak instruments   9 296     8.176 7.44e-11 ***
    Wu-Hausman         1 303   173.953  < 2e-16 ***
    Sargan             8  NA    47.419 1.28e-07 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Residual standard error: 1.406 on 304 degrees of freedom
    Multiple R-Squared: 0.7955,	Adjusted R-squared: 0.7706 
    Wald test: 38.05 on 37 and 304 DF,  p-value: < 2.2e-16 


​    



由 Dni_valid 的系数可知 $\theta=12.86(1.74)$

## Section 5.1

### Table III

估计 (30) 式

#### OLS Estimation


```julia
# 组织数据框
# 这次要有 dist1，故重新从 Julia 中传递包含dist1的 geography_dummy_valid 到 R
R"""
geography_dummy_valid <- $geography_dummy_valid
table3_data <- cbind(normalized_trade_prime_valid, geography_dummy_valid, country_dummy_valid) %>%
  as.data.table()
"""
```




    RObject{VecSxp}
         normalized_trade_prime_valid dist1 dist2 dist3 dist4 dist5 dist6 border
      1:                       -7.410     0     0     0     0     0     1      0
      2:                      -10.074     0     0     0     0     0     1      0
      3:                       -5.826     0     0     0     0     0     1      0
      4:                       -8.206     0     0     0     0     0     1      0
      5:                       -6.461     0     0     0     0     0     1      0
     ---                                                                        
    338:                       -8.887     0     0     0     0     1     0      0
    339:                       -9.624     0     0     0     0     1     0      0
    340:                       -7.248     0     0     0     0     1     0      0
    341:                       -7.448     0     0     0     0     1     0      0
    342:                       -5.596     0     0     0     0     1     0      0
         common_language both_in_EU both_in_EFTA S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11
      1:               0          0            0 -1  1  0  0  0  0  0  0  0   0   0
      2:               0          0            0 -1  0  1  0  0  0  0  0  0   0   0
      3:               1          0            0 -1  0  0  1  0  0  0  0  0   0   0
      4:               0          0            0 -1  0  0  0  1  0  0  0  0   0   0
      5:               0          0            0 -1  0  0  0  0  1  0  0  0   0   0
     ---                                                                           
    338:               0          0            0  1  1  1  1  1  1  1  1  1   1   1
    339:               0          0            0  1  1  1  1  1  1  1  1  1   1   1
    340:               0          0            0  1  1  1  1  1  1  1  1  1   1   1
    341:               0          0            0  1  1  1  1  1  1  1  1  1   1   1
    342:               1          0            0  1  1  1  1  1  1  1  1  1   1   1
         S12 S13 S14 S15 S16 S17 S18 m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12 m13 m14
      1:   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
      2:   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
      3:   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
      4:   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
      5:   0   0   0   0   0   0   0  1  0  0  0  0  0  0  0  0   0   0   0   0   0
     ---                                                                           
    338:   1   1   2   1   1   1   1 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1  -1  -1  -1  -1
    339:   1   1   1   2   1   1   1 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1  -1  -1  -1  -1
    340:   1   1   1   1   2   1   1 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1  -1  -1  -1  -1
    341:   1   1   1   1   1   2   1 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1  -1  -1  -1  -1
    342:   1   1   1   1   1   1   2 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1  -1  -1  -1  -1
         m15 m16 m17 m18
      1:   0   0   0   0
      2:   0   0   0   0
      3:   0   0   0   0
      4:   0   0   0   0
      5:   0   0   0   0
     ---                
    338:  -1  -1  -1  -1
    339:  -1  -1  -1  -1
    340:  -1  -1  -1  -1
    341:  -1  -1  -1  -1
    342:  -1  -1  -1  -1





```julia
# OLS
R"""
lm_table3 <- lm(normalized_trade_prime_valid ~ 0 + ., data = table3_data)
summary(lm_table3)
"""
```




    RObject{VecSxp}
    
    Call:
    lm(formula = normalized_trade_prime_valid ~ 0 + ., data = table3_data)
    
    Residuals:
         Min       1Q   Median       3Q      Max 
    -1.37812 -0.28260  0.00324  0.27485  1.35971 
    
    Coefficients:
                     Estimate Std. Error t value Pr(>|t|)    
    dist1           -3.102440   0.154903 -20.028  < 2e-16 ***
    dist2           -3.665941   0.106969 -34.271  < 2e-16 ***
    dist3           -4.033395   0.095713 -42.141  < 2e-16 ***
    dist4           -4.218077   0.153080 -27.555  < 2e-16 ***
    dist5           -6.064372   0.087005 -69.701  < 2e-16 ***
    dist6           -6.558933   0.097792 -67.070  < 2e-16 ***
    border           0.303564   0.137159   2.213 0.027645 *  
    common_language  0.510080   0.145505   3.506 0.000526 ***
    both_in_EU       0.035912   0.121613   0.295 0.767974    
    both_in_EFTA     0.536071   0.182563   2.936 0.003581 ** 
    S1               0.192558   0.149741   1.286 0.199471    
    S2              -1.161839   0.128054  -9.073  < 2e-16 ***
    S3              -3.335625   0.118827 -28.071  < 2e-16 ***
    S4               0.411561   0.141915   2.900 0.004010 ** 
    S5              -1.749550   0.121735 -14.372  < 2e-16 ***
    S6              -0.522466   0.129777  -4.026 7.22e-05 ***
    S7               1.281384   0.118952  10.772  < 2e-16 ***
    S8               2.352748   0.121609  19.347  < 2e-16 ***
    S9              -2.813521   0.122484 -22.971  < 2e-16 ***
    S10              1.781510   0.120437  14.792  < 2e-16 ***
    S11              4.198787   0.132413  31.710  < 2e-16 ***
    S12             -2.189319   0.120839 -18.118  < 2e-16 ***
    S13             -1.197687   0.149741  -7.998 2.87e-14 ***
    S14             -1.346152   0.129424 -10.401  < 2e-16 ***
    S15             -1.573180   0.126130 -12.473  < 2e-16 ***
    S16              0.303089   0.121268   2.499 0.012984 *  
    S17              0.009816   0.129869   0.076 0.939800    
    S18              1.374167   0.121654  11.296  < 2e-16 ***
    m1               0.236221   0.256161   0.922 0.357197    
    m2              -1.678415   0.203764  -8.237 5.75e-15 ***
    m3               1.120118   0.180023   6.222 1.67e-09 ***
    m4               0.688596   0.237671   2.897 0.004045 ** 
    m5              -0.505889   0.187633  -2.696 0.007416 ** 
    m6              -1.334488   0.207808  -6.422 5.36e-10 ***
    m7               0.218294   0.180352   1.210 0.227099    
    m8               0.998812   0.187305   5.333 1.93e-07 ***
    m9              -2.356411   0.189573 -12.430  < 2e-16 ***
    m10              0.070178   0.184252   0.381 0.703566    
    m11              1.584890   0.214620   7.385 1.56e-12 ***
    m12              1.004782   0.185301   5.422 1.22e-07 ***
    m13              0.066574   0.256161   0.260 0.795129    
    m14             -1.000409   0.207199  -4.828 2.21e-06 ***
    m15             -1.206780   0.198907  -6.067 3.97e-09 ***
    m16             -1.156611   0.186420  -6.204 1.85e-09 ***
    m17             -0.024864   0.208183  -0.119 0.905012    
    m18              0.816808   0.187422   4.358 1.81e-05 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Residual standard error: 0.4913 on 296 degrees of freedom
    Multiple R-squared:  0.9935,	Adjusted R-squared:  0.9925 
    F-statistic: 984.2 on 46 and 296 DF,  p-value: < 2.2e-16


​    



#### GLS Estimation

上述 OLS 所得残差，并将其扩展为矩阵，作为估计误差协方差的材料


```julia
R"res <- lm_table3$residuals"
@rget res # 在 Julia 中获得与 R 同名的变量

ee_Mat = res * res'
sum_σ² = diag(ee_Mat) |> mean
```




    0.20891654679896704



对 $\sigma_1^2 + \sigma_2^2$ 的估计结果大概是 $0.21$

然后估计 $\sigma_2^2$，关键是计算所有的对称国家对 $(n, i)$ 和 $(i, n)$ 在 `ee_Mat` 中交叉的行列坐标

把 `ee_Mat` 中这 342 个元素加起来求平均，就是 $\sigma_2^2$ 的估计值


```julia
country_pairs = DataFrame(
    hcat(index_n_valid, index_i_valid, 1:N^2-N), 
    ["n", "i", "row_index"]
)
first(country_pairs, 5) |> println 
```

    [1m5×3 DataFrame[0m
    [1m Row [0m│[1m n     [0m[1m i     [0m[1m row_index [0m
    [1m     [0m│[90m Int64 [0m[90m Int64 [0m[90m Int64     [0m
    ─────┼─────────────────────────
       1 │     1      2          1
       2 │     1      3          2
       3 │     1      4          3
       4 │     1      5          4
       5 │     1      6          5


对某一行的索引 row，求对应的进口国index(n)和出口国index(i)  
进出口关系反转，求得相应的行索引 col  

则在ee_Mat中，col列与row行的交叉处，协方差应为σ₂²  
找到所有的这种交叉处，对残差平方和取平均，就是我们估计的σ₂²  


```julia
"""
根据行号求相应的对称国家对在ee_Mat中行列坐标的函数
"""
function cross_indices(row)
    n, i = Matrix(subset(country_pairs, :row_index => ByRow(==(row))))[1, 1:2]
    col = subset(country_pairs, :n => ByRow(==(i)), :i => ByRow(==(n)))[1, :row_index]
    return row, col
end
```




    cross_indices




```julia
σ₂² = @pipe 1:size(country_pairs, 1) .|> cross_indices .|> ee_Mat[_...] |> mean
```




    0.05064992755973885




```julia
σ₁² = sum_σ² - σ₂²
```




    0.1582666192392282



有了 $\sigma_1^2$ 和 $\sigma_2^2$，就可以构建 $342 \times 342$ 的误差协方差矩阵 $\Omega$ 


```julia
# 构建 Ω
Ω = Matrix(I, N^2 - N, N^2 - N)*sum_σ²
for i ∈ 1:N^2-N
    Ω[cross_indices(i)...] = σ₂²
end
Ω
```




    342×342 Matrix{Float64}:
     0.208917  0.0       0.0       0.0       …  0.0       0.0       0.0
     0.0       0.208917  0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.208917  0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.208917     0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0       …  0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0       …  0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     ⋮                                       ⋱            ⋮         
     0.0       0.0       0.0       0.0       …  0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0       …  0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.0
     0.0       0.0       0.0       0.0          0.208917  0.0       0.0
     0.0       0.0       0.0       0.0       …  0.0       0.208917  0.0
     0.0       0.0       0.0       0.0          0.0       0.0       0.208917




```julia
# GLS estimation（代数运算），仍用 OLS 的数据框
@rget table3_data

Y = extract(table3_data, :normalized_trade_prime_valid)
X = extract(table3_data, Not(:normalized_trade_prime_valid))


estimate = inv(X'inv(Ω)X)X'inv(Ω)Y # 几乎就是数学公式，返回各系数估计值的向量
estimate_S19 = -sum(estimate[11:28]) 
estimate_m19 = -sum(estimate[29:46])
gls_estimate = [estimate[1:28]..., estimate_S19, estimate[29:46]..., estimate_m19]


var_estimate = inv(X'inv(Ω)X)
stand_error = diag(var_estimate) .|> sqrt
stand_error_S19 = var_estimate[11:28, 11:28] |> sum |> sqrt
stand_error_m19 = var_estimate[29:46, 29:46] |> sum |> sqrt
gls_stand_error = [stand_error[1:28]..., stand_error_S19, stand_error[29:46]..., stand_error_m19];
```


```julia
# Table III

R"""
country_table = $country_table
gls_estimate <- $gls_estimate
gls_stand_error <- $gls_stand_error

gls_parameters <- c(
  1:6 %>% str_c("$-\\theta d_{", ., "}$"),
  "$-\\theta b$", "$-\\theta l$", "$-\\theta e_1$", "$-\\theta e_2$",
  1:19 %>% str_c("$S_{", ., "}$"),
  1:19 %>% str_c("$-\\theta m_{", ., "}$")
)
variable_names <- c(
  "Distance [0, 375)", "Distance [375, 750)", "Distance [750, 1500)",
  "Distance [1500, 3000)", "Distance [3000, 6000)", "Distance [6000, maximum)",
  "Shared border", "Shared language", "Both in EEC/EU", "Both in EFTA",
  country_table$name %>% str_c("Source country: ", .),
  country_table$name %>% str_c("Destination country: ", .)
)
table3 <- data.table(
  variables = variable_names,
  parameters = gls_parameters,
  estimate = round(gls_estimate, 2),
  std_error = round(gls_stand_error, 2)
)
table3 %>%
  mutate(std_error = str_c("(", std_error, ")")) %>%
  set_colnames(c("Variable", "parameter", "est.", "s.e."))
"""
```




    RObject{VecSxp}
                                   Variable         parameter  est.   s.e.
     1:                   Distance [0, 375)  $-\\theta d_{1}$ -3.10 (0.16)
     2:                 Distance [375, 750)  $-\\theta d_{2}$ -3.66 (0.11)
     3:                Distance [750, 1500)  $-\\theta d_{3}$ -4.03  (0.1)
     4:               Distance [1500, 3000)  $-\\theta d_{4}$ -4.22 (0.16)
     5:               Distance [3000, 6000)  $-\\theta d_{5}$ -6.06 (0.09)
     6:            Distance [6000, maximum)  $-\\theta d_{6}$ -6.56  (0.1)
     7:                       Shared border      $-\\theta b$  0.30 (0.14)
     8:                     Shared language      $-\\theta l$  0.51 (0.15)
     9:                      Both in EEC/EU    $-\\theta e_1$  0.04 (0.13)
    10:                        Both in EFTA    $-\\theta e_2$  0.54 (0.19)
    11:           Source country: Australia           $S_{1}$  0.19 (0.15)
    12:             Source country: Austria           $S_{2}$ -1.16 (0.12)
    13:             Source country: Belgium           $S_{3}$ -3.34 (0.11)
    14:              Source country: Canada           $S_{4}$  0.41 (0.14)
    15:             Source country: Denmark           $S_{5}$ -1.75 (0.12)
    16:             Source country: Finland           $S_{6}$ -0.52 (0.12)
    17:              Source country: France           $S_{7}$  1.28 (0.11)
    18:             Source country: Germany           $S_{8}$  2.35 (0.12)
    19:              Source country: Greece           $S_{9}$ -2.81 (0.12)
    20:               Source country: Italy          $S_{10}$  1.78 (0.11)
    21:               Source country: Japan          $S_{11}$  4.20 (0.13)
    22:         Source country: Netherlands          $S_{12}$ -2.19 (0.11)
    23:         Source country: New Zealand          $S_{13}$ -1.20 (0.15)
    24:              Source country: Norway          $S_{14}$ -1.35 (0.12)
    25:            Source country: Portugal          $S_{15}$ -1.57 (0.12)
    26:               Source country: Spain          $S_{16}$  0.30 (0.12)
    27:              Source country: Sweden          $S_{17}$  0.01 (0.12)
    28:      Source country: United Kingdom          $S_{18}$  1.37 (0.12)
    29:       Source country: United States          $S_{19}$  3.98 (0.14)
    30:      Destination country: Australia  $-\\theta m_{1}$  0.24 (0.27)
    31:        Destination country: Austria  $-\\theta m_{2}$ -1.68 (0.21)
    32:        Destination country: Belgium  $-\\theta m_{3}$  1.12 (0.19)
    33:         Destination country: Canada  $-\\theta m_{4}$  0.69 (0.25)
    34:        Destination country: Denmark  $-\\theta m_{5}$ -0.51 (0.19)
    35:        Destination country: Finland  $-\\theta m_{6}$ -1.33 (0.22)
    36:         Destination country: France  $-\\theta m_{7}$  0.22 (0.19)
    37:        Destination country: Germany  $-\\theta m_{8}$  1.00 (0.19)
    38:         Destination country: Greece  $-\\theta m_{9}$ -2.36  (0.2)
    39:          Destination country: Italy $-\\theta m_{10}$  0.07 (0.19)
    40:          Destination country: Japan $-\\theta m_{11}$  1.59 (0.22)
    41:    Destination country: Netherlands $-\\theta m_{12}$  1.00 (0.19)
    42:    Destination country: New Zealand $-\\theta m_{13}$  0.07 (0.27)
    43:         Destination country: Norway $-\\theta m_{14}$ -1.00 (0.21)
    44:       Destination country: Portugal $-\\theta m_{15}$ -1.21 (0.21)
    45:          Destination country: Spain $-\\theta m_{16}$ -1.16 (0.19)
    46:         Destination country: Sweden $-\\theta m_{17}$ -0.02 (0.22)
    47: Destination country: United Kingdom $-\\theta m_{18}$  0.81 (0.19)
    48:  Destination country: United States $-\\theta m_{19}$  2.46 (0.25)
                                   Variable         parameter  est.   s.e.




#### 保存估计结果

TABLE III 的估计值对于下一步的 simulation 非常重要。

1. Source country dummy 的估计值可用于计算各国技术水平
2. 由其他虚拟变量系数的估计值可计算双边障碍 $-\theta \ln(d_{ni})$ 的拟合值。将此拟合值命名为 dni_measure，作为 simulation 阶段 $d_{ni}$ 的数据来源。


```julia
# 由 Table III 估计出的 48 个系数（gls_estimate）可计算拟合值: d_measure
barrier_dummy = hcat(Matrix(geography_dummy_valid), destination_dummy[valid_index,:]) # 包含dist1
barrier_estimate =gls_estimate[[1:10;30:48]]
barrier_sum = barrier_dummy * barrier_estimate
```




    342-element Vector{Float64}:
     -6.32308562884616
     -6.32308562884616
     -5.811442086342885
     -6.32308562884616
     -6.32308562884616
     -6.32308562884616
     -6.32308562884616
     -6.32308562884616
     -6.32308562884616
     -5.828453822321084
     -6.32308562884616
     -3.286113016210577
     -6.32308562884616
      ⋮
     -3.605517711163891
     -3.605517711163891
     -3.605517711163891
     -3.605517711163891
     -4.100149517688967
     -3.605517711163891
     -3.5885059751856927
     -3.605517711163891
     -3.605517711163891
     -3.605517711163891
     -3.605517711163891
     -3.0938741686606166




```julia
# 为了后续使用的方便，将其变形为矩阵
dni_measure = zeros(N, N)
for row in 1:342
    n, i = Matrix(subset(country_pairs, :row_index => ByRow(==(row))))[1, 1:2]
    dni_measure[n, i] = barrier_sum[row]
end
dni_measure
```




    19×19 Matrix{Float64}:
      0.0      -6.32309  -6.32309  -5.81144   …  -6.32309  -5.81144  -5.81144
     -8.23702   0.0      -5.34225  -7.74239      -5.1748   -5.71169  -7.74239
     -5.43925  -2.54448   0.0      -4.94462      -2.91392  -1.94204  -4.94462
     -5.35851  -5.37552  -5.37552   0.0          -5.37552  -4.86387  -2.16785
     -7.06717  -4.1724   -4.13555  -6.57254      -3.60681  -4.13555  -6.57254
     -7.89396  -4.83175  -5.36864  -7.39933   …  -3.60083  -5.36864  -7.39933
     -6.34016  -3.44539  -2.03542  -5.84553      -3.81483  -2.84296  -5.84553
     -5.55831  -1.29043  -2.3308   -5.06368      -2.66355  -2.62669  -5.06368
     -8.9161   -6.39077  -6.35392  -8.42147      -6.39077  -6.35392  -8.42147
     -6.48756  -3.2969   -3.55594  -5.99293      -3.96223  -3.92538  -5.99293
     -4.47917  -4.47917  -4.47917  -4.9738    …  -4.47917  -4.47917  -4.9738
     -5.55555  -2.66078  -1.76245  -5.06092      -2.66078  -2.05834  -5.06092
     -3.45576  -6.49273  -6.49273  -5.98109      -6.49273  -5.98109  -5.98109
     -7.56032  -4.49811  -4.66556  -7.06569      -3.26719  -4.66556  -7.06569
     -7.76592  -5.24059  -5.20374  -7.27128      -5.42479  -5.20374  -7.27128
     -7.71491  -5.18958  -5.15273  -7.22028   …  -5.37379  -5.15273  -7.22028
     -6.58411  -3.52189  -4.05878  -6.08947       0.0      -4.05878  -6.08947
     -5.23371  -3.22002  -2.24815  -4.73908      -3.22002   0.0      -4.73908
     -3.58851  -3.60552  -3.60552  -0.397847     -3.60552  -3.09387   0.0




```julia
save("../data/table3-output.jld", "table3_estimate", gls_estimate, "dni_measure", dni_measure) 
```


```julia

```
