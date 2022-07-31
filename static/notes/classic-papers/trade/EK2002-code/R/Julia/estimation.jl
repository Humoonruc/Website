using JSON, CSV, JLD, DataFrames # data
using LinearAlgebra, Statistics, NLsolve # math
using Pipe # programming

using RCall
R"""
library(tidyverse)
library(data.table)
library(magrittr)
library(ivreg)
"""

const scalars = JSON.parsefile("../data/scalar.json")

const country_table = CSV.read("../data/country_code.csv", DataFrame);
country_table |> println

const regression_data =  CSV.read("../data/regression_data.csv", DataFrame)
first(regression_data, 3) |> println

const price_table = CSV.read("../data/price.csv", DataFrame)
first(price_table, 1) |> println

const N = scalars["N"]

const β = scalars["beta"]

const θₛ= scalars["theta"] # 三种方法估计出的 θ 值

"""
select(df, args...) 返回 DataFrame，有时候计算起来不方便
所以自定义一个 extract 函数，只取一列，返回多列 Matrix 或单列 Vector
"""
function extract(data::DataFrame, var)
    M = select(data, var) |> Matrix
    size(M, 2) > 1 ? M : reshape(M, length(M))
end

index_n = extract(regression_data, :import_country); # kron(1:N, ones(Int, N))
index_i = extract(regression_data, :export_country); # kron(ones(Int, N), 1:N)

# 对数标准化的制造业双边贸易数据 ln(Xni/Xnn)
normalized_trade = extract(regression_data, :trade);

# ln(X'ni/X'nn), (26)式等号的左边
normalized_trade_prime = extract(regression_data, :trade_prime);

# 由 ln(X'ni) 的定义计算 (12) 式的左边 ln (Xni/Xn)/(Xii/Xi)
# 可将其视为 country n's normalized import share from country i
normalized_trade_share = -(normalized_trade_prime - normalized_trade) * β / (1 - β) .+ normalized_trade;

# 这批变量需要的计算较少，保留变量名则很重要，所以用 select()

# 六档距离，说明见P21
dist = select(regression_data, 6:11)

# 是否 share border/language
border = select(regression_data, :border);
language =  select(regression_data, :common_language);

# 是否在同一个 RTA 中（欧共体EEC是EU的前身，EFTA是欧自联）
RTA = select(regression_data, :both_in_EU, :both_in_EFTA); 

# 横向合并 distance, border, language, RTA 等虚拟变量
# 注意，六档距离只需要 5 个 dummy variable 
geography_dummy = hcat(select(dist, Not(:dist1)), border, language, RTA);

# 以下 5 个变量的数值都是对数标准化的，即 ln(var_i/var_n)
# 分别是(1)R&D 支出, (2)以平均受教育年限来衡量的 human capital
# (3)人口密度, (4)制造业劳动力数量, (5)工资（均以美元计）
r_and_d = extract(regression_data, :r_and_d);
human_capital = extract(regression_data, :human_capital);
density = extract(regression_data, :density);
labor = extract(regression_data, :labor);
wage = extract(regression_data, :wage);

# 国家首都之间的对数距离
ln_distance = extract(regression_data, :distance) .|> log

"""
生成某对 (n, i) 对应的进/出口国虚拟变量，维度为 1×N

# arguments
- k 代表 index_n 或 index_i
"""
function render_line(k::Int)
  [x == k ? 1 : 0 for x ∈ 1:19]'
end

# 进口国（目的地国）虚拟变量的矩阵，第 index_n 列标 1
destination_matrix = vcat([render_line(n) for n ∈ 1:N for i ∈ 1:N]...);
# destination_matrix = kron(diagm(ones(Int, N)), ones(Int, N)) # 另一种写法

# 出口国（来源国）虚拟变量的稀疏矩阵，第 index_i 列标 1 
source_matrix = vcat([render_line(i) for n ∈ 1:N for i ∈ 1:N]...);
# source_matrix = kron(ones(Int, N), diagm(ones(Int, N))) # 另一种写法

# (28)式中的来源国虚拟变量 S_i-S_n
source_dummy = source_matrix .- destination_matrix;
# 这个减法决定了 source_dummy 和 destination_dummy 在(30)式中是不对称的

# (29)式中的目的地国虚拟变量 m_n
destination_dummy = destination_matrix;

