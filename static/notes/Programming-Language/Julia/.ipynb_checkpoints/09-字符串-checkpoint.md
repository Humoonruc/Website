[TOC]

# 09 字符串

- 传统语言的缺点
  - 很多编程语言因为历史原因，对字符串并没有很好地支持
  - 对于非英语系的国家来说，更普遍的场景是需要对ASCII码表中128个字符之外的Unicode字符进行处理，这是包括Python等流行语言都捉襟见肘的地方

- Julia 的优势
  - Julia自设计之初，便从根本上提供了对多语言编码的支持，同时还兼容了类C风格的字符串操作方式

## Char

### 构造

字符的类型为 `Char`，父类型为 `AbstractChar`，形式为一对单引号 `'x'`，且其中只能有一个字符

```julia
julia> typeof('x')
Char

julia> 'x'
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)

# 除了提示该字符的 Unicode 码值（16进制）外，还告知其在字符集中的分类
julia> '￥'
'￥': Unicode U+FFE5 (category Sc: Symbol, currency)
```

也可以用 `Char(数字)` 创建字符

```julia
julia> Char(0x78)
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)

julia> Char(120) # 10进制的120，对应16进制的78
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)

julia> Int('x')
120
```

### 运算

字符之间的四则运算仅支持减法，返回二者编码之间的距离

```julia
julia> 'x' - 'a'
23

julia> 'x' - 23
'a': ASCII/Unicode U+0061 (category Ll: Letter, lowercase)

julia> 'A' + 1
'B': ASCII/Unicode U+0042 (category Lu: Letter, uppercase)
```

### 判断分类

`isletter(c::AbstractChar)` 是否在 letter 类中

`isascii(c::Union(AbstractChar, AbstractString))` Char 是否在 ASCII 中，或 String 的所有字符是否都在 ASCII 中

`isnumber(c::AbstractChar)` 是否在 numeric 类中

`isdigit(c::AbstractChar)` 是否为 0-9 的数字

`isprint(c::AbstractChar)` 是否为可打印字符

`iscntrl(c::AbstractChar)` 是否为不可打印字符（如换行符、制表符）

`ispunct(c::AbstractChar)` 是否为标点符号

`isspace(c::AbstractChar)` 是否为白空格

`islowercase(c::AbstractChar)` 是否为小写字符

`isuppercase(c::AbstractChar)` 是否为大写字符

## String

字符串的类型为 `String`，父类型为 `AbstractString`

### 构造

#### 一对或三对双引号

```julia
# 用一对双引号或三对双引号
julia> typeof("x")
String
julia> typeof("""x""")
String

# 若字符串中本来就有双引号，则需要对其转义，或最外层用三对双引号
julia> s = """Contains "quote" characters"""
"Contains \"quote\" characters"
```

#### `repeat()`

```julia
julia> repeat(".:Z:.", 10)
".:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:..:Z:."
```

#### `String()`

接收 Vector{Char}，返回将其连接起来的 String

### 类型转换

#### `string(num)` 数字转字符串

```julia
julia> string(328, base=8, pad=6) # 位数不足pad时补0
"000510"
```

#### `parse(type, str; base=10)` 字符串转数字

```julia
julia> parse(Int64, "3043", base=5) # 将5进制数值3043转为Int64整型的十进制数
398
```

### 转换大小写

#### `uppercase()`/`lowercase()` 字符全部大/小写

#### `titlecase()` 所有单词首字母大写

`titlecase(s::AbstractString; [wordsep::Function], strict::Bool=true) -> String`

- strict为true，单词非首字母的其他字母小写
- 不设置 wordsep 时，非字母都被视为单词的间隔符，包括表示缩写的单撇
  - 为解决这个问题，可以将间隔符设为空格

```julia
str = "How can mirrors be real if our eyes aren't real"
titlecase(str, wordsep=isspace) # isspace 是函数
# 如果wordsep默认，'是单词分隔符，后面的 t 会大写
using Pipe
@pipe split(str) .|> uppercasefirst |> join(_, ' ') # 等价
# "How Can Mirrors Be Real If Our Eyes Aren't Real"
```



#### `uppercasefirst()`/`lowercasefirst()` 字符串首字母大/小写

### 规模 size

`length()` 字符数

`sizeof()` 字节数

`lastindex()`返回最大索引值（字节数）

### 索引 index

`[]`可取得 string 中的任意字符，索引表示字节数，可以是数字（从 1 开始），也可以是关键字 `end`

