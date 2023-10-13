

# Module

## 包



|                                          |                            |
| ---------------------------------------- | -------------------------- |
| List installed packages (human-readable) | `Pkg.status()`             |
| Update all packages                      | `Pkg.update()`             |
| Install package                          | `Pkg.add("PackageName")`   |
| Rebuild package                          | `Pkg.build("PackageName")` |
| Use package (after install)              | `using PackageName`        |
| Remove package                           | `Pkg.rm("PackageName")`    |



```shell
julia> Pkg.status()
Status `C:\Users\humoo\.julia\environments\v1.8\Project.toml`
  [336ed68f] CSV v0.10.9
  [49dc2e85] Calculus v0.5.1
  [a93c6f00] DataFrames v1.5.0
  [60bf3e95] GLPK v1.1.1
  [b6b21f68] Ipopt v1.2.0
  [682c06a0] JSON v0.21.3
  [4076af6c] JuMP v1.9.0
  [2621e9c9] MadNLP v0.6.0
  [b98c9c47] Pipe v1.3.0
  [f0f68f2c] PlotlyJS v0.18.10
  [91a5bcdd] Plots v1.38.8
  [438e738f] PyCall v1.95.1
  [274fc56d] PythonPlot v1.0.2
  [6f49c342] RCall v0.13.14
  [37e2e46d] LinearAlgebra
  [10745b16] Statistics
```



## 文件

### 导入语法

如果将程序分散在不同文件中，要在主脚本中引入其他 .jl 脚本，使用

`include(path)`

一个 module 可以分散到多个脚本中，一个脚本也可以有多个 module

前者如

```julia
module Foo
    include("file1.jl")
    include("file2.jl")
end
```

后者如

```julia
module Normal
  include("mycode.jl")
end 

module Testing
  include("safe_operators.jl")
  include("mycode.jl")
end
```

### 调用模块中的变量

module 中的对象，

（1）如果有一行 `export xxx`

（2）在主文件使用 `using/import .ModuleName` 之后

就可以直接使用其中的变量了

```julia
include("./toolkit/HandleDF.jl")
using .HandleDF # 引入模块中所有导出的变量
using .HandleDF:add # 引入其中的部分变量 

add2(1, 2)
```



| 语法                 | 被导入的变量名                           |
| -------------------- | ---------------------------------------- |
| `using .HandleDF`    | a<br />b<br />HandleDF.a<br />HandleDF.b |
| `using .HandleDF:a`  | a                                        |
| `import .HandleDF`   | HandleDF.a<br />HandleDF.b               |
| `import .HandleDF:a` | a                                        |
| `import .HandleDF.a` | a                                        |

将特定名称引入当前命名空间确实是大多数用例的最佳选择  
