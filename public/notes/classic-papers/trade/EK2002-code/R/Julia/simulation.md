# Counterfactual Simulation

## Data Processing

### Import Modules


```julia
using JSON, CSV, JLD                               # IO
using DataFrames                                   # Data Processing
using LinearAlgebra, Statistics, Kronecker         # Math
using NLsolve                                      # Numeric
using Pipe                                         # Programming
```

### Read Data


```julia
# 标量常数
scalars = JSON.parsefile("../data/scalar.json")
```




    Dict{String, Any} with 3 entries:
      "theta" => Any[3.6, 8.28, 12.86]
      "N"     => 19
      "beta"  => 0.21221




```julia
# 国家代码表
country_table = CSV.read("../data/country_code.csv", DataFrame);
```


```julia
# 国别原始数据
nominal_variables = CSV.read("../data/nominal_variable.csv", DataFrame)
```

    [1m1×25 DataFrame[0m
    [1m Row [0m│[1m n     [0m[1m gdp    [0m[1m exchange_rate [0m[1m industrial_labor [0m[1m nominal_wage [0m[1m edu_year [0m[1m trade_1  [0m[1m trade_2 [0m[1m trade_3 [0m[1m trade_4 [0m[1m trade_5 [0m[1m trade_6 [0m[1m trade_7 [0m[1m trade_8 [0m[1m trade_9 [0m[1m trade_10 [0m[1m trade_11 [0m[1m trade_12 [0m[1m trade_13 [0m[1m trade_14 [0m[1m trade_15 [0m[1m trade_16 [0m[1m trade_17 [0m[1m trade_18 [0m[1m trade_19 [0m
    [1m     [0m│[90m Int64 [0m[90m Int64  [0m[90m Float64       [0m[90m Int64            [0m[90m Float64      [0m[90m Float64  [0m[90m Float64  [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64 [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m[90m Float64  [0m
    ─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       1 │     1  378681          1.281           1160000       21873.1      8.72  144400.0  216.647  369.611  875.574  198.919   330.87  1090.47  3043.48   47.434   1378.51    8741.7   478.718   1962.17   128.908    48.469   185.523   827.736   3727.88   10623.7
    


```julia
# TABLE III 中所有虚拟变量的系数估计值
estimators = load("../data/table3-output.jld")
```




    Dict{String, Any} with 2 entries:
      "table3_estimate" => [-3.09889, -3.66447, -4.03391, -4.21812, -6.06461, -6.55…
      "dni_measure"     => [0.0 -6.32309 … -5.81144 -5.81144; -8.23702 0.0 … -5.711…



### Data Transformation


```julia
"""
`select(df, args...)` 永远返回 DataFrame，有时候计算起来不方便
所以自定义一个 `extract(df, args...)`，返回多列 Matrix 或单列 Vector
"""
function extract(df::DataFrame, var)
    M = select(df, var) |> Matrix
    size(M, 2) > 1 ? M : reshape(M, length(M))
end;
```


```julia
## 1. scalars
N = scalars["N"];
θ = scalars["theta"][2]
```




    8.28




```julia
## 2. exchange rate
exchange_rate = extract(nominal_variables, :exchange_rate);
```


```julia
## 3. bilateral trade data

# nominal bilateral trade
Xni_nominal = extract(nominal_variables, Not(1:6)) * 10^6

# real bilateral trade
Xni = Xni_nominal ./ exchange_rate # 自动扩展除数为矩阵
Xnn = diag(Xni)

# expenditure on manufacturing goods
Xn = @pipe mapslices(sum, Xni; dims=2) |> reshape(_, N)

imports = Xn - Xnn
exports = @pipe mapslices(sum, Xni; dims=1) |> reshape(_, N) - Xnn;
```


```julia
## 4. manufacturing labor and wage

industrial_labor = nominal_variables.industrial_labor
nominal_wage = nominal_variables.nominal_wage # 已经以美元计价
edu_year = nominal_variables.edu_year
effective_labor = industrial_labor .* exp.(0.06 * edu_year)
effective_wage = nominal_wage .* exp.(-0.06 * edu_year);
```


```julia
## 5. income/expenditure

# GDP in dollars
Y = nominal_variables.gdp * (10^6) ./ exchange_rate

# manufacturing labor income
Y_l = effective_wage .* effective_labor

# non-manufacturing income
Y_o = Y - Y_l;
```


```julia
## 6. β and α

# β = manufacturing labor income / manufacturing output
βs = Y_l ./ (Xnn + exports) # 不知作者如何加权得出了 β = 0.21221 这个数值
β = scalars["beta"]
```




    0.21221




```julia
# α = manufacturing expenditure / total expenditure
αs = (Y_l + imports - exports) ./ Y
# 各国按 GDP 加权计算 α
α = sum((Y / sum(Y)) .* αs)
```




    0.13481359059266587




```julia
## 7. technology

# 表示技术的 T 来源于 (27) 式，计算所需的 source dummies 的估计系数见 TABLE VI
table3_estimate = estimators["table3_estimate"]
source_estimate = table3_estimate[11:29]
# 这个 tech 使用的都是绝对数据，保持准确量纲，便于 wL 直接与 Y/Y_o 相比
absolute_tech = (log.(effective_wage) * θ + source_estimate) * β .|> exp;
```


```julia
## 8. geography barrier
# barrier_measure 来源于 (28) 式，为 -θ ln(dni)
dni_measure = estimators["dni_measure"]
Dni = exp.(dni_measure); # dni^{-θ} 矩阵
```


```julia
## 9. gamma constant
γ = β^β * (1 - β)^(1 - β) # 不知为何 γ 可以由 β 推出
g = γ^(-θ)
```




    72.2176306769607



## Calibration

求解一般均衡模型的多元非线性方程组，作为反事实模拟的 baseline

一些符号的含义：
1. $P_n = p_n^{-\theta}$，所以价格水平越高 $P_n$ 越小，价格水平越低 $P_n$ 越大
2. $D_{ni} = d_{ni}^{-\theta}$
3. $k_i = gT_iw_i^{-\beta\theta}$

### 情境一 劳动力可以跨部门流动


```julia
"""
劳动力可跨产业流动的模型
"""
function model_mobile(tech, Dni)

    # 不变参数
    w = effective_wage
    global Y

    # 可变参数
    T = tech
    D = Dni

    # 计算 k
    k = @. g * T * (w^(-β * θ))

    # 设定 P 的迭代初值
    P_low = k .^ (1 / β)
    P_high = sum(k)^(1 / β) * ones(N)
    P_start = (P_low + P_high) / 2

    # (16) 式
    function f!(F, P)
        # S 是一个中间变量，换成其他名字也可以
        S = inv(D)P - @. k * (P^(1 - β))
        for i in 1:length(P)
            F[i] = S[i] # 或 F[i]=(inv(D)P - k .* (P .^ (1 - β)))[i]
        end
    end

    # 解 P
    if D == ones(N, N) # 全1矩阵，无贸易障碍
        P = P_high
    else
        P = nlsolve(f!, P_start, show_trace=false, iterations=500).zero
    end

    # 根据 P 推导其他变量
    Pi = D .* ((1 ./ P) ⊗ (@. k * P^(1 - β))')
    L = α * β * (1 ./ w) .* (inv(I(N) - (1 - β)Pi')Pi'Y)
    Xn = w .* L * (1 - β) / β + α * Y
    Xni = Pi .* (Xn ⊗ ones(1, N))
    trade_volumn = sum(Xni) - sum(diag(Xni))
    W = @. Y * P^(α / θ)

    return Dict(
        "p" => P .^ (-1 / θ),
        "L" => L,
        "W" => W,
        "Xni" => Xni,
        "trade_volumn" => trade_volumn
    )
end

baseline_mobile = model_mobile(absolute_tech, Dni)
```




    Dict{String, Any} with 5 entries:
      "trade_volumn" => 1.92072e12
      "W"            => [4.19262e11, 2.23337e11, 2.8212e11, 8.30919e11, 1.83804e11,…
      "Xni"          => [9.42192e10 9.46421e7 … 1.47821e9 8.75686e9; 2.68663e7 5.68…
      "L"            => [1.64588e6, 1.20563e6, 1.314e6, 7.57545e6, 7.60466e5, 8.502…
      "p"            => [0.0748662, 0.078304, 0.0615964, 0.0594699, 0.0728381, 0.07…



### 情境二 劳动力不能跨部门流动


```julia
"""
劳动力不可跨产业流动的模型
"""
function model_immobile(tech, Dni)

    # 不变参数
    L = effective_labor
    global Y_o

    # 可变参数
    T = tech
    D = Dni


    #=
    # 解法一：方程组自变量为 w 与 P 的串联向量，直接求解 2N 个方程

    # 设定 w 的迭代初始值
    w_0 = effective_wage
    k_0 = @. g * T * (w_0^(-β * θ))

    # 设定 P 的迭代初值
    P_low = k_0 .^ (1 / β)
    P_high = sum(k_0)^(1 / β) * ones(N)
    P_start = (P_low + P_high) / 2

    # w 和 P 串联的迭代初值为
    x_0 = [w_0..., P_start...]

    # (16) 式
    function f!(F, x)
        w = x[1:N]
        P = x[N+1:2N]
        @show P

        # 中间变量
        k = @. g * T * (w^(-β * θ))
        Y_l = w .* L
        Pi = D .* ((1 ./ P) ⊗ (@. k * P^(1 - β))')

        # 前 N 个方程
        S1 = inv(D)P - @. k * (P^(1 - β))
        # 后 N 个方程
        S2 = Y_l - (1 - β + α * β) * Pi'Y_l - α * β * Pi'Y_o

        for i in 1:N
            F[i] = S1[i]
        end
        for i in 1:N
            F[i+N] = S2[i]
        end
    end

    # 解 x
    x = nlsolve(f!, x_0, show_trace=false, iterations=2000).zero
    w = x[1:N]
    P = x[N+1:2N]

    # 推导其他变量
    Pi = D .* ((1 ./ P) ⊗ (@. k * P^(1 - β))')
    Xn = @. (α + (1 - β) / β) * w * L + α * Y_o
    Xni = Pi .* (Xn ⊗ ones(Int, 1, N))
    trade_volumn = sum(Xni) - sum(diag(Xni))
    W = @. (w * L + Y_o) * P^(α / θ)

    return Dict(
        "p" => P .^ (-1 / θ),
        "w" => w,
        "W" => W,
        "Xni" => Xni,
        "trade_volumn" => trade_volumn
    )


    # 将 w 和 P 串联作为自变量直接求解，迭代会发散
    # P 的初值为 1e14 级别，均衡值大概在 1e10
    # 但在 2N 个方程的求解过程中，P 最多下降到 1e13 数量级，就出现负值错误
    # 所以大量联立方程可能会导致不可解。应采取以下负反馈算法： 
    =#



    # 解法二：负反馈
    # 假设w已知，由(16)解出P后，可推出Y_l/w，即对劳动力的引致需求
    # 它与劳动力L的差，为超额需求，会根据一定弹性拉动w的变化
    # 然后不断迭代 w，直到超额需求为0

    # w 的初始值
    w = effective_wage

    for i ∈ 1:500
        # 根据每轮的 w 计算 k
        k = @. g * T * (w^(-β * θ))

        # 根据每轮的 w 计算 P 的初始值
        P_low = k .^ (1 / β)
        P_high = sum(k)^(1 / β) * ones(N)
        P_start = (P_low + P_high) / 2

        # (16) 式
        function f!(F, P)
            # S 是一个中间变量，换成其他名字也可以
            S = inv(D)P - @. k * (P^(1 - β))
            for i in 1:N
                F[i] = S[i]
            end
        end

        # 解 P
        if D == ones(N, N) # 全1矩阵，无贸易障碍
            P = P_high
        else
            P = nlsolve(f!, P_start, show_trace=false, iterations=500).zero
        end

        # 用 (21) 式计算制造业收入(世界市场对各国制造业产品的需求)
        Pi = D .* ((1 ./ P) ⊗ (@. k * P^(1 - β))')
        Y_l = (1 - β + α * β) * Pi' * (w .* L) + α * β * Pi' * Y_o

        # 引致的超额劳动需求
        excess_labor_ratio = @. (Y_l / w - L) / L
        tolerance = sum(excess_labor_ratio .^ 2) |> sqrt

        if tolerance < 1e-9 # 精度符合要求，可输出模型结果
            Xn = @. (α + (1 - β) / β) * w * L + α * Y_o
            Xni = Pi .* (Xn ⊗ ones(Int, 1, N))
            trade_volumn = sum(Xni) - sum(diag(Xni))
            W = @. (w * L + Y_o) * P^(α / θ)

            return Dict(
                "p" => P .^ (-1 / θ),
                "w" => w,
                "W" => W,
                "Xni" => Xni,
                "trade_volumn" => trade_volumn
            )
        else # 否则，令 w 与超额劳动需求相反的方向变化
            # 对劳动的超额需求会导致工资发生变化
            w = w .+ 0.3excess_labor_ratio .* w # 0.3 为弹性
            println("iterator: ", i)
        end
    end


    # 500 次迭代还没结果，一般来说，是因为序列不收敛
    println("not convergent")
end

baseline_immobile = model_immobile(absolute_tech, Dni)
```

    iterator: 1
    iterator: 2
    iterator: 3
    iterator: 4
    iterator: 5
    iterator: 6
    iterator: 7
    iterator: 8
    iterator: 9
    iterator: 10
    iterator: 11
    iterator: 12
    iterator: 13
    iterator: 14
    iterator: 15
    iterator: 16
    iterator: 17
    iterator: 18
    iterator: 19
    iterator: 20
    iterator: 21
    iterator: 22
    iterator: 23
    iterator: 24
    iterator: 25
    iterator: 26
    iterator: 27
    iterator: 28
    iterator: 29
    iterator: 30
    iterator: 31
    iterator: 32
    iterator: 33
    iterator: 34
    iterator: 35
    iterator: 36
    iterator: 37
    iterator: 38
    iterator: 39
    iterator: 40
    iterator: 41
    iterator: 42
    iterator: 43
    iterator: 44
    iterator: 45
    iterator: 46
    iterator: 47
    iterator: 48
    iterator: 49
    iterator: 50
    iterator: 51
    iterator: 52
    iterator: 53
    iterator: 54
    iterator: 55
    iterator: 56
    iterator: 57
    iterator: 58
    iterator: 59
    




    Dict{String, Any} with 5 entries:
      "trade_volumn" => 1.82557e12
      "w"            => [12506.8, 14506.8, 18590.9, 20783.4, 18886.0, 18816.9, 1829…
      "W"            => [4.18727e11, 2.23016e11, 2.82351e11, 8.44268e11, 1.84049e11…
      "Xni"          => [1.07602e11 1.13535e8 … 1.71397e9 7.80303e9; 2.87523e7 6.38…
      "p"            => [0.0739043, 0.076653, 0.0607997, 0.0619525, 0.0718603, 0.07…



## Simulation

### TABLE IX

提高贸易障碍至 Autarky


```julia
D_autarky = I(N)

autarky_mobile = model_mobile(absolute_tech, D_autarky)
autarky_immobile = model_immobile(absolute_tech, D_autarky)

# 福利变化
100 * log.(autarky_mobile["W"] ./ baseline_mobile["W"])
100 * log.(autarky_immobile["W"] ./ baseline_immobile["W"])


# 价格变化
100 * log.(autarky_mobile["p"] ./ baseline_mobile["p"])
100 * log.(autarky_immobile["p"] ./ baseline_immobile["p"])


# 制造业劳动力变化
100 * log.(autarky_mobile["L"] ./ baseline_mobile["L"])
100 * log.(autarky_immobile["w"] ./ baseline_immobile["w"])
```

    iterator: 1
    iterator: 2
    iterator: 3
    iterator: 4
    iterator: 5
    iterator: 6
    iterator: 7
    iterator: 8
    iterator: 9
    iterator: 10
    iterator: 11
    iterator: 12
    iterator: 13
    iterator: 14
    iterator: 15
    iterator: 16
    iterator: 17
    iterator: 18
    iterator: 19
    iterator: 20
    iterator: 21
    iterator: 22
    iterator: 23
    iterator: 24
    iterator: 25
    iterator: 26
    iterator: 27
    iterator: 28
    iterator: 29
    iterator: 30
    iterator: 31
    iterator: 32
    iterator: 33
    iterator: 34
    iterator: 35
    iterator: 36
    iterator: 37
    iterator: 38
    iterator: 39
    iterator: 40
    iterator: 41
    iterator: 42
    iterator: 43
    iterator: 44
    iterator: 45
    iterator: 46
    iterator: 47
    iterator: 48
    iterator: 49
    iterator: 50
    iterator: 51
    iterator: 52
    iterator: 53
    iterator: 54
    iterator: 55
    iterator: 56
    iterator: 57
    iterator: 58
    iterator: 59
    iterator: 60
    iterator: 61
    iterator: 62
    iterator: 63
    iterator: 64
    iterator: 65
    iterator: 66
    iterator: 67
    iterator: 68
    iterator: 69
    iterator: 70
    iterator: 71
    iterator: 72
    iterator: 73
    iterator: 74
    iterator: 75
    iterator: 76
    iterator: 77
    iterator: 78
    iterator: 79
    iterator: 80
    iterator: 81
    iterator: 82
    iterator: 83
    iterator: 84
    iterator: 85
    iterator: 86
    iterator: 87
    iterator: 88
    iterator: 89
    iterator: 90
    iterator: 91
    iterator: 92
    iterator: 93
    iterator: 94
    iterator: 95
    iterator: 96
    iterator: 97
    iterator: 98
    iterator: 99
    iterator: 100
    iterator: 101
    iterator: 102
    iterator: 103
    iterator: 104
    iterator: 105
    iterator: 106
    iterator: 107
    iterator: 108
    iterator: 109
    iterator: 110
    iterator: 111
    iterator: 112
    iterator: 113
    iterator: 114
    iterator: 115
    iterator: 116
    iterator: 117
    iterator: 118
    iterator: 119
    iterator: 120
    iterator: 121
    iterator: 122
    iterator: 123
    iterator: 124
    iterator: 125
    iterator: 126
    iterator: 127
    iterator: 128
    iterator: 129
    iterator: 130
    iterator: 131
    iterator: 132
    iterator: 133
    iterator: 134
    iterator: 135
    iterator: 136
    iterator: 137
    iterator: 138
    iterator: 139
    iterator: 140
    iterator: 141
    iterator: 142
    iterator: 143
    iterator: 144
    iterator: 145
    iterator: 146
    iterator: 147
    iterator: 148
    iterator: 149
    iterator: 150
    iterator: 151
    iterator: 152
    iterator: 153
    iterator: 154
    iterator: 155
    iterator: 156
    iterator: 157
    iterator: 158
    iterator: 159
    iterator: 160
    iterator: 161
    iterator: 162
    iterator: 163
    iterator: 164
    iterator: 165
    iterator: 166
    iterator: 167
    iterator: 168
    iterator: 169
    iterator: 170
    iterator: 171
    iterator: 172
    iterator: 173
    iterator: 174
    iterator: 175
    iterator: 176
    iterator: 177
    iterator: 178
    iterator: 179
    iterator: 180
    iterator: 181
    iterator: 182
    iterator: 183
    iterator: 184
    iterator: 185
    iterator: 186
    iterator: 187
    iterator: 188
    iterator: 189
    iterator: 190
    iterator: 191
    iterator: 192
    iterator: 193
    iterator: 194
    iterator: 195
    iterator: 196
    iterator: 197
    iterator: 198
    iterator: 199
    iterator: 200
    iterator: 201
    iterator: 202
    iterator: 203
    iterator: 204
    iterator: 205
    iterator: 206
    iterator: 207
    iterator: 208
    iterator: 209
    iterator: 210
    iterator: 211
    iterator: 212
    iterator: 213
    iterator: 214
    iterator: 215
    iterator: 216
    iterator: 217
    iterator: 218
    iterator: 219
    iterator: 220
    iterator: 221
    iterator: 222
    iterator: 223
    iterator: 224
    iterator: 225
    iterator: 226
    iterator: 227
    iterator: 228
    iterator: 229
    iterator: 230
    iterator: 231
    iterator: 232
    iterator: 233
    iterator: 234
    iterator: 235
    iterator: 236
    iterator: 237
    iterator: 238
    iterator: 239
    iterator: 240
    iterator: 241
    iterator: 242
    iterator: 243
    iterator: 244
    iterator: 245
    iterator: 246
    iterator: 247
    iterator: 248
    iterator: 249
    iterator: 250
    iterator: 251
    iterator: 252
    iterator: 253
    iterator: 254
    iterator: 255
    iterator: 256
    iterator: 257
    iterator: 258
    iterator: 259
    iterator: 260
    iterator: 261
    iterator: 262
    iterator: 263
    iterator: 264
    iterator: 265
    iterator: 266
    iterator: 267
    iterator: 268
    iterator: 269
    iterator: 270
    iterator: 271
    iterator: 272
    iterator: 273
    iterator: 274
    iterator: 275
    iterator: 276
    iterator: 277
    iterator: 278
    iterator: 279
    iterator: 280
    iterator: 281
    iterator: 282
    iterator: 283
    iterator: 284
    iterator: 285
    iterator: 286
    iterator: 287
    iterator: 288
    iterator: 289
    iterator: 290
    iterator: 291
    iterator: 292
    iterator: 293
    iterator: 294
    iterator: 295
    iterator: 296
    iterator: 297
    iterator: 298
    iterator: 299
    iterator: 300
    iterator: 301
    iterator: 302
    iterator: 303
    iterator: 304
    iterator: 305
    iterator: 306
    iterator: 307
    iterator: 308
    iterator: 309
    iterator: 310
    iterator: 311
    iterator: 312
    iterator: 313
    iterator: 314
    iterator: 315
    iterator: 316
    iterator: 317
    iterator: 318
    iterator: 319
    iterator: 320
    iterator: 321
    iterator: 322
    iterator: 323
    iterator: 324
    iterator: 325
    iterator: 326
    iterator: 327
    iterator: 328
    iterator: 329
    iterator: 330
    iterator: 331
    iterator: 332
    iterator: 333
    iterator: 334
    iterator: 335
    iterator: 336
    iterator: 337
    iterator: 338
    iterator: 339
    iterator: 340
    




    19-element Vector{Float64}:
      54.236889020437516
       4.095901538390153
       3.1248485359551688
       9.903420636141288
      18.625079132012115
       9.633163662618422
       9.675178832188543
     -47.196498692107994
      93.18676825994937
       8.576313985690403
      -9.68068036097647
      21.27961047106693
      41.22107291659153
      46.52024796643474
      28.273523737857314
      22.068662159047282
      -4.470590260326001
      -7.372878046980325
       9.245188473933679



### TABLE X

降低贸易障碍

### TABLE XI

技术进步（改善福利的）外溢效果

### TABLE XII

关税


```julia

```
