# -*- coding: utf-8 -*-

using Markdown, Pipe
using CSV, JSON, DataFrames
using LinearAlgebra


md"# Pre Simulation"


md"## Config"

scalars = JSON.parsefile("./data/scalar.json")

# 标量都用普通字体，向量和矩阵用粗斜体
const J = scalars["J"]; # number of factors
const N = scalars["N"]; # number of countries
const δ = scalars["delta"]; # 反馈系数
const tol = scalars["tolerance"]; # 精度
const max_itr = scalars["maxIterator"]; # 最大迭代次数


md"## Read data"

md"### Data File Path"

data_trade = "./data/xbilat1993.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边贸易量矩阵, 共20个可贸易部门
data_τ1993 = "./data/tariffs1993.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边关税矩阵, 共20个可贸易部门
data_τ2005 = "./data/tariffs2005.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边关税矩阵, 共20个可贸易部门
data_IO = "./data/IO.txt"; # NJ×J, 每 J 行为一个国家的行业 I-O 矩阵。注意，行表示中间品来源，列表示中间品去处，各列之和为 1
data_γʲ = "./data/B.txt"; # J×N, γₙʲ, 劳动收入占比. 行为部门, 列为国家. 
data_Y = "./data/GO.txt"; # J×N, Yₙʲ, 部门产出. 行为部门, 列为国家
data_θ = "./data/T.txt"; # 20×1, θʲ, 20个可贸易部门的θ


md"### Custom Reading Functions"

include("ReadData.jl")
using .ReadData

md"### Data Reading and Wrangling"

# 双边贸易
trade = 1000 * cat(to_tensor(data_trade, N, N, 20), zeros(N, N, 20); dims=3) # 在第三个维度(部门)上连接

# 双边关税率 
𝝉 = cat(to_tensor(data_τ1993, N, N, 20), zeros(N, N, 20); dims=3) / 100
𝝉̃ = 1 .+ 𝝉
# 𝝉′ = 𝝉
𝝉′ = cat(to_tensor(data_τ2005, N, N, 20), zeros(N, N, 20); dims=3) / 100
𝝉̃′ = 1 .+ 𝝉′

# 投入产出表数据比较特殊, 三个维度分别为 k, j, n
tensor_IO = to_tensor(data_IO, J, J, N)
# mapslices(sum, tensor_IO[:, :, 3]; dims=1) # 验证某国各列和为1

# 劳动成本在总成本中占比
𝜸ʲ = to_matrix(data_γʲ)'

# 计算 𝜸ᵏʲ, j部门产品总成本中k部门中间品所占的份额
𝜸ᵏʲ = zeros(J, J, N)
for k ∈ 1:J, j ∈ 1:J, n ∈ 1:N
    𝜸ᵏʲ[k, j, n] = tensor_IO[k, j, n] * (1 - 𝜸ʲ[n, j])
end
# 𝜸ᵏʲ

# 部门产出
𝒀 = to_matrix(data_Y)'

# 部门技术分布常数, 非贸易部门的θ是8.22
𝜽 = @pipe to_matrix(data_θ) |> vcat(_, fill(8.22, (20, 1)))


md"## Data Transformation"

# 进出口
𝑬𝑿 = @pipe mapslices(sum, trade; dims=1) |> reshape(_, (N, J)) # 对n加总为某国总出口
𝑰𝑴 = @pipe mapslices(sum, trade; dims=2) |> reshape(_, (N, J)) # 对i加总为某国总进口

# 对国内产品的支出
𝑿ₙₙ = max.(𝑬𝑿, 𝒀) - 𝑬𝑿 # 产出减出口，即国内销售

# 支出张量
𝑿 = trade .* 𝝉̃ # 进口额加上关税才是对外国的支出
for n ∈ 1:N, j ∈ 1:J
    𝑿[n, n, j] = 𝑿ₙₙ[n, j] # 再加上对国内产品的支出, 才是完整的支出数据
end

# 各国总支出
𝑿ₙ = @pipe mapslices(sum, 𝑿; dims=2) |> reshape(_, (N, J)) # 对进口来源（第二个维度）求和

# 支出份额
𝝅 = 𝑿 ./ mapslices(sum, 𝑿; dims=2) # 除数的第二个维度自动扩展
#= 标量写法
𝝅 = zeros(N, N, J)
for n ∈ 1:N, i ∈ 1:N, j ∈ 1:J
    𝝅[n, i, j] = 𝑿[n, i, j] / 𝑿ₙ[n, j]
end
=#

# 总劳动收入, 对部门加总即可
𝒘𝑳 = @pipe (𝜸ʲ .* 𝒀) |> mapslices(sum, _; dims=2)

# 关税转移支付. 此式不能以直觉理解，是推导出来的，见 CP 笔记 (8.5) 式
𝑻𝑹 = @pipe reshape(𝑿ₙ, (N, 1, J)) .* (1 .- mapslices(sum, 𝝅 ./ 𝝉̃; dims=2)) |> # 对出口国i加总 
           mapslices(sum, _; dims=3) |> # 对部门j加总
           reshape(_, N)

# 贸易赤字, 对部门加总
𝑫 = @pipe (𝑰𝑴 - 𝑬𝑿) |> mapslices(sum, _; dims=2)

# 总预算
𝑰 = 𝒘𝑳 + 𝑻𝑹 + 𝑫


"""
n国对各部门中间产品的引致需求，返回行向量
"""
function derive_demand(n::Int64)::Matrix
    # n国各部门总销售
    Sales = 𝑿ₙₙ + 𝑬𝑿

    # n国各部门投入的中间品总成本
    intermediate_cost = (1 .- 𝜸ʲ[n, :]) .* Sales[n, :]

    # n国各部门间的投入产出表：行部门产品，在列部门所有中间品需求中的比率
    IO_matrix::Matrix = tensor_IO[:, :, n]

    (IO_matrix * intermediate_cost[:])' # 等价写法：intermediate_cost' * IO_matrix'
end

# 生产过程中对各种中间产品的需求)
intermediate_demand = @pipe derive_demand.(1:N) |> vcat(_...)

# 各国对各部门最终产品的需求
final_demand = 𝑿ₙ - intermediate_demand

# 最终消费品在总预算中的占比
𝜶 = @pipe (final_demand ./ 𝑰) |>
          replace(x -> x < 0 ? 0 : x, _) # 小于0的值全部以0替代

𝜶 = 𝜶 ./ mapslices(sum, 𝜶; dims=2) # 因为将负数变成了0, 各部门α总和未必是1, 要重新归一化
# 验证重新对 α 归一
# mapslices(sum, 𝜶; dims=2) 


md"# Simulation"


md"## Import Modules"

include("Equilibrium.jl")
using .Equilibrium


md"## BaseLine"

solve_equilibrium(N, J, δ, tol, max_itr, 𝝉̃, 𝝉̃′, 𝜸ʲ, 𝜸ᵏʲ, 𝜽, 𝝅, 𝑿ₙ, 𝒘𝑳, 𝑫, 𝜶)




