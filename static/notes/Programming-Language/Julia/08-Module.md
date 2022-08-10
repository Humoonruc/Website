

# Module

## 包

#### `Pkg.status()`/`Pkg.installed()`

已安装的包

#### `Pkg.update()`

升级所有包Module

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