# 以其中一个虚拟变量为基准，用其他虚拟变量与这个基准的相对差异，作为回归模型的自变量
# 以美国（第19列）为基准，前18列都减去19列
relative_source_dummy = DataFrame(
  source_dummy[:, 1:(N-1)] .- source_dummy[:, N], # 第一个参数是构成 df 主体的矩阵
  "S" .* string.(1:(N-1)) # DataFrame 的第二个参数是列名向量
);

relative_destination_dummy = DataFrame(
  destination_dummy[:, 1:(N-1)] .- destination_dummy[:, N],
  "m" .* string.(1:(N-1)) # 列名
);

price = extract(price_table, Not(:country));

# 对 n, i 交叉遍历，求对应每一行 (n, i) 的50种产品相对价格
relative_price = vcat([(price[n:n, :] .- price[i:i, :]) for n ∈ 1:N for i ∈ 1:N]...);
# 另一种写法：
# destination_price = kron(price, ones(Int, N)) # 目的地国 $\ln p_n(j)$
# source_price = kron(ones(Int, N), price) # 来源地国 $\ln p_i(j)$
# relative_price = destination_price .- source_price

function max2(vector)
  sorted = vector |> sort |> reverse # 此处不要改变原矩阵，拷贝一份
  sorted[2] 
end

ln_dₙᵢ = mapslices(max2, relative_price; dims=2);
# dims=2，沿列的方向依次应用函数，即函数的参数总是一行

# 用 50 种商品对数标准化价格的平均值作为各国价格指数的代理变量
price_index = mapslices(mean, price; dims=2);

# (13)式: D_{ni}=ln(p_i)-ln(p_n)+ln(d_{ni})
Dni = [price_index[i] - price_index[n] for n ∈ 1:N for i ∈ 1:N] .+ ln_dₙᵢ;

valid_index = index_n .!= index_i;
# 由于 index_n 和 index_i 均为单列矩阵，返回也是 Bool 型的单列矩阵
# 若不 reshape 成向量，就无法作为 DataFrame 的行选择器

# destinations and sources index
index_n_valid = index_n[valid_index]
index_i_valid = index_i[valid_index]

# ln(X'ni/X'nn)
normalized_trade_prime_valid = normalized_trade_prime[valid_index]

# ln (Xni/Xn)/(Xii/Xi)
normalized_trade_share_valid = normalized_trade_share[valid_index]

# exp(D_{ni})，用于 Figure 2
Dni_valid = Dni[valid_index]
price_measure = exp.(Dni_valid) 

# ln_distance
ln_distance_valid = ln_distance[valid_index];

# 距离、边界、语言、RTA等虚拟变量
geography_dummy_valid = geography_dummy[valid_index, :];

# 国家虚拟变量
relative_source_dummy_valid = relative_source_dummy[valid_index, :];
relative_destination_dummy_valid = relative_destination_dummy[valid_index, :];
country_dummy_valid = hcat(relative_source_dummy_valid, relative_destination_dummy_valid);
# names(country_dummy_valid)

lowest, highest = exp.(normalized_trade_share_valid) |> extrema

# 标准化贸易份额的最大值
println(highest)

# 横跨近四个数量级
log10(highest/lowest)

# 相关系数 correlation
cor(Dni_valid, normalized_trade_share_valid)

x_center = mean(Dni_valid)
y_center = mean(normalized_trade_share_valid)
theta = y_center / x_center

# 将 julia 变量转变为 R 变量
R"""
normalized_trade_prime_valid <- $normalized_trade_prime_valid
geography_dummy_valid <- $geography_dummy_valid
country_dummy_valid <- $country_dummy_valid
Dni_valid <- $Dni_valid

TSLS_data <- cbind(normalized_trade_prime_valid, Dni_valid, geography_dummy_valid, country_dummy_valid)

head(TSLS_data)
"""

# IV Regression 的公式
R"""
formula_exogenous <- colnames($country_dummy_valid) %>% str_c(collapse = " + ")
formula_instrument <- colnames($geography_dummy_valid) %>% str_c(collapse = " + ")
formula <- str_c(
  "normalized_trade_prime_valid ~ Dni_valid + ", formula_exogenous, " | ",
  formula_instrument, " + ", formula_exogenous
)
"""

R"""
fit_iv_3 <- ivreg(formula = formula, data = TSLS_data)
summary(fit_iv_3, test = TRUE)
"""

# 组织数据框 country_dummy_valid
dist1_valid = select(regression_data, :dist1)[valid_index, :]

R"""
dist1_valid = $dist1_valid
table3_data <- cbind(
  normalized_trade_prime_valid, dist1_valid, 
  geography_dummy_valid, country_dummy_valid
) %>%
  as.data.table()
"""

