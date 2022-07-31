
# 国别原始数据
nominal_variables = CSV.read("../data/nominal_variable.csv", DataFrame)

# TABLE III 中所有虚拟变量的系数估计值
estimators = load("../data/table3-output.jld")

## 1. θ
θ = θs[2];

## 2. exchange rate
exchange_rate = nominal_variables.exchange_rate;

## 3. bilateral trade data

# nominal bilateral trade
Xni_nominal = (select(nominal_variables, Not(1:6)) |> Matrix) .* 10^6
# real bilateral trade
Xni = Xni_nominal ./ exchange_rate # 自动扩展除数为矩阵
Xnn = diag(Xni)

# expenditure on manufacturing goods
Xn = mapslices(sum, Xni; dims=2)


imports = Xn .- Xnn
exports = mapslices(sum, Xni; dims=1)' .- Xnn;

## 4. manufacturing labor and wage

industrial_labor = nominal_variables.industrial_labor
nominal_wage = nominal_variables.nominal_wage # 已经以美元计价
edu_year = nominal_variables.edu_year
effective_labor = industrial_labor .* exp.(0.06 .* edu_year)
effective_wage = nominal_wage .* exp.(-0.06 .* edu_year);

## 5. income/expenditure

# GDP in dollars
Y = nominal_variables.gdp .* (10^6) ./ exchange_rate
# manufacturing labor income
Y_l = effective_wage .* effective_labor
# non-manufacturing income
Y_o = Y .- Y_l;

## 6. beta and alpha

# beta = manufacturing labor income / manufacturing output
βs = Y_l ./ (Xnn .+ exports); # 不知作者如何加权得出了 beta = 0.21221 这个数值

# α = manufacturing expenditure / total expenditure
αs = (Y_l .+ imports .- exports) ./ Y
# 各国按 GDP 加权计算 α
α = (αs .* Y ./ sum(Y)) |> sum

## 7. technology

# 表示技术的 T 来源于 (27) 式，计算所需的 source dummies 的估计系数见 TABLE VI
table3_estimate = estimators["table3_estimate"]
source_estimate = table3_estimate[11:29]
# 这个 tech 使用的都是绝对数据，保持准确量纲，便于 wL 直接与 Y/Y_o 相比
absolute_tech = (log.(effective_wage) .* θ .+ source_estimate) .* β .|> exp

## 8. geography barrier
# barrier_measure 来源于 (28) 式，为 -theta ln(dni)
dni_measure = estimators["dni_measure"]
Dni = exp.(dni_measure) # dni^{-theta} 矩阵

## 9. gamma constant
γ = β^β * (1 - β)^(1 - β) # 不知为何 γ 可以由 β 推出
g = γ^(-θ)

struct Solve
  p
  L
  W
  Xni
  trade_volumn
end

function model_mobile(tech, Dni)

  # 不变参数
  w = effective_wage
  # Y = Y

  # 可变参数
  T = tech
  D = Dni
  k = g .* T .* (w .^ (-β * θ))

  # 设定 P 的迭代初值
  P_low = k .^ (1 / β)
  P_high = sum(k)^(1 / β) .* ones(N)
  P_start = (P_low .+ P_high) / 2

  # (16) 式
  function f!(F, P)
    S = inv(D) * P .- k .* (P .^ (1 - β))
    for i in 1:length(P)
      F[i] = S[i]
    end
  end

  # 解 P
  if D == ones(Int, N, N)
    P = P_high
  else
    P = nlsolve(f!, P_start, iterations=200).zero
  end

  # 根据 P 推导其他变量
  Pi = D .* kron(1 ./ P, (k .* P .^ (1 - β))')
  L = α * β .* (1 ./ w) .* (inv(diagm(ones(Int, N)) .- (1 - β) .* Pi') * Pi' * Y)
  Xn = w .* L .* (1 - β) / β + α .* Y
  Xni = Pi .* kron(Xn, ones(Int, 1, N))
  trade_volumn = sum(Xni) - sum(diag(Xni))
  W = Y .* P .^ (α / θ)

  return Dict("p" => P .^ (-1 / θ), "L" => L,
    "W" => W, "Xni" => Xni, "trade_volumn" => trade_volumn)
end


baseline_mobile = model_mobile(absolute_tech, Dni)




