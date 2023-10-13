## 线性代数

### 基本矩阵运算

`+` 加，`-` 减，两个 size 相同的矩阵对应元素加减**可以省略 `.`**

`.+`/`.-`，数组与标量的加减必须要用广播语法

`*` 矩阵乘法

`.*` 对应元素相乘（哈达马积），包括数乘（可以省略`.*` ）

```julia
julia> a = [1, 2]
2-element Vector{Int64}:
 1
 2

julia> 3a
2-element Vector{Int64}:
 3
 6
```



`⊗` (`\otimes<TAB>`) 克罗内克积 `using Kronecker`

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



### LinearAlgebra.jl

```julia
using LinearAlgebra
```



#### `dot(x, y)`/`\cdot<TAB>` 点积



#### `norm()`  模长



#### `I([k])` 

表示k 阶单位阵的一个对象，可以参与各种矩阵运算

```julia
julia> a = [1 2;3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> a - I
ERROR: UndefVarError: I not defined
Stacktrace:
 [1] top-level scope
   @ REPL[21]:1

julia> using LinearAlgebra

julia> a - I
2×2 Matrix{Int64}:
 0  2
 3  3
```



`Matrix{T}(I, m, n)`, `m` 行 `n` 列的主对角线为 1 的矩阵



#### 主对角线

`diag(A)` 提取主对角线元素

`diagm(Vector)` 由 Vector 构建对角矩阵

```julia
A = diagm(ones(Int, 3))
```



#### `UpperTriangular(A)`/`LowerTriangular(A)` 上/下三角矩阵



#### `det()`/`rank()`/`tr()`



#### 特征值和特征向量

`eigvals()`/ `eigvecs()`

`eigen(A)` 返回对矩阵特征值和特征向量的封装，用`.`提取



#### `cholesky()`

### 稀疏矩阵 SparseArrays.jl

`sparse`, `SparseVector`, `SparseMatrixCSC`



