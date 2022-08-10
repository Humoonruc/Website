# -*- coding: utf-8 -*-

using Markdown, Pipe
using CSV, JSON, DataFrames
using LinearAlgebra


md"# Pre Simulation"


md"## Config"

scalars = JSON.parsefile("./data/scalar.json")

# 标量都用普通字体
J = scalars["J"]; # number of factors
N = scalars["N"]; # number of countries
δ = scalars["delta"]; # 反馈系数
tol = scalars["tolerance"]; # 精度
max_itr = scalars["maxIterator"]; # 最大迭代次数


md"## Read data
将三维数据读为张量, 三个维度分别代表本国, 他国, 部门
"

md"### Data File Path"

data_trade = "./data/xbilat1993.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边贸易量矩阵, 共20个可贸易部门
data_τ1993 = "./data/tariffs1993.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边关税矩阵, 共20个可贸易部门
data_τ2005 = "./data/tariffs1993.txt"; # 20N×N, 每 N 行为一个可贸易部门的双边关税矩阵, 共20个可贸易部门
data_io = "./data/IO.txt"; # NJ×J, 每 J 行为一个国家的行业 I-O 矩阵。注意，行表示中间品来源，列表示中间品去处，各列之和为 1
data_γʲ = "./data/B.txt"; # J×N, γₙʲ, 劳动收入占比. 行为部门, 列为国家. 
data_Y = "./data/GO.txt"; # J×N, Yₙʲ, 部门产出. 行为部门, 列为国家
data_θ = "./data/T.txt"; # 20×1, θʲ, 20个可贸易部门的θ


md"### Custom Reading Functions"

"""
读取N行数据, 返回矩阵; j决定读取哪N行
"""
function read_table(path::String, N::Int64, j::Int64)::Matrix
    start = N * (j - 1) + 1
    CSV.read(path, DataFrame; header=false, skipto=start, limit=N) |> Matrix
end

"""
将数据表读为三维张量
# Arguments
- `path`, 数据文件路径, 一般有N×J行、M列. 每N行M列构成一个具有意义的二维表, 第三维(1:J)在行方向排列
"""
function to_tensor(path::String, N::Int64, M::Int64, J::Int64)
    tables = [read_table(path, N, j) for j ∈ 1:J] # 读为若干张N×M表，在第三维上排列成向量
    vector = @pipe tables .|> reshape(_, N * M) |> vcat(_...) # 将这些表展开成一个大向量
    reshape(vector, (N, M, J)) # 重组为张量
end

"""
将只有二维的数据表读为矩阵
"""
function to_matrix(path::String)
    CSV.read(path, DataFrame; header=false) |> Matrix
end


md"### Data Reading and Wrangling"

# 双边贸易
tensor_trade = to_tensor(data_trade, N, N, 20)
trade = 1000 * cat(tensor_trade, zeros(N, N, 20); dims=3) # 在第三个维度(部门)上连接

# 双边关税率
tensor_τ = to_tensor(data_τ1993, N, N, 20)
τ̃₁₉₉₃ = 1 .+ cat(tensor_τ, zeros(N, N, 20); dims=3) / 100

# 投入产出表数据比较特殊, 部门维度有两个, 故对其进行特殊处理
tensor_IO = to_tensor(data_io, J, J, N)
# 验证某国各列和为1
# mapslices(sum, tensor_IO[:, :, 1]; dims=1) 


# 劳动成本在总成本中占比
𝜸ʲ = to_matrix(data_γʲ)'


# 部门产出
𝒀 = to_matrix(data_Y)'


# 部门技术分布常数
θ = to_matrix(data_θ)
T = 1 ./ vcat(to_matrix(data_θ), fill(8.22, (20, 1))) # 非贸易部门的θ是8.22



md"## Data Transformation"

𝑬𝑿 = @pipe mapslices(sum, trade; dims=1) |> reshape(_, (N, J)) # 对n加总为某国总出口
𝑰𝑴 = @pipe mapslices(sum, trade; dims=2) |> reshape(_, (N, J)) # 对i加总为某国总进口

𝑿ₙₙ = max.(𝑬𝑿, 𝒀) - 𝑬𝑿 # 产出减出口为国内销售，也就是对国内产品的支出
Sales = 𝑿ₙₙ + 𝑬𝑿 # 总销售

𝑿 = trade .* τ̃₁₉₉₃ # 进口额加上关税才是对外国的支出
𝑿 += cat([diagm(𝑿ₙₙ[:, j]) for j ∈ 1:J]...; dims=3) # 再加上对国内产品的支出, 才是完整的支出数据
#=标量写法
for n ∈ 1:N, j ∈ 1:J
    𝑿[n, n, j] = 𝑿ₙₙ[n, j]
end
=#

𝑿ₙ = @pipe mapslices(sum, 𝑿; dims=2) |> reshape(_, (N, J)) # 某国总支出, 对i（第二个维度）求和
𝝅 = 𝑿 ./ mapslices(sum, 𝑿; dims=2) # 支出份额，除数的第二个维度自动扩展
#= 标量写法
𝝅 = zeros(N, N, J)
for n ∈ 1:N, i ∈ 1:N, j ∈ 1:J
    𝝅[n, i, j] = 𝑿[n, i, j] / 𝑿ₙ[n, j]
end
=#

# 总劳动收入, 对第三个坐标（部门）加总即可
𝒘𝑳 = @pipe (𝜸ʲ .* 𝒀) |> mapslices(sum, _; dims=2)

# 关税转移支付, 先对第二个坐标（进口来源国）加总, 再对部门加总
# 此式不能以直觉理解，是推导出来的，见 CP 笔记 (8.5) 式
𝑹 = @pipe (1 .- mapslices(sum, 𝝅 ./ τ̃₁₉₉₃; dims=2) |> reshape(_, (N, J))) |>
          (.*)(𝑿ₙ, _) |>
          mapslices(sum, _; dims=2)

# 贸易赤字, 对部门加总
𝑫 = @pipe (𝑰𝑴 - 𝑬𝑿) |> mapslices(sum, _; dims=2)

# 总预算
𝑰 = 𝒘𝑳 + 𝑹 + 𝑫




"""
n国对各部门中间产品的引致需求，返回行向量
"""
function derive_demand(n::Int64)::Matrix
    # n国各部门间的投入产出表：行部门产品，在列部门所有中间品需求中的比率
    IO_matrix::Matrix = tensor_IO[:, :, n]

    # n国各部门投入的中间品总成本
    intermediate_cost::Vector = (1 .- 𝜸ʲ[n, :]) .* Sales[n, :]

    return (IO_matrix * intermediate_cost)'
end

# 生产过程中对各种中间产品的需求
intermediate_demand = @pipe derive_demand.(1:N) |> vcat(_...)

# 各国对各部门最终产品的需求
final_demand = 𝑿ₙ - intermediate_demand

# 最终消费品在总预算中的占比
𝜶 = @pipe (final_demand ./ 𝑰) |>
          replace(x -> x < 0 ? 0 : x, _) # 小于0的值全部以0替代

𝜶 = 𝜶 ./ mapslices(sum, 𝜶; dims=2) # 因为将负数变成了0, 各部门α总和未必是1, 要重新归一化
mapslices(sum, 𝜶; dims=2) 

md"# Simulation"

md"## Import Modules"

include("RootSolving.jl")
using .RootSolving











