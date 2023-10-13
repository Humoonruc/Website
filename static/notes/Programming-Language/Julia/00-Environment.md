[TOC]

# Environment

## 启动加载

`$HOME/.julia/config` 目录中可以建立 `startup.jl` 文件，存放每次 REPL 启动时要运行的代码

在 Windows 系统中，`$HOME` 就是 `C:/Users/用户名`

## REPL

 REPL (Read-Evaluate-Print-Loop),



|                                        |                                              |
| -------------------------------------- | -------------------------------------------- |
| 帮助模式                               | `?` on empty line                            |
| See all places where `func` is defined | `apropos("func")`                            |
| 包管理模式                             | `]` on empty line. 然后`add 包名` 即可安装包 |
| Command line mode                      | `;` on empty line                            |
| Exit special mode / Return to REPL     | [Backspace] on empty line                    |
| Exit REPL                              | `exit()` or [Ctrl] + [D]                     |
|                                        |                                              |
| 获得上一步计算的结果                   | `ans`                                        |
| Interrupt execution                    | [Ctrl] + [C]                                 |
| Clear screen                           | [Ctrl] + [L]                                 |
| Run script                             | `include("filename.jl")`                     |



## 操作系统

`Sys.WORD_SIZE()` 返回**Int32**或**Int64**，表示系统位数

### 调用 Shell

```julia
julia> mycommand = `echo hello`
`echo hello`

julia> typeof(mycommand)
Cmd

julia> run(mycommand);
hello

julia> read(`echo hello`, String)
"hello\n"

julia> readchomp(`echo hello`)
"hello"
```

反引号``括起来的内容为 Cmd 类型的对象

`run(cmd)` 运行

`read(cmd, String)`可以获取其输出

对于 Cmd 类型的对象，可以用 `$` 插值，就像字符串一样

```julia
run(`python test.py`)

const RscriptPath = "C:\\Program Files\\R\\R-4.2.1\\bin\\Rscript.exe"
run(`$RscriptPath test.R`)
```

```julia
filename = "output.txt"
cmd = `md5 $filename`
res = read(cmd, String)
```

### 记录程序运行时间

1. `@time`
2. BenchmarkTools 包的 `@btime` 更准确

```julia
julia> A = rand(3,3)
3×3 Matrix{Float64}:
 0.639429  0.531428  0.915683
 0.457444  0.221791  0.713925
 0.811219  0.263119  0.622511

julia> inv(A)
3×3 Matrix{Float64}:
 -0.710358  -1.28268   2.51594
  4.20089   -4.91984  -0.536994
 -0.849907   3.751    -1.44525

julia> @time inv(A)
  0.000019 seconds (4 allocations: 1.859 KiB)
3×3 Matrix{Float64}:
 -0.710358  -1.28268   2.51594
  4.20089   -4.91984  -0.536994
 -0.849907   3.751    -1.44525

julia> @btime inv(A)
  521.579 ns (4 allocations: 1.86 KiB)
3×3 Matrix{Float64}:
 -0.710358  -1.28268   2.51594
  4.20089   -4.91984  -0.536994
 -0.849907   3.751    -1.44525

julia> @btime inv($A) # $表示其后的变量 A is "pre-computed" before the benchmarking begins
  486.082 ns (4 allocations: 1.86 KiB)
3×3 Matrix{Float64}:
 -0.710358  -1.28268   2.51594
  4.20089   -4.91984  -0.536994
 -0.849907   3.751    -1.44525
```



3. BenchmarkTools 包的 `@benchmark` 多次运行代码段统计平均时长

```julia
function estimate_pi(n) # 蒙特卡洛方法估计 pi
    n_circle = 0
    for i in 1:n
        x = 2*rand() - 1 # x,y的范围均为[-1, 1]
        y = 2*rand() - 1
        if sqrt(x^2 + y^2) <= 1 # 是否在原点为圆心、半径为1的圆内
           n_circle += 1
        end
    end
    return 4*n_circle/n # 落在圆内点的比例应为圆与正方形的的面积之比，即pi/4
end
```