```julia
julia> str = "Hello, world."
"Hello, world."
julia> str[1]
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)
julia> str[8]
'w': ASCII/Unicode U+0077 (category Ll: Letter, lowercase)

julia> str[end]
'.': ASCII/Unicode U+002e (category Po: Punctuation, other)
julia> str[end-1]
'd': ASCII/Unicode U+0064 (category Ll: Letter, lowercase)
julia> str[end÷2]
',': ASCII/Unicode U+002c (category Po: Punctuation, other)
```

> `÷` 的输入方式为 `\div`+`TAB`

#### 多字节字符问题

当其中存在 UTF-8 字符时，码值大于等于 `0x80` 的字符为多字节字符（有的甚至是 4 字节），连续字符的有效索引位置（字节数）并不是连续的。 

```julia
julia> s = "\u2200x\u2203y"
"∀x∃y"
julia> length(s)
4
julia> sizeof(s)
8
julia> lastindex(s) # lastindex()返回最大索引值（字节数）
8

julia> s[1]
'∀': Unicode U+2200 (category Sm: Symbol, math)

julia> s[2]
ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] getindex_continued(s::String, i::Int64, u::UInt32)
   @ Base .\strings\string.jl:233
 [3] getindex(s::String, i::Int64)
   @ Base .\strings\string.jl:226
 [4] top-level scope
   @ REPL[28]:1

julia> s[4]
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
julia> s[5]
'∃': Unicode U+2203 (category Sm: Symbol, math)
julia> s[8]
'y': ASCII/Unicode U+0079 (category Ll: Letter, lowercase)
```

   为此，需要使用函数 `nextind(str::AbstractString, i::Integer, n::Integer=1) -> Int`/`prevind()`，从索引 i 开始向后/前寻找 next 字符的有效 index

- `n = 1` 时，获得 `i` 位置之后/前首个 Unicode 字符的有效索引位置
- `n > 1` 时，相当于 `n = 1` 时的多次操作
- `n = 0` 时，会判断 `i` 是否为 Unicode 字符的有效起始索引，如果有效，会返回 `i` 值，否则报 StringIndexError（无效索引）或 BoundsError（越界）异常。  

```julia
julia> i1 = nextind(s, 0) # i取0，n默认取1
1
julia> i2 = nextind(s,i1) # 以前一个有效索引为参数
4
julia> i3 = nextind(s,i2) # 以前一个有效索引为参数
5
julia> i4 = nextind(s,i3) # 以前一个有效索引为参数
8
julia> i5 = nextind(s,i4) # 以前一个有效索引为参数
9
julia> i5> lastindex(s) # 判断获得的索引是否越界
true # 已经超出s实际的字符长度
julia> s[i1], s[i2], s[i3], s[i4] # 以获得各有效索引提取字符
('∀', 'x', '∃', 'y')

julia> nextind(s, 3, 0) # 判断3是否为有效索引位置
ERROR: StringIndexError: invalid index [3], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] nextind(s::String, i::Int64, n::Int64)
   @ Base .\strings\basic.jl:559
 [3] top-level scope
   @ REPL[48]:1

julia> nextind(s, 4, 0) # 判断4是否为有效索引位置
4 # 有效，返回该值
```

### 遍历 map

#### `1:length()/lastindex()`

由单字节字符组成的 `string`，可以用 `length()` 或 `lastindex()` 遍历

````julia
julia> for i = 1:length(str)
         print(str[i])
       end
H e l l o ,   w o r l d .

# 这种遍历都不适用包含多字节字符的string
julia> for i = 1:length(s)
         print(s[i])
       end
∀ERROR: StringIndexError: invalid index [2], valid nearby indices [1]=>'∀', [4]=>'x'
Stacktrace:
 [1] string_index_err(s::String, i::Int64)
   @ Base .\strings\string.jl:12
 [2] getindex_continued(s::String, i::Int64, u::UInt32)
   @ Base .\strings\string.jl:233
 [3] getindex(s::String, i::Int64)
   @ Base .\strings\string.jl:226
 [4] top-level scope
   @ .\REPL[56]:2
````

#### `eachindex()`

包含多字节字符的 `string`，要遍历只能用 `eachindex()`

```julia
julia> for i in eachindex(s)
         println(i, " is ", s[i]) # println()相比print()自动换行
       end
1 is ∀
4 is x
5 is ∃
8 is y
```

#### 将 string 作为迭代器

字符串也是可迭代数集的一种，可以基于迭代器，采用元素迭代的方式进行遍历  

```julia
julia> for c in s # 或 for c = s 或 for c∈s，∈符号的左边只能是char
         println(c)
       end
∀
x
∃
y
```



### 切片 Subset

`[start:end]`提取器，内部使用范围索引

- 左右闭区间，与 js 不同
- start > end，结果将会是空字符串 
- start == end，取出的将是仅有一个字符的 string，但不是 char。 

