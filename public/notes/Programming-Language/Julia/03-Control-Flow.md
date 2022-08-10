[TOC]

# Control Flow

## 复合表达式 `begin...end`

**begin ... end** 表达式可以按顺序计算若干子表达式，并返回最后一个子表达式的值

因为这些是非常简短的表达式，它们可以简单地被放到一行里

```julia
julia> z = begin
           x = 1
           y = 2
           x + y
       end
3

julia> z = begin x = 1; y = 2; x+y end
3
```



`;` 链

```julia
julia> z = (x = 1; y = 2; x + y)
3
```

## Condition

### if-elseif-else-end

#### 尽量避免嵌套

尽早 return，让大段代码**不要陷入过深的层级**，多用单行

```julia
function rev(arr)
  if length(arr) != 0
    ...
    ...
    ... # 一堆逻辑
  else
    return 0
  end
end
```

改为

```julia
function rev(arr)
  if length(arr) == 0 return 0 end
  
  ...
  ...
  ... # 一堆逻辑
end
```

甚至

```julia
function rev(arr)
  length(arr) == 0 && return 0
  
  ...
  ...
  ... # 一堆逻辑
end
```



#### 占位代码

```julia
if x < 0
  # TODO: ...
end
```

### condition ? expr1 : expr2

注意 `?` 和 `:` 两边强制的空格

### 短路运算和链式比较

- 在表达式 `a && b` 中，子表达式 `b` 仅当 `a` 为 `true` 的时候才会被执行，如果 a 为 false 则直接返回 false。
- 在表达式 `a || b` 中，子表达式 `b` 仅在 `a` 为 `false` 的时候才会被执行，如果 a 为 true ，直接返回 a。



最简单的 if 表达式的一种简写形式：`condition && do`

```julia
if n < 0
  return false
end

n < 0 && return false
```

这种写法的必要性：Julia 条件语句中的 `end` 太累赘了

这种写法的可行性：Julia 的任何表达式都有返回值





## Loop

### for…in

### while

### break

### continue

### 嵌套循环的合并

多个嵌套的 for 循环可以合并到一个外部循环，可以用来创建其迭代对象的笛卡尔积：

```julia
julia> for i in 1:2, j in 3:4
           println((i, j))
       end
(1, 3)
(1, 4)
(2, 3)
(2, 4)
```

但是在一个循环里面使用 break 语句则会跳出整个嵌套循环，不仅仅是内层循环。



## Task（协程）：yieldto

`Channel()` 创建任务

`put!()` 将数据存储在 Channel 对象中

`take!() `从中读取值



## 异常处理

`try…catch…finally…end`

```julia
try
    fin = open("not_exist_file.txt")
catch exc
    println("Something went wrong: $exc")
end
```



```julia
f = open("output.txt")
try
    line = readline(f)
    println(line)
    ... # 无论中间出现什么错误
    ...
finally
    close(f)
end
```



`error(string)` 生成 ErrorException，错误消息为 string