```shell
julia> using BenchmarkTools

julia> n = 10000000
10000000

julia> @benchmark estimate_pi(n) # 运行了56轮，每轮都撒了10000000个点
BenchmarkTools.Trial: 56 samples with 1 evaluation.
 Range (min … max):  86.735 ms … 94.346 ms  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     89.119 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):   89.358 ms ±  1.659 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

                 ▁   ▃   █                                     
  ▄▁▄▇▁▇▇▁▁▄▄▄▄▄▄█▄▄▁█▄▄▁█▇▇▄▁▁▁▄▄▁▁▇▇▁▇▁▇▄▁▄▁▁▁▁▄▄▁▇▁▁▁▁▄▄▁▄ ▁
  86.7 ms         Histogram: frequency by time        92.7 ms <

 Memory estimate: 16 bytes, allocs estimate: 1.
```

### 显示 for 循环的进度条

ProgressMeter.jl

```julia
julia> using ProgressMeter

julia> @showprogress 1 "Computing..." for i in 1:50 # 每1秒刷新一次
           sleep(0.1)
       end
Computing... 20%|███████▊                               |  ETA: 0:00:04


julia> x, n = 1 , 10;

julia> p = Progress(n);

julia> for iter in 1:10
           x *= 2
           sleep(0.5)
           ProgressMeter.next!(p; showvalues = [(:iter, iter), (:x, x)])
       end
Progress: 100%|█████████████████████████████████████████| Time: 0:00:10
  iter:  10
  x:     1024
```





## File System

Julia 核心库 Base 的 Filesystem 模块

[Filesystem · The Julia Language](https://docs.julialang.org/en/v1/base/file/)

| 函数             | 描述                                                         |
| :--------------- | :----------------------------------------------------------- |
| cd(path)         | 切换当前目录                                                 |
| pwd()            | 获取当前目录                                                 |
| readdir(path)    | 返回当前目录的文件与目录列表                                 |
| mkdir()          | 创建目录                                                     |
| abspath(path)    | 获取绝对路径。                                               |
| joinpath(..)     | 从参数中组装路径，以在不同系统上通用                         |
| isdir(path)      | 判断 path 是否是一个目录                                     |
| isfile(path)     | 判断 path 是否是一个文件                                     |
| ispath(path)     | 判断文件或目录是否存在                                       |
| cp()             | 复制文件                                                     |
| mv()             | 移动文件                                                     |
| splitdir(path)   | 将路径按层级切分，返回 Tuple{String}                         |
| splitdrive(path) | Windows 上将路径拆分为驱动器号部分和路径部分，在 Unix 系统上，第一个组件始终是空字符串。 |
| splitext(path)   | 如果路径的最后一个组件包含一个点，则将路径拆分为点之前的所有内容以及包括点和点之后的所有内容。 否则，返回一个未修改的参数和空字符串的元组。 |
| expanduser(path) | 将路径开头的波浪字符 ～ 替换为当前用户的主目录。             |
| normpath(path)   | 规范化路径，删除 "." 和 ".." 目录                            |
| realpath(path)   | 如果符号链接来规范化路径，并删除 "." 和 ".." 目录            |
| homedir()        | 获取当前用户的主目录。                                       |
| dirname(path)    | 获取路径参数 path 的目录部分                                 |
| basename(path)   | 获取路径参数 path 的文件名部分。                             |
| walkdir(dir)     | 返回递归的 tuple `(root, dirs, files)`                       |



```julia
root = dirname(@__FILE__) # 获取脚本文件 .jl 所在目录的路径
joinpath(root, "my_script.jl")
joinpath(root, "data", "my_data.csv")
```



```julia
map(abspath, readdir(dir_path)) # 返回某目录下所有文件和目录的绝对路径
```



`walkdir(dir)` 返回递归的 `(root, dirs, files)`

```julia
for (root, dirs, files) in walkdir(".")
    println("Directories in $root")
    for dir in dirs
        println(joinpath(root, dir)) # path to directories
    end
    println("Files in $root")
    for file in files
        println(joinpath(root, file)) # path to files
    end
end
```

