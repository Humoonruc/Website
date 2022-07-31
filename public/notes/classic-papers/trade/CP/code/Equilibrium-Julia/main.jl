# -*- coding: utf-8 -*-


# ## Using Packages
using CSV, DataFrames, Pipe


# ## config
J = 40
N = 31


# ## read data
# 将数据尽可能读为3维张量，三个维度分别代表本国, 他国, 部门    
# 不论观察还是操作数据，一眼就能看明白是哪个坐标
data_trade = "./data/xbilat1993.txt" # 20N×N, 每 N 行为一个可贸易部门的双边贸易量矩阵，共20个可贸易部门
data_τ1993 = "./data/tariffs1993.txt" # 20N×N, 每 N 行为一个可贸易部门的双边关税矩阵，共20个可贸易部门
data_τ2005 = "./data/tariffs1993.txt"
data_io = "./data/IO.txt" # NJ×J, 每 J 行为一个国家的行业 I-O 矩阵，共N个。行为 destination sectors，列为 source sectors
data_γʲ = "./data/B.txt" # J×N, γₙʲ, 行为部门，列为国家. 
data_Y = "./data/GO.txt" # J×N, Yₙʲ, 行为部门，列为国家
data_θ = "./data/T.txt" # 20×1, 可贸易部门的 θʲ


"""
读取N行数据，返回矩阵; j决定读取哪N行
"""
function read_table(data, N, j)::Matrix
    CSV.read(data, DataFrame; header=false, skipto=N * (j - 1) + 1, limit=N) |> Matrix
end

"""
将二维数据读取为三维张量，三个维度分别代表本国、外国、部门

# Arguments
- `data`, 二维数据文件，一般有N×J行，M列，每N行、M列构成一个具有意义的二维表，第三维在行方向排列
"""
function to_tensor(data, N, M, J)
    tables = [read_table(data, N, j) for j ∈ 1:J]
    vector = vcat([table[:] for table ∈ tables]...)
    reshape(vector, (N, M, J))
end


# 双边贸易
tensor_X = to_tensor(data_trade, N, N, 20)
X = 1000 * cat(tensor_X, zeros(N, N, 20); dims=3)

# 双边关税率
tensor_τ = to_tensor(data_τ1993, N, N, 20)
τ̃₁₉₉₃ = 1 .+ cat(tensor_τ, zeros(N, N, 20); dims=3) / 100

# 投入产出表数据比较特殊，它本质上是四个维度的数据(部门维度有两个)，故对其进行特殊处理
tensor_IO = @pipe to_tensor(data_io, J, J, N)

# 劳动成本在总成本中占比
γʲ = @pipe to_tensor(data_γʲ, 1, N, J) |> reshape(_, (N, 1, J))

# 部门产出
Y = @pipe to_tensor(data_Y, 1, N, J) |> reshape(_, (N, 1, J))

# 部门常数
θ = @pipe to_tensor(data_θ, 1, 1, 20) |> reshape(_, (1, 1, 20))
T = 1 ./ cat(θ, fill(8.22, (1, 1, 20)); dims=3) # 非贸易部门的θ是8.22


# ## data processing
# 进出口
E = @pipe mapslices(sum, X; dims=1) |> reshape(_, (N, 1, J)) # 对n加总为总出口
M = @pipe mapslices(sum, X; dims=2) # 对i加总为总进口

Xₙₙ = max.(E, Y) - E # 产出减出口为国内销售
Sales = Xₙₙ + E # 总销售

EX = X .* τ̃₁₉₉₃ # X乘以关税才是对外国的支出数据
[EX[n, n, j] = Xₙₙ[n, 1, j] for n ∈ 1:N for j ∈ 1:J] # X每张table的对角元都是0，加上国内销售数据，才是完整的支出数据
EXₙ = mapslices(sum, EX; dims=2) # 某国总支出，对i（第二个维度）求和即可
Pi = EX ./ EXₙ # 支出份额


# 某国各部门间的投入产出表
IOₙ = n -> tensor_IO[:, :, n]
# 某国各部门中间品成本
m_costₙ = n -> ((1 .- γʲ[n, :, :]) .* Sales[n, :, :])'
# 生产过程中对各种中间产品的引致需求
m_demand = @pipe [IOₙ(n) * m_costₙ(n) for n ∈ 1:N] .|>
                 transpose |> vcat(_...) |> reshape(_, (N, 1, J))
# 对最终产品的需求
final_demand = EXₙ - m_demand


# 总劳动收入，对第三个坐标（部门）加总即可
Yₙˡ = @pipe (γʲ .* Y) |> mapslices(sum, _; dims=3)
# 关税转移支付，先对第二个坐标（进口来源国）加总，再对部门加总
Rₙ = @pipe EXₙ .* (1 .- mapslices(sum, Pi ./ τ̃₁₉₉₃; dims=2)) |>
           mapslices(sum, _; dims=3)
# 贸易赤字，对部门加总
Dₙ = @pipe (M - E) |> mapslices(sum, _; dims=3)
# 总预算
Iₙ = Yₙˡ + Rₙ + Dₙ


# 最终消费品在总预算中的占比
αs = @pipe (final_demand ./ Iₙ) |> replace(x -> x < 0 ? 0 : x, _)
αs = αs ./ mapslices(sum, αs; dims=3) # 因为将负数变成了0，各部门α总和未必是1，要重新归一化

























vfactor = -0.2 # 迭代的负反馈系数
tol = 1e-7 # 误差容忍度（精度）
maxitr = 1e10 # 最大迭代次数