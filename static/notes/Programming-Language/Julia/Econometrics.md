# 统计和计量

## GML 包

Linear and generalized linear models



这个包似乎没有用 . 表示其余所有变量的语法，如果变量很多， formula 写起来很费劲。可能需要用到 meta programming 的表达式，略麻烦。


```julia
using DataFrames
using GLM



a = 1:10
b = collect(2:2:20) + randn(10) / 5
c = randn(10)
df = DataFrame(; a, b, c)


fm = @formula(b ~ 0 + a + c)
linearRegressor = lm(fm, df)

r2(linearRegressor)
coef(linearRegressor)
stderror(linearRegressor)

print(linearRegressor)

# predict(linearRegressor, test)
# predict(linearRegressor, train)
```