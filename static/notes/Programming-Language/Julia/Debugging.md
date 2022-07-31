[TOC]

# Debugging

## Error

### 三种错误

1. syntax error: 程序无法被正确解析
2. runtime error / exception: 程序运行时检测到的错误，如数据类型不符等
3. semantic error: 程序无法得到程序员预想的结果

### 报错信息

错误类型

出现位置

## 设计/调试技巧

### `@assert` 检查

`@assert cond [text]` 检测一个表达式，false 则抛出一个异常。若有错误，尽早曝出

```julia
@assert 1==2 "not equal"
```



而且，对于很多错误，**摘要检查和类型检查足够**。打印全部数据或返回值可能过于繁冗。

### 在函数体首尾打印信息

即使在 Jupyter 中，也不要过于依赖通过细碎分块查看中间结果，而应多写一些输出中间计算结果的代码

```julia
function factorial(n)
    space = " "^(4n) # 栈的第n层，缩进4n个空格
    println(space, "factorial ", n)
    if n == 0
        println("returning 1")
        return 1
    else
        result = n * factorial(n - 1)
        println(space, "returning ", result)
        return result
    end
end

factorial(4)
```

打印结果为：

```
                factorial 4
            factorial 3
        factorial 2
    factorial 1
factorial 0
returning 1
    returning 1
        returning 2
            returning 6
                returning 24
```

### Incremental Development

一点一点地实现功能，逐渐导入全部数据（开始可以只导入一部分），用 `@show` 打印中间变量

```julia
function distance(x₁, y₁, x₂, y₂)
    dx = x₂ - x₁
    dy = y₂ - y₁
    @show dx dy
    0.0
end
distance(0, 0, 3, 4)


function distance(x₁, y₁, x₂, y₂)
    dx = x₂ - x₁
    dy = y₂ - y₁
    d² = dx^2 + dy^2
    @show d²
    0.0
end
distance(0, 0, 3, 4)


function distance(x₁, y₁, x₂, y₂)
    dx = x₂ - x₁
    dy = y₂ - y₁
    d² = dx^2 + dy^2
    √d²
end
distance(0, 0, 3, 4)
```

`@show`的打印语句对调试很有用，但不会存在于最终代码中。由于其特性，往往被称为脚手架（scaffolding）

### Data Encapsulation

频繁修改全局变量是不安全的，实践中可以

- 首先用读写全局变量的函数实现功能
- 将全局变量封装为一个 struct 的字段
- 把前述函数改写为一个方法，接收这个新对象作为参数

这样，程序中（或调试过程中）万一存在一些对全局变量的随意改动，就大概率不会影响程序最终的输出





## Unit Testing

### Test 包

`@testset` 检测一串返回 Bool 的表达式

`@test` 检测一个返回 Bool 的表达式

```julia
using Test

@test sqrt(4) == 2

@testset "ArithmeticSum" begin
    @test ArithmeticSum(1,1,14) == SlowSum(1,1,14)
    @test ArithmeticSum(5,1,10) == SlowSum(5,1,10)
    @test ArithmeticSum(2,3,14) == SlowSum(2,3,14)
end
```