# OLS
R"""
lm_table3 <- lm(normalized_trade_prime_valid ~ 0 + ., data = table3_data)
summary(lm_table3)
"""

R"res <-lm_table3$residuals"
@rget res

ee_matrix = res * res'

sigma_square_sum = diag(ee_matrix) |> mean

R"""
observation_valid <- data.table(n = $index_n_valid, i = $index_i_valid) %>%
  `[`(, index := .I)

print(observation_valid)
"""

# 遍历每一对 (n, i)，找到其与 (i, n) 在 ee_matrix 中对应的元素
# 把这 342 个元素加起来就平均，就是 σ2^2 的估计值
R"""
sigma2_square <- observation_valid$index %>%
  map_dbl(function(row_index) {
    n_row <- observation_valid$n[row_index]
    i_row <- observation_valid$i[row_index]
    col_index <- observation_valid[n == i_row & i == n_row, ]$index
    $ee_matrix[row_index, col_index]
  }) %>%
  mean()

sigma2_square
"""
# $ee_matrix 前面的 $ 表示这个矩阵本来是 julia 变量

sigma_square_sum - @rget sigma2_square 

R"""
Omega <- diag(nrow(observation_valid)) * $sigma_square_sum

observation_valid$index %>%
  walk(function(row_index) {
    n_row <- observation_valid$n[row_index]
    i_row <- observation_valid$i[row_index]
    col_index <- observation_valid[n == i_row & i == n_row, ]$index
    Omega[row_index, col_index] <<- sigma2_square 
  })

Omega %>%
  round(2) %>%
  as.data.table()
""";

# 求逆
R"Omega_inverse <- solve(Omega)"

# GLS estimation
R"""
Y <- table3_data$normalized_trade_prime_valid
X <- table3_data[, -1] %>% as.matrix()

# 3 most important results
estimate <- solve(t(X) %*% Omega_inverse %*% X) %*% t(X) %*% Omega_inverse %*% Y
estimate_S19 <- -estimate[11:28] %>% sum() 
estimate_m19 <- -estimate[29:46] %>% sum()

var_estimate <- solve(t(X) %*% Omega_inverse %*% X)
stand_error <- diag(var_estimate) %>% sqrt()
stand_error_S19 <- var_estimate[11:28, 11:28] %>%
  sum() %>% 
  sqrt()
stand_error_m19 <- var_estimate[29:46, 29:46] %>%
  sum() %>%
  sqrt()
"""

# Table III
R"""
country_table = $country_table

gls_estimate <- c(
  estimate[1:28], estimate_S19,
  estimate[29:46], estimate_m19
)
gls_stand_error <- c(
  stand_error[1:28], stand_error_S19,
  stand_error[29:46], stand_error_m19
)
gls_parameters <- c(
  1:6 %>% str_c("$-\\theta d_{", ., "}$"),
  "$-\\theta b$", "$-\\theta l$", "$-\\theta e_1$", "$-\\theta e_2$",
  1:19 %>% str_c("$S_{", ., "}$"),
  1:19 %>% str_c("$-\\theta m_{", ., "}$")
)
variable_names <- c(
  "Distance [0, 375)", "Distance [375, 750)", "Distance [750, 1500)",
  "Distance [1500, 3000)", "Distance [3000, 6000)", "Distance [6000, maximum)",
  "Shared border", "Shared language", "Both in EEC/EU", "Both in EFTA",
  country_table$name %>% str_c("Source country: ", .),
  country_table$name %>% str_c("Destination country: ", .)
)
table3 <- data.table(
  variables = variable_names,
  parameters = gls_parameters,
  estimate = round(gls_estimate, 2),
  std_error = round(gls_stand_error, 2)
)
table3 %>%
  mutate(std_error = str_c("(", std_error, ")")) %>%
  set_colnames(c("Variable", "parameter", "est.", "s.e."))
"""

# Table III 估计出的 48 个系数
table3_estimate = @rget gls_estimate

# 拟合值: d_measure
geography_dummy = Matrix(regression_data[!, [6:12;18:20]])
barrier_dummy = hcat(geography_dummy, destination_dummy) # 保留 invalid 行，与前面不同

barrier_estimate =table3_estimate[[1:10;30:48]] 
barrier_sum = barrier_dummy * barrier_estimate
barrier_sum[index_n .== index_i] .= 0
dni_measure = reshape(barrier_sum, N, N)' |> Matrix

save("../data/table3-output.jld", "table3_estimate", table3_estimate, "dni_measure", dni_measure) 