注意：**若使用一个数字的索引，提取出来的将是 char 而非 string**

```julia
julia> "abc"[2:2]
"b"

julia> "abc"[2]
'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)
```

### 串联 concatenation

#### `join()`

 `join([io::IO,] iterator [, delim [, last]])`

`delim` 默认为 `""`

```julia
julia> join(["abc","def"])
"abcdef"

julia>  join(["apples", "bananas", "pineapples"], ", ", " and ")
"apples, bananas and pineapples"
```

如果 `join()` 接收 String 而非 Vector{String}，由于 String 也是 iterator，所以也能运行，将其拆分为 Char 再 join

```julia
julia> join("bitcoin", "***")
"b***i***t***c***o***i***n"
```

特别是，`join()` 接收的 iterator 可以是数字等类型，自动将其转换为 String 再拼接。

#### `*`

也可以用 `*` 连接字符串（`*`在数学上常表示不满足交换律的运算）

```julia
julia> "abc" * "def"
"abcdef"

julia> greet * ", " * whom * ".\n"
"Hello, World.\n"

julia> 'a' * "bc" # 可以串联 char 和 string
"abc"

julia> broadcast(*, "ab", 'c', 'd', "ef")
"abcdef"
```



### 插值 interpolation

`$` 后面紧跟的变量被展开插入到字符串中

```julia
julia> greet = "Hello"
"Hello"

julia> whom = "World"
"World"

julia> "$greet, $whom."
"Hello, World."

julia> "1 + 2 = $(1 + 2)"
"1 + 2 = 3"

julia> v = [1,2,3]
3-element Vector{Int64}:
 1
 2
 3

julia> "v: $v"
"v: [1, 2, 3]"
```

如果字符串中一定要使用 `$`，需要将其转义 `\$`

### 比较

默认遵循字典次序

### 判断前后缀

`startwith(s, prefix)`/`endwith(s, suffix)`

### 判断匹配

`occursin(needle::Union{AbstractString,AbstractPattern,AbstractChar}, haystack::AbstractString) -> Bool`

确定第一个参数是否是第二个参数的子字符串。如果 `needle` 是正则表达式，则检查 `haystack` 是否包含匹配项。

### 搜索 index

`findfirst(needle, haystack)`，返回值为 range 对象（即使 `needle` 的长度为 1 ，如 `3:3`）

`findlast()`

`findnext()`

`findprev()`

`findall()`

如果搜索失败，返回 nothing 对象

```julia
julia> s
"∀x∃y"

julia> findfirst("∃y", s)
5:8

julia> s[5:8]
"∃y"
```

### 分割 split

#### `collect()`

`collect(String)::Vector{Char}`

拆分字符串为字符向量

#### `split()`

`split(str::AbstractString, [chars]; limit::Integer=0,keep::Bool=true)`

- str是待分割字符串
- chars是Char、String或正则表达式的对象，描述分隔的依据，**如果不指定，则默认为空格**，但需注意chars表达的内容一定要在str中能够找到，否则不会出现预期的结果
- 另外两个参数是可选的键值参数，分别用于限定结果的数量以及设定是否保留空的内容



分割的结果虽然是 Array，但不是 String 的 Array，而是 SubString 的 Array，需要使用构造方法 `String()` 将该类型转化为 `String` 类型

```julia
julia> a = split("hi 1 hello 2 hey 3 world", r"\d")
4-element Vector{SubString{String}}:
 "hi "
 " hello "
 " hey "
 " world"

julia> a[1]
"hi "

julia>  dump(a[1])
SubString{String}
  string: String "hi 1 hello 2 hey 3 world"
  offset: Int64 0
  ncodeunits: Int64 3

julia> String(a[1])
"hi "

julia> typeof(ans)
String
```

### 提取 extract

#### `match()` 匹配一次

`match(r::Regex, s::AbstractString[, idx::Integer[, addopts]])`

在 `s` 中搜索正则表达式 `r` 的第一个匹配项，可选的 `idx` 参数指定开始搜索的索引。

返回一个包含匹配项的 `RegexMatch`对象（匹配失败则返回 nothing），结构如下：

