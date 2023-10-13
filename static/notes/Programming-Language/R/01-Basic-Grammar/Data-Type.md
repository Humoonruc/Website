[TOC]

## Type

### 基本数据类型

- numeric
  - integer
  - double
- logical
- character
- NA 缺失值 not available
  - 对于 R 中大多数函数，NA 具有传染性，即 NA 参与的运算结果会返回 NA
- NULL 空值 
- NaN 并非一个数 not a number
- Inf 无穷大

#### R 中无标量

装载数据的对象均为向量，即使标量也视为长度为 1 的向量。因此 type 一致的原子向量的 type 也就是其装载的元素的 type，用 `typeof()` 查看

### 查看数据类型

- `typeof(x)/mode(x)`，查看对象的数据类型

若对象为homogeneous data types，则返回元素的数据类型，如 integer, double, character, logical；若为异质性的列表或数据框，则返回 list.

`typeof()` 比 `mode()` 返回的更精细一些

```R
a <- 1:5
mode(a)
# [1] "numeric"
typeof(a)
# [1] "integer"
```
