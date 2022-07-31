[TOC]

# IO

## Console

### Input

`readline()`从 REPL 接受输入

### Output

对象长度太长时，自动折叠；如果非要显示全，使`show(xxx, allrows=true)`

`print()`不自动换行，`println()`自动换行

`@show x y` 的作用与 `println(x, y)` 相似。这个宏更适合调试时使用。

> 但`print(x, y)`的打印结果是 `"$x$y"`，而 `@show x y`的打印形式为 `"x = $x\ny = $y"`

`TabularDisplay.displaytable(stdout, v::AbstractVector{T}; index = true)`，完整展示一个向量（不论它多长），带序号且自动排版成表格

## 文件读取

![read_packages](img/read_packages.png)

### .txt

`open(path)`，返回 IOStream

`readline()`

`write()`

`close(stream::IOStream)`



覆盖 `"w"`

追加写 `"a+"`

```julia
open("./data/sample.txt", "a+") do io
  write(io, "Hello World again\n")
end

# 或

f = open("./data/sample.txt", "a+")
write(f, "Hello World again\n")
close(f)
```



```julia
# 读写函数可以直接以 path 为参数
readline("sample.txt") # 一次只能读一行
write("sample.txt", "Hello World")
```

#### 常用

`read(io, String)`

`read(filename, String)`

### .csv

![csv.jl](img/csv.jl.png)

```julia
using CSV
using DataFrames
```

#### `CSV.read(path, DataFrame)`

#### `DataFrame(CSV.File(path))`

`DataFrame(CSV.File(path; missingstring="NA"))`

#### `CSV.write(path, x)`



### .json

```julia
using JSON
```

#### `JSON.parse()`/`JSON.parsefile()`

```julia
julia> JSON.parse("{\"a_number\" : 5.0, \"an_array\" : [\"string\", 9]}")
Dict{String, Any} with 2 entries:
  "an_array" => Any["string", 9]
  "a_number" => 5.0

julia> constant_values = JSON.parsefile("./data/scalar.json")
Dict{String, Any} with 3 entries:
  "theta" => Any[3.6, 8.28, 12.86]
  "N"     => 19
  "beta"  => 0.21221

julia> θs = constant_values["theta"]
3-element Vector{Any}:
  3.6
  8.28
 12.86

julia> N = constant_values["N"]
19

julia> β = constant_values["beta"]
0.21221
```

解析时的类型对应规则：

- Object becomes `Dict`
- array becomes `Vector`
  - jSON.jl 无法解析多维数组，所以**矩阵等数据形式最好不要保存在 .json 中**
  - .json 文件适合保存常量，.csv 适合保存矩阵和数据框
- number becomes `Int64` or `Float64`
- boolean becomes `Bool`
- null becomes `nothing::Void`

#### `JSON.json()`

serializes a Julia object into a Julia `String` containing JSON

```julia
julia> JSON.json([1:10...]) # 或 JSON.json(1:10)
"[1,2,3,4,5,6,7,8,9,10]"
```

#### `JSON.print()`

```julia
julia> JSON.json(Dict(:a => :b, :c => [1, 2, 3.0], :d => nothing)) |> println
{"c":[1.0,2.0,3.0],"a":"b","d":null}

julia> JSON.print(Dict(:a => :b, :c => :d), indent = 2) # pretty 输出
{       
  "a": "b",
  "c": "d"
}
```

### .jld

Julia 本身的数据储存文件，就像 R 的 .rda

`using JLD` 后使用 `save()` 和 `load()`

```julia
julia> A = ones(2, 2)
2×2 Matrix{Float64}:
 1.0  1.0
 1.0  1.0

julia> b = "a_string"
"a_string"

julia> using JLD

julia> save("./data/mydata.jld", "var_A", A, "var_b", b) 
# save("mydata.jld") 可以储存工作区中的所有变量

julia> D = load("./data/mydata.jld") 
Dict{String, Any} with 2 entries:
  "var_b" => "a_string"
  "var_A" => [1.0 1.0; 1.0 1.0]

# 提取文件中一个变量
# b = load("mydata.jld", "var_b")
```

### .mat

```julia
using MAT
input = matread("tensor.mat")
tensor = input["tensor"]
```





## 数据库

## HTTP

```julia
using Downloads
url = "https://raw.githubusercontent.com/JuliaDataScience/JuliaDataScience/main/Project.toml"
my_file = Downloads.download(url)
readlines(my_file)[1:4]
```

更复杂的 HTTP 交互参考 HTTP.jl 包