```julia
RegexMatch <: Any
  match::SubString{String}
  captures::Array{Union{SubString{String}, Nothing},1}
  offset::Int64
  offsets::Array{Int64,1}
  regex::Regex
```

 `.match` 记录匹配的子串整体内容，`.captures` 记录捕捉到的各分组子串内容，即match字段中的字符串里符合圆括号内正则表达式的子串，相当于正则模式中对应的各个组（Group）；若捕捉结果为空，该字段将为nothing，而offsets值会为0（无效值）。`.offset`记录匹配的子串整体在原字符串中的偏移，`offsets`记录捕捉到的各分组子串的偏移，`.regex`记录原始正则表达式的内容  

 ```julia
 julia> rx = r"a(.)a"
 r"a(.)a"
 
 julia> m = match(rx, "cabac")
 RegexMatch("aba", 1="b") 
 # 结果已经给出了基本的提取信息：符合模式的子串整体内容，和()捕捉到的内容
 
 julia> typeof(m)
 RegexMatch
 
 julia> dump(m)
 RegexMatch
   match: SubString{String}
     string: String "cabac"
     offset: Int64 1
     ncodeunits: Int64 3
   captures: Array{Union{Nothing, SubString{String}}}((1,))
     1: SubString{String}
       string: String "cabac"
       offset: Int64 2
       ncodeunits: Int64 1
   offset: Int64 2
   offsets: Array{Int64}((1,)) [3]
   regex: Regex
     pattern: String "a(.)a"
     compile_options: UInt32 0x040a0002
     match_options: UInt32 0x40000000
     regex: Ptr{Nothing} @0x000000001c46e9d0
 
 julia> m.match
 "aba"
 
 julia> m.captures
 1-element Vector{Union{Nothing, SubString{String}}}:
  "b"
 
 julia> match(rx, "cabac", 3) === nothing
 true
 ```

#### `eachmatch() `匹配多次

将每个匹配部位处得到的 RegexMatch 封装在一个迭代器中 

```julia
julia> n = eachmatch(r"cq(\d)", "apcq1apcq2apcq3")
Base.RegexMatchIterator(r"cq(\d)", "apcq1apcq2apcq3", false)

julia> for i in n
         println(i)
       end
RegexMatch("cq1", 1="1")
RegexMatch("cq2", 1="2")
RegexMatch("cq3", 1="3")
```

#### 最佳实践

如果仅需要最终的匹配内容，而不需要RegexMatch结构，可以使用以下的命令实现  

`collect(m.match for m in eachmatch(r, s))  `

```julia
julia> collect(m.match for m in eachmatch(r"cq(\d)", "apcq1apcq2apcq3"))
3-element Vector{SubString{String}}:
 "cq1"
 "cq2"
 "cq3"
```

若无法提取，则会返回零元素的数组  

### 替换 replace

`replace(str::AbstractString, pattern=>rpl; count) `

- str为原字符串
- pattern是Char、String或正则表达式类型（描述欲替换内容的模式）
- rpl是用于替换的新内容，可以是String、Char或一个函数对象，当rpl为一个函数时，pattern匹配的子串内容s会被rpl（s）的计算结果所代替
- count为可选，用于指定从左到右需要替换的个数，不设置时会将所有匹配上的内容替换，否则会替换掉count个内容
- 注意，**从 pattern 到 rpl 的符号是 `=>`，而非表示匿名函数的 `->`**

```julia
julia> s = replace(str, "o"=>"p")
"Hellp, wprld."

julia> s = replace(str, 'o'=>'p'; count=1)
"Hellp, world."

julia> replace(str, r"o"=>uppercase)
"HellO, wOrld."
```

#### `map(f, string)`

注意：`f` 必须返回 `Char`，才能使用 `f` 更换 `string` 的每一个字符。

### 删除头尾字符

#### `strip`/`lstrip`/`rstrip` 删除头尾空格或指定字符

`strip([pred=isspace,] str::AbstractString) -> SubString`
`strip(str::AbstractString, chars) -> SubString`

从 `str` 中删除前导和尾随字符，这些字符由 `chars` 指定或函数 `pred` 返回 `true`。

默认行为是删除前导和尾随空格和分隔符。

可选的 `chars` 参数指定要删除的字符：它可以是单个字符、向量或字符集。

```julia
julia> strip("{3, 5}\n", ['{', '}', '\n'])
"3, 5"
```

#### `chop` 删除头尾指定数量的字符

`chop(s::AbstractString; head::Integer = 0, tail::Integer = 1)`

从 `s` 中删除前 `head` 个和后 `tail` 个字符。如果请求删除的字符多于 `length(s)`，则返回一个空字符串。

```julia
julia> a = "March"
"March"

julia> chop(a)
"Marc"

julia> chop(a, head = 1, tail = 2)
"ar"

julia> chop(a, head = 5, tail = 5)
""
```

#### `chomp(s::AbstractString)` 删除尾部单个换行符



## 正则表达式

`Regex` 类

### 构造

常规字符串加前缀 `r`，或 `Regex(s::AbstractString)`（内部的特殊标识符都要转义）

```julia
julia> a = r"^\s*(?:#|$)"
r"^\s*(?:#|$)"

julia> typeof(a)
Regex
```



`i`后缀，忽略大小写
