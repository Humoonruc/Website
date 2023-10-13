## Arithmetic

### Global constants

`π`

`ℯ` **\euler TAB**

`im` 虚数单位 $i$

```julia
	using Base.MathConstants # 有更多数学常数
```



### 算数函数

| 函数             | 描述                                                |
| :--------------- | :-------------------------------------------------- |
| `sqrt(x)`, `√x`  | `x` 的平方根                                        |
| `cbrt(x)`, `∛x`  | `x` 的立方根                                        |
| `hypot(x,y)`     | 当直角边的长度为 `x` 和 `y`时，直角三角形斜边的长度 |
| `exp(x)`         | 自然指数函数在 `x` 处的值                           |
| `expm1(x)`       | 当 `x` 接近 0 时的 `exp(x)-1` 的精确值              |
| `ldexp(x,n)`     | `x*2^n` 的高效算法，`n` 为整数                      |
| `log(x)`         | `x` 的自然对数                                      |
| `log(b,x)`       | 以 `b` 为底 `x` 的对数                              |
| `log2(x)`        | 以 2 为底 `x` 的对数                                |
| `log10(x)`       | 以 10 为底 `x` 的对数                               |
| `log1p(x)`       | 当 `x`接近 0 时的 `log(1+x)` 的精确值               |
| `exponent(x)`    | `x` 的二进制指数                                    |
| `significand(x)` | 浮点数 `x` 的二进制有效数（也就是尾数）             |



| 函数            | 描述                                             |
| :-------------- | :----------------------------------------------- |
| `abs(x)`        | `x` 的模                                         |
| `abs2(x)`       | `x` 的模的平方                                   |
| `sign(x)`       | 表示 `x` 的符号，返回 -1，0，或 +1               |
| `signbit(x)`    | 表示符号位是 true 或 false                       |
| `copysign(x,y)` | 返回一个数，其值等于 `x` 的模，符号与 `y` 一致   |
| `flipsign(x,y)` | 返回一个数，其值等于 `x` 的模，符号与 `x*y` 一致 |



| 函数                                              | 描述                                                         |
| :------------------------------------------------ | :----------------------------------------------------------- |
| `div(x,y, r::RoundingMode=RoundToZero)`, `x÷y`    | 截断除法，无论任何类型相除的结果都会省略小数部分，剩下整数部分（向 0 靠近） |
| `fld(x,y)`，等价于 `floor(Int, x/y)`              | 向下取整除法（向 -Inf 靠近）<br />当 x 与 y 一正一负且不能整除时，`floor()` 与 `div()` 的结果不同 |
| `cld(x,y)`，等价于 `ceil(Int, x/y)`               | 向上取整除法                                                 |
| `rem(x,y, r::RoundingMode=RoundToZero)`，` x % y` | 取余，与 `div()` 配对；满足 `x == div(x,y)*y + rem(x,y)`；符号与 `x` 一致 |
| `mod(x,y)`                                        | 取模，与 `fld()` 配对；满足 `x == fld(x,y)*y + mod(x,y)`；符号与 `y` 一致<br />当 x 与 y 一正一负且不能整除时，取余与取模的结果不同 |
| `mod1(x,y)`                                       | 偏移 1 的 `mod`；若 `y>0`，则返回 `r∈(0,y]`，若 `y<0`，则 `r∈[y,0)` 且满足 `mod(r, y) == mod(x, y)` |
| `mod2pi(x)`                                       | 对 2pi 取模；`0 <= mod2pi(x) < 2pi`                          |
| **`divrem(x,y)`**                                 | 返回 `(div(x,y),rem(x,y))`，很高效                           |
| `fldmod(x,y)`                                     | 返回 `(fld(x,y),mod(x,y))`                                   |
| `gcd(x,y...)`                                     | `x`, `y`,... 的**最大公约数**                                |
| `lcm(x,y...)`                                     | `x`, `y`,... 的**最小公倍数**                                |

### 三角函数

接收弧度值