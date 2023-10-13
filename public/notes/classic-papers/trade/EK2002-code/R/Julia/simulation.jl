using JSON, CSV, JLD                               # IO
using DataFrames                                   # Data Processing
using LinearAlgebra, Statistics, Kronecker         # Math
using NLsolve                                      # Numeric
using Pipe                                         # Programming

# 标量常数
scalars = JSON.parsefile("../data/scalar.json")

# 国家代码表
country_table = CSV.read("../data/country_code.csv", DataFrame)

# 国别原始数据
nominal_variables = CSV.read("../data/nominal_variable.csv", DataFrame)

# TABLE III 中所有虚拟变量的系数估计值
estimators = load("../data/table3-output.jld")


"""
`select(df, args...)` 永远返回 DataFrame，有时候计算起来不方便
所以自定义一个 `extract(df, args...)`，返回多列 Matrix 或单列 Vector
"""
function extract(df::DataFrame, var)
    M = select(df, var) |> Matrix
    size(M, 2) > 1 ? M : reshape(M, length(M))
end

## 1. scalars
N = scalars["N"];
θ = scalars["theta"][2]

## 2. exchange rate
exchange_rate = extract(nominal_variables, :exchange_rate);

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

## 4. manufacturing labor and wage

industrial_labor = nominal_variables.industrial_labor
nominal_wage = nominal_variables.nominal_wage # 已经以美元计价
edu_year = nominal_variables.edu_year
effective_labor = industrial_labor .* exp.(0.06 * edu_year)
effective_wage = nominal_wage .* exp.(-0.06 * edu_year);

## 5. income/expenditure

# GDP in dollars
Y = nominal_variables.gdp * (10^6) ./ exchange_rate

# manufacturing labor income
Y_l = effective_wage .* effective_labor

# non-manufacturing income
Y_o = Y - Y_l;

## 6. β and α

# β = manufacturing labor income / manufacturing output
βs = Y_l ./ (Xnn + exports) # 不知作者如何加权得出了 β = 0.21221 这个数值
β = scalars["beta"]

# α = manufacturing expenditure / total expenditure
αs = (Y_l + imports - exports) ./ Y
# 各国按 GDP 加权计算 α
α = sum((Y / sum(Y)) .* αs)

## 7. technology

# 表示技术的 T 来源于 (27) 式，计算所需的 source dummies 的估计系数见 TABLE VI
table3_estimate = estimators["table3_estimate"]
source_estimate = table3_estimate[11:29]
# 这个 tech 使用的都是绝对数据，保持准确量纲，便于 wL 直接与 Y/Y_o 相比
absolute_tech = (log.(effective_wage) * θ + source_estimate) * β .|> exp;

## 8. geography barrier
# barrier_measure 来源于 (28) 式，为 -θ ln(dni)
dni_measure = estimators["dni_measure"]
Dni = exp.(dni_measure); # dni^{-θ} 矩阵

## 9. gamma constant
γ = β^β * (1 - β)^(1 - β) # 不知为何 γ 可以由 β 推出
g = γ^(-θ)




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
