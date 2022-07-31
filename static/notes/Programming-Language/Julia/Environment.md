[TOC]

# Environment

## 启动加载

`$HOME/.julia/config` 目录中可以建立 `startup.jl` 文件，存放每次 REPL 启动时要运行的代码

## REPL

### Help 模式



按 `?` 进入帮助模式

### Pkg 模式

按 `]` 进入 pkg 模式 `add 包名` 即可安装包



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







### 程序运行时间

1. `@time`
2. BenchmarkTools 包的 `@btime`



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

